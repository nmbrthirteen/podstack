#!/bin/bash
set -e

# PodStack Setup
# Installs slash commands and knowledge base templates into your project

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-.}"

# Colors
TEAL='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${TEAL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${TEAL}  PodStack — Podcast Content Workflow${NC}"
echo -e "${TEAL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Detect if we're in a podcli project
KNOWLEDGE_DIR="knowledge"
if [ -d "$PROJECT_DIR/.podcli" ]; then
    KNOWLEDGE_DIR=".podcli/knowledge"
    echo -e "${GREEN}✓${NC} Detected podcli project"
fi

# 1. Install slash commands
echo -e "\n${YELLOW}Installing slash commands...${NC}"
mkdir -p "$PROJECT_DIR/.claude/commands"

for cmd in "$SCRIPT_DIR/commands/"*.md; do
    filename=$(basename "$cmd")
    if [ -f "$PROJECT_DIR/.claude/commands/$filename" ]; then
        echo "  ⊘ $filename (already exists, skipping)"
    else
        cp "$cmd" "$PROJECT_DIR/.claude/commands/$filename"
        echo -e "  ${GREEN}✓${NC} $filename"
    fi
done

# 2. Install knowledge base templates
echo -e "\n${YELLOW}Installing knowledge base templates...${NC}"
mkdir -p "$PROJECT_DIR/$KNOWLEDGE_DIR"

for tmpl in "$SCRIPT_DIR/templates/"*.md; do
    filename=$(basename "$tmpl")
    if [ -f "$PROJECT_DIR/$KNOWLEDGE_DIR/$filename" ]; then
        echo "  ⊘ $filename (already exists, skipping)"
    else
        cp "$tmpl" "$PROJECT_DIR/$KNOWLEDGE_DIR/$filename"
        echo -e "  ${GREEN}✓${NC} $filename"
    fi
done

# 3. Install CLAUDE.md
echo -e "\n${YELLOW}Installing CLAUDE.md...${NC}"
if [ -f "$PROJECT_DIR/CLAUDE.md" ]; then
    echo "  ⊘ CLAUDE.md already exists"
    echo "  → PodStack config saved to CLAUDE.podstack.md"
    echo "  → Merge manually or replace your existing CLAUDE.md"
    cp "$SCRIPT_DIR/CLAUDE.md" "$PROJECT_DIR/CLAUDE.podstack.md"
else
    cp "$SCRIPT_DIR/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
    echo -e "  ${GREEN}✓${NC} CLAUDE.md"
fi

# 4. Create output directory
mkdir -p "$PROJECT_DIR/episodes"

# Done
echo -e "\n${TEAL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ PodStack installed!${NC}"
echo ""
echo "Next steps:"
echo "  1. Edit your knowledge base files in ${KNOWLEDGE_DIR}/"
echo "     Fill in your show name, voice, brand, and style"
echo ""
echo "  2. Open Claude Code and run:"
echo "     /prep-episode    — Full pipeline from transcript"
echo "     /process-transcript — Just extract moments"
echo "     /generate-titles — Just generate titles"
echo ""
echo -e "${TEAL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
