# AI Coding Context — long-running task harness
# Evaluation criterion: does it help an agent run long tasks? (see AGENTS.md)

.PHONY: test

test:
	@echo "== danger-patterns =="
	@bash harness/hooks/lib/danger-patterns.test.sh
	@echo "== pre-commit-check =="
	@bash harness/hooks/pre-commit-check.test.sh
	@echo "== record-test-evidence =="
	@bash harness/hooks/record-test-evidence.test.sh
	@echo ""
	@echo "All suites green."
