#!/bin/bash
set -euo pipefail

# PodStack Setup
# Installs slash commands, knowledge base templates, and project docs into your project.
# Host-agnostic: works with Claude Code, OpenAI Codex, Cursor, opencode, or generic.
#
# Usage:
#   ./setup.sh [project-dir] [--host <name>] [--update]
#
#   --host claude-code   (default) installs to .claude/commands/, copies CLAUDE.md
#   --host codex         installs to .codex/prompts/, copies AGENTS.md as entry point
#   --host cursor        installs to .cursor/rules/ as .mdc files
#   --host opencode      installs to .opencode/commands/
#   --host generic       copies commands/ and AGENTS.md to project root; no tool integration
#   --host auto          (default when --host not passed) auto-detect from existing dirs
#   --update             overwrite commands PodStack installed earlier; edited files are
#                        saved as <file>.bak first. Without it, existing files are skipped.
#
# Recommended layout: clone PodStack to <project>/.podstack and run .podstack/setup.sh
# from the project root. Running it from inside a clone named .podstack installs into the parent.
#
# Examples:
#   ./setup.sh                         # auto-detect, install to current dir
#   ./setup.sh ~/my-podcast            # auto-detect, install to ~/my-podcast
#   ./setup.sh --host codex            # force Codex layout
#   ./setup.sh . --host cursor         # force Cursor layout
#   .podstack/setup.sh --update        # refresh installed commands after git pull

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/manifest.sh
source "$SCRIPT_DIR/scripts/manifest.sh"

# Parse args: first non-flag is PROJECT_DIR, --host takes a value
PROJECT_DIR="."
HOST="auto"
UPDATE=0
while [ $# -gt 0 ]; do
    case "$1" in
        --host)
            if [ $# -lt 2 ] || [[ "$2" == -* ]]; then
                echo "Error: --host needs a value (claude-code, codex, cursor, opencode, generic, auto)" >&2
                exit 1
            fi
            HOST="$2"
            shift 2
            ;;
        --host=*)
            HOST="${1#*=}"
            shift
            ;;
        --update)
            UPDATE=1
            shift
            ;;
        -h|--help)
            sed -n '3,34 p' "$0"
            exit 0
            ;;
        *)
            PROJECT_DIR="$1"
            shift
            ;;
    esac
done

mkdir -p "$PROJECT_DIR"
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
if [ "$PROJECT_DIR" = "$SCRIPT_DIR" ]; then
    if [ "$(basename "$SCRIPT_DIR")" = ".podstack" ]; then
        PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
    else
        echo "Error: refusing to install into the PodStack clone itself." >&2
        echo "Run setup.sh from your project, or pass the project directory." >&2
        exit 1
    fi
fi

# Colors
TEAL='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
DIM='\033[2m'
NC='\033[0m'

VERSION_STR="$(cat "$SCRIPT_DIR/VERSION" 2>/dev/null || echo "dev")"

echo -e "${TEAL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${TEAL}  PodStack v${VERSION_STR}: Podcast Content Workflow${NC}"
echo -e "${TEAL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Auto-detect host if not specified (first match wins)
if [ "$HOST" = "auto" ]; then
    if [ -d "$PROJECT_DIR/.claude" ]; then
        HOST="claude-code"
    elif [ -d "$PROJECT_DIR/.codex" ]; then
        HOST="codex"
    elif [ -d "$PROJECT_DIR/.cursor" ]; then
        HOST="cursor"
    elif [ -d "$PROJECT_DIR/.opencode" ]; then
        HOST="opencode"
    else
        HOST="claude-code"
        echo -e "${DIM}No host config detected. Defaulting to Claude Code.${NC}"
        echo -e "${DIM}Pass --host codex|cursor|opencode|generic to install for another tool.${NC}"
        echo ""
    fi
fi

echo -e "${GREEN}✓${NC} Host: ${HOST}"

# Knowledge base location (.podcli/knowledge in a podcli project)
KNOWLEDGE_DIR="$(detect_knowledge_dir "$PROJECT_DIR")"
if [ "$KNOWLEDGE_DIR" = ".podcli/knowledge" ]; then
    echo -e "${GREEN}✓${NC} Detected podcli project"
fi

# Determine install paths per host
case "$HOST" in
    claude-code)
        COMMANDS_DIR="$PROJECT_DIR/.claude/commands"
        COMMAND_EXT="md"
        PRIMARY_DOC="CLAUDE.md"
        ;;
    codex)
        COMMANDS_DIR="$PROJECT_DIR/.codex/prompts"
        COMMAND_EXT="md"
        PRIMARY_DOC="AGENTS.md"
        ;;
    cursor)
        COMMANDS_DIR="$PROJECT_DIR/.cursor/rules"
        COMMAND_EXT="mdc"
        PRIMARY_DOC="AGENTS.md"
        ;;
    opencode)
        COMMANDS_DIR="$PROJECT_DIR/.opencode/commands"
        COMMAND_EXT="md"
        PRIMARY_DOC="AGENTS.md"
        ;;
    generic)
        COMMANDS_DIR="$PROJECT_DIR/commands"
        COMMAND_EXT="md"
        PRIMARY_DOC="AGENTS.md"
        ;;
    *)
        echo -e "\033[0;31m✗ Unknown --host: $HOST${NC}"
        echo "Valid hosts: claude-code, codex, cursor, opencode, generic, auto"
        exit 1
        ;;
esac

# 1. Install commands
echo -e "\n${YELLOW}Installing commands to ${COMMANDS_DIR}/...${NC}"
mkdir -p "$COMMANDS_DIR"
manifest_begin
RENDERED="$(mktemp)"
trap 'rm -f "$RENDERED"' EXIT

