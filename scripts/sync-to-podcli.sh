#!/bin/bash
set -euo pipefail

# Sync the current PodStack into a podcli project.
#
# Usage:
#   ./scripts/sync-to-podcli.sh <path-to-podcli>
#
# Behavior:
#   - Updates podcli's .claude/commands/*.md with current PodStack commands
#   - Records what it installed, with checksums, in .claude/commands/.podstack-manifest
#   - Saves a .bak copy before overwriting a command you edited
#   - Deletes only commands listed in the previous manifest that PodStack no longer
#     ships and that you have not edited. Your own commands are never touched.
#   - Copies any missing knowledge-base templates into podcli's knowledge dir
#     (.podcli/knowledge if .podcli/ exists, else knowledge/). Never overwrites them.
#   - Writes CLAUDE.podstack.md, AGENTS.podstack.md, and ETHOS.podstack.md alongside
#     podcli's own docs for manual merge
#   - Does NOT touch podcli's CLAUDE.md, README, or source
#   - Does NOT commit. Run `git status` in podcli afterward to review

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/manifest.sh
source "$SCRIPT_DIR/scripts/manifest.sh"
PODCLI_DIR="${1:-}"

TEAL='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
DIM='\033[2m'
NC='\033[0m'

if [ -z "$PODCLI_DIR" ]; then
    echo -e "${RED}Usage:${NC} $0 <path-to-podcli>"
    exit 1
fi

if [ ! -d "$PODCLI_DIR" ]; then
    echo -e "${RED}Not a directory:${NC} $PODCLI_DIR"
    exit 1
fi

VERSION_STR="$(cat "$SCRIPT_DIR/VERSION" 2>/dev/null || echo "dev")"

echo -e "${TEAL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${TEAL}  Sync PodStack v${VERSION_STR} to podcli${NC}"
echo -e "${DIM}  target: ${PODCLI_DIR}${NC}"
echo -e "${TEAL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

KNOWLEDGE_DIR="$(detect_knowledge_dir "$PODCLI_DIR")"

# 1. Sync commands. The manifest tells shipped files apart from the user's own.
echo -e "\n${YELLOW}Syncing .claude/commands/ ...${NC}"
COMMANDS_DIR="$PODCLI_DIR/.claude/commands"
mkdir -p "$COMMANDS_DIR"
manifest_begin

for cmd in "$SCRIPT_DIR/commands/"*.md; do
    name=$(basename "$cmd")
    install_managed "$cmd" "$COMMANDS_DIR/$name" 1
    case "$INSTALL_STATUS" in
        updated)   echo -e "  ${GREEN}↻${NC} $name (updated)" ;;
        backed-up) echo -e "  ${YELLOW}↻${NC} $name (updated, your edits saved to $name.bak)" ;;
        *)         echo -e "  ${GREEN}✓${NC} $name" ;;
    esac
done

remove_stale "$COMMANDS_DIR" | while read -r line; do
    echo -e "  ${RED}-${NC} $line"
done
manifest_commit "$COMMANDS_DIR"

# 2. Sync knowledge templates (never overwrite; user edits are kept)
echo -e "\n${YELLOW}Syncing ${KNOWLEDGE_DIR}/ (new files only, no overwrites)...${NC}"
mkdir -p "$PODCLI_DIR/$KNOWLEDGE_DIR"

for tmpl in "$SCRIPT_DIR/templates/"*.md; do
    name=$(basename "$tmpl")
    if [ -f "$PODCLI_DIR/$KNOWLEDGE_DIR/$name" ]; then
        echo -e "  ${DIM}⊘ $name (already present, skipping)${NC}"
    else
        cp "$tmpl" "$PODCLI_DIR/$KNOWLEDGE_DIR/$name"
        echo -e "  ${GREEN}+${NC} $name"
    fi
done

# 3. CLAUDE.md + AGENTS.md + ETHOS.md: write with a .podstack.md suffix so podcli's own copy is preserved
echo -e "\n${YELLOW}Writing PodStack docs as *.podstack.md (merge manually if desired)...${NC}"
for doc in CLAUDE.md AGENTS.md ETHOS.md; do
    if [ -f "$SCRIPT_DIR/$doc" ]; then
        target_name="${doc%.md}.podstack.md"
        cp "$SCRIPT_DIR/$doc" "$PODCLI_DIR/$target_name"
        echo -e "  ${GREEN}✓${NC} $target_name"
    fi
done

# 4. Record the version we synced
echo "$VERSION_STR" > "$PODCLI_DIR/.claude/commands/.podstack-version"
echo -e "  ${GREEN}✓${NC} .claude/commands/.podstack-version = ${VERSION_STR}"

echo -e "\n${TEAL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Synced PodStack v${VERSION_STR} into podcli${NC}"
echo ""
echo "Next steps (in the podcli directory):"
echo "  1. cd \"$PODCLI_DIR\""
echo "  2. git status             # review what changed"
echo "  3. git diff .claude/      # inspect command updates"
echo "  4. Decide whether to merge CLAUDE.podstack.md into CLAUDE.md"
echo "  5. git add + commit when ready"
echo -e "${TEAL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
