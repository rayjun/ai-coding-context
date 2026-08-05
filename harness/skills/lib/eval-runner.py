#!/usr/bin/env python3
"""
eval-runner — 解析 SKILL.md 中的"质量评估标准"EVAL 块，按二元 pass/fail 打分。

Modes:
  parse <skill.md>                     # 仅解析并打印 EVAL 条目
  prompt <skill.md>                    # 生成发给 LLM 的评估提示（自行接外部 API）
  score <skill.md> <transcript.txt>    # 规则式快速评分（启发式，不保证精度）

EVAL 格式示例（来自 investigate / plan-review / careful-ops 等）:
    ```
    EVAL 1: 标题
    问题: ...?
    Pass: ...
    Fail: ...
    ```

对于严格评估建议把 prompt 模式输出给 Claude/GPT；score 模式只做启发式自检。
"""
from __future__ import annotations
import argparse
import json
import re
import sys
from dataclasses import dataclass, asdict
from pathlib import Path


@dataclass
class Eval:
    index: int
    title: str
    question: str
    pass_criteria: str
    fail_criteria: str


EVAL_BLOCK_RE = re.compile(
    r"EVAL\s+(\d+):\s*(.+?)\n问题:\s*(.+?)\nPass:\s*(.+?)\nFail:\s*(.+?)(?=\n\s*(?:EVAL\s+\d+|```|\Z))",
    re.DOTALL,
)


def parse_evals(path: Path) -> list[Eval]:
    text = path.read_text(encoding="utf-8")
    evals: list[Eval] = []
    for m in EVAL_BLOCK_RE.finditer(text):
        evals.append(
            Eval(
                index=int(m.group(1)),
                title=m.group(2).strip(),
                question=m.group(3).strip(),
                pass_criteria=m.group(4).strip(),
                fail_criteria=m.group(5).strip(),
            )
        )
    return evals


def cmd_parse(skill: Path) -> int:
    evals = parse_evals(skill)
    if not evals:
        print(f"WARN: no EVAL blocks found in {skill}", file=sys.stderr)
        return 1
    print(json.dumps([asdict(e) for e in evals], ensure_ascii=False, indent=2))
    return 0


def cmd_prompt(skill: Path) -> int:
    evals = parse_evals(skill)
    if not evals:
        print(f"ERROR: no EVAL blocks in {skill}", file=sys.stderr)
        return 1
    print(f"# Skill evaluation prompt for: {skill}\n")
    print("You are given a transcript of an AI session. For each evaluation below,")
    print("output one line: `EVAL <n>: pass|fail — <one-sentence justification>`.\n")
    print("Do not hedge. If evidence is missing, that's fail.\n")
    print("## Evaluations\n")
    for e in evals:
        print(f"### EVAL {e.index}: {e.title}")
        print(f"Question: {e.question}")
        print(f"Pass: {e.pass_criteria}")
        print(f"Fail: {e.fail_criteria}\n")
    print("## Transcript")
    print("(paste the session transcript after this line)")
    return 0


# ---- Heuristic score mode ---------------------------------------------------
# Each EVAL gets a tiny set of string-match rules derived from its Pass/Fail text.
# This is strictly a cheap sanity check — not a replacement for LLM evaluation.

def heuristic_score(evals: list[Eval], transcript: str) -> list[dict]:
    results = []
    for e in evals:
        verdict = "unknown"
        reason = "heuristic: no strong signal"
        pcrit = e.pass_criteria.lower()
        fcrit = e.fail_criteria.lower()
        t = transcript.lower()

        # Pull a few keyword-ish tokens (>3 chars, Chinese & English) from criteria
        def tokens(s: str) -> list[str]:
            return [w for w in re.split(r"[\s,，。.?？:：;；、/()（）\[\]【】'\"`]+", s) if len(w) >= 3]

        ptoks = [w for w in tokens(pcrit) if w not in {"问题", "pass", "fail", "是否", "没有"}]
        ftoks = [w for w in tokens(fcrit) if w not in {"问题", "pass", "fail", "是否", "没有"}]

        phits = sum(1 for w in ptoks if w in t)
        fhits = sum(1 for w in ftoks if w in t)

        if phits >= 2 and phits > fhits:
            verdict = "pass"
            reason = f"heuristic: matched {phits} pass-side tokens"
        elif fhits >= 2 and fhits > phits:
            verdict = "fail"
            reason = f"heuristic: matched {fhits} fail-side tokens"

        results.append({
            "eval": e.index,
            "title": e.title,
            "verdict": verdict,
            "reason": reason,
        })
    return results


def cmd_score(skill: Path, transcript: Path) -> int:
    evals = parse_evals(skill)
    if not evals:
        print(f"ERROR: no EVAL blocks in {skill}", file=sys.stderr)
        return 1
    if not transcript.is_file():
        print(f"ERROR: transcript not found: {transcript}", file=sys.stderr)
        return 2
    results = heuristic_score(evals, transcript.read_text(encoding="utf-8"))
    print(json.dumps(results, ensure_ascii=False, indent=2))
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="mode", required=True)

    p_parse = sub.add_parser("parse")
    p_parse.add_argument("skill", type=Path)

    p_prompt = sub.add_parser("prompt")
    p_prompt.add_argument("skill", type=Path)

    p_score = sub.add_parser("score")
    p_score.add_argument("skill", type=Path)
    p_score.add_argument("transcript", type=Path)

    args = ap.parse_args()
    if args.mode == "parse":
        return cmd_parse(args.skill)
    if args.mode == "prompt":
        return cmd_prompt(args.skill)
    if args.mode == "score":
        return cmd_score(args.skill, args.transcript)
    return 2


if __name__ == "__main__":
    sys.exit(main())
