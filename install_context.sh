#!/bin/bash

# install_context.sh
# Installs the AI coding context (Agents, Rules, Skills) into a target project.

# Source directory (where this script is located)
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Target directory (argument 1, or current directory)
TARGET_DIR="${1:-.}"

# Destination folder inside the target project
DEST_CONTEXT_DIR="$TARGET_DIR/.ai-context"

echo "🤖 AI Context Installer"
echo "======================="
echo "Source: $SOURCE_DIR"
echo "Target: $TARGET_DIR"

# Check if source files exist
if [ ! -f "$SOURCE_DIR/AGENTS.md" ]; then
    echo "❌ Error: AGENTS.md not found in source directory."
    exit 1
fi

# Create destination directory
if [ ! -d "$DEST_CONTEXT_DIR" ]; then
    echo "📂 Creating $DEST_CONTEXT_DIR..."
    mkdir -p "$DEST_CONTEXT_DIR"
else
    echo "📂 Directory $DEST_CONTEXT_DIR already exists."
fi

# Language Selection
echo "🌐 Select Language / 选择语言:"
echo "   1) English (Default)"
echo "   2) Chinese (中文)"
read -p "Enter number [1]: " lang_choice
case $lang_choice in
    2) LANG_DIR="zh" ;;
    *) LANG_DIR="en" ;;
esac
echo "✅ Selected Language: $LANG_DIR"

# Copy files
echo "📄 Copying context files..."
cp "$SOURCE_DIR/AGENTS.md" "$DEST_CONTEXT_DIR/"

# Create subdirectories in destination
mkdir -p "$DEST_CONTEXT_DIR/agents"
mkdir -p "$DEST_CONTEXT_DIR/rules"
mkdir -p "$DEST_CONTEXT_DIR/skills"

# Copy specific language versions
cp "$SOURCE_DIR/agents/$LANG_DIR/"*.md "$DEST_CONTEXT_DIR/agents/"
cp "$SOURCE_DIR/rules/$LANG_DIR/"*.mdc "$DEST_CONTEXT_DIR/rules/"
cp "$SOURCE_DIR/skills/$LANG_DIR/"*.md "$DEST_CONTEXT_DIR/skills/"

# Optional: Create/Update .cursorrules (for Cursor users)
CURSOR_RULES_FILE="$TARGET_DIR/.cursorrules"
CURSOR_RULES_DIR="$TARGET_DIR/.cursor/rules"

echo "💡 setup .cursorrules? (Merging AGENTS.md into root .cursorrules and installing rules/ to .cursor/rules)"
read -p "Do you want to create/overwrite .cursorrules and install rules? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 1. Create .cursor/rules
    if [ ! -d "$CURSOR_RULES_DIR" ]; then
        echo "📂 Creating $CURSOR_RULES_DIR..."
        mkdir -p "$CURSOR_RULES_DIR"
    fi
    cp "$SOURCE_DIR/rules/$LANG_DIR/"*.mdc "$CURSOR_RULES_DIR/"
    echo "✅ Installed separate rule files to $CURSOR_RULES_DIR"

    # 2. Create root .cursorrules (Mainly for Agents)
    echo "📝 Generating .cursorrules..."
    echo "# AI Coding Assistant Rules" > "$CURSOR_RULES_FILE"
    echo "" >> "$CURSOR_RULES_FILE"
    echo "## 🚀 CORE AGENT DEFINITION" >> "$CURSOR_RULES_FILE"
    cat "$SOURCE_DIR/AGENTS.md" >> "$CURSOR_RULES_FILE"
    
    # Optional: We could add a note or the general rules here too
    echo "" >> "$CURSOR_RULES_FILE"
    echo "## 📏 GENERAL CODING RULES" >> "$CURSOR_RULES_FILE"
    # Fallback: Add general philosophy to root rules for context
    cat "$SOURCE_DIR/rules/$LANG_DIR/general.mdc" >> "$CURSOR_RULES_FILE"
    
    echo "✅ .cursorrules created."
else
    echo "ℹ️  Skipped .cursorrules generation."
fi

echo "✅ Installation complete!"
echo "   Context files are located in: $DEST_CONTEXT_DIR"