for cmd in "$SCRIPT_DIR/commands/"*.md; do
    name=$(basename "$cmd" .md)
    dest="$COMMANDS_DIR/${name}.${COMMAND_EXT}"

    if [ "$HOST" = "cursor" ]; then
        # Cursor .mdc accepts description and alwaysApply; other keys are dropped.
        {
            echo "---"
            awk '/^---$/ && c < 2 { c++; next } c == 1 && /^description:/ { print }' "$cmd"
            echo "alwaysApply: false"
            echo "---"
            echo ""
            awk '/^---$/ && c < 2 { c++; next } c >= 2' "$cmd"
        } > "$RENDERED"
    else
        cp "$cmd" "$RENDERED"
    fi

    install_managed "$RENDERED" "$dest" "$UPDATE"
    case "$INSTALL_STATUS" in
        installed|unchanged) echo -e "  ${GREEN}✓${NC} ${name}.${COMMAND_EXT}" ;;
        updated)             echo -e "  ${GREEN}↻${NC} ${name}.${COMMAND_EXT} (updated)" ;;
        backed-up)           echo -e "  ${YELLOW}↻${NC} ${name}.${COMMAND_EXT} (updated, your edits saved to ${name}.${COMMAND_EXT}.bak)" ;;
        skipped)             echo "  ⊘ ${name}.${COMMAND_EXT} (already exists, skipping; use --update to overwrite)" ;;
    esac
done

if [ "$UPDATE" = "1" ]; then
    remove_stale "$COMMANDS_DIR" | while read -r line; do echo "  - $line"; done
fi
manifest_commit "$COMMANDS_DIR"

# 2. Install knowledge base templates (same for every host)
echo -e "\n${YELLOW}Installing knowledge base templates to ${KNOWLEDGE_DIR}/...${NC}"
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

# 3. Install primary doc (CLAUDE.md for claude-code, AGENTS.md for everything else)
echo -e "\n${YELLOW}Installing ${PRIMARY_DOC}...${NC}"
if [ -f "$PROJECT_DIR/$PRIMARY_DOC" ]; then
    backup="${PRIMARY_DOC%.md}.podstack.md"
    echo "  ⊘ ${PRIMARY_DOC} already exists"
    echo "  → PodStack config saved to ${backup}"
    echo "  → Merge manually or replace your existing ${PRIMARY_DOC}"
    cp "$SCRIPT_DIR/$PRIMARY_DOC" "$PROJECT_DIR/$backup"
else
    cp "$SCRIPT_DIR/$PRIMARY_DOC" "$PROJECT_DIR/$PRIMARY_DOC"
    echo -e "  ${GREEN}✓${NC} ${PRIMARY_DOC}"
fi

# For non-Claude-Code hosts, also drop AGENTS.md if CLAUDE.md was primary, and vice versa.
# This is a no-op for Codex/Cursor/opencode/generic (AGENTS.md is already primary).
# For claude-code, also install AGENTS.md as a secondary cross-tool index.
if [ "$HOST" = "claude-code" ]; then
    if [ ! -f "$PROJECT_DIR/AGENTS.md" ]; then
        cp "$SCRIPT_DIR/AGENTS.md" "$PROJECT_DIR/AGENTS.md"
        echo -e "  ${GREEN}✓${NC} AGENTS.md (cross-tool index)"
    fi
fi

# 4. Install ETHOS.md (content philosophy, host-agnostic)
echo -e "\n${YELLOW}Installing ETHOS.md...${NC}"
if [ -f "$PROJECT_DIR/ETHOS.md" ]; then
    echo "  ⊘ ETHOS.md already exists, skipping"
else
    cp "$SCRIPT_DIR/ETHOS.md" "$PROJECT_DIR/ETHOS.md"
    echo -e "  ${GREEN}✓${NC} ETHOS.md"
fi

# 5. Create output directory
mkdir -p "$PROJECT_DIR/episodes"

# 6. Host-specific next-step hints
echo -e "\n${TEAL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ PodStack v${VERSION_STR} installed for ${HOST}${NC}"
echo ""
echo "Next steps:"
echo "  1. Edit your knowledge base files in ${KNOWLEDGE_DIR}/"
echo "     Fill in your show name, voice, brand, and style"
echo ""

case "$HOST" in
    claude-code)
        echo "  2. Open Claude Code and run:"
        echo "       /plan-episode        - Design questions BEFORE recording"
        echo "       /produce-shorts      - Full pipeline from transcript"
        echo "       /process-transcript  - Just extract moments"
        echo "       /generate-titles     - Just generate titles"
        echo "       /retro-episode       - Performance review + learnings"
        ;;
    codex)
        echo "  2. Open Codex. It will read AGENTS.md at project root."
        echo "     Say: \"Run the produce-shorts playbook on [transcript]\""
        echo "     Codex will load .codex/prompts/produce-shorts.md and follow it."
        ;;
    cursor)
        echo "  2. In Cursor, open a chat and invoke a rule:"
        echo "     \"Use the produce-shorts rule on [transcript]\""
        echo "     Rules live in .cursor/rules/. Cursor finds them by description."
        ;;
    opencode)
        echo "  2. In opencode, run the command directly:"
        echo "       /produce-shorts"
        echo "     Commands live in .opencode/commands/"
        ;;
    generic)
        echo "  2. Point your AI tool at AGENTS.md (project root)."
        echo "     Say: \"Run the produce-shorts skill from commands/produce-shorts.md\""
        ;;
esac

echo ""
echo "  3. Every skill returns DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_INPUT"
echo "     See ${PRIMARY_DOC} for the Completion Protocol."
echo ""
echo -e "${TEAL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
