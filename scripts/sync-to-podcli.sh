#!/bin/bash
set -e

# Sync the current PodStack into a podcli project.
#
# Usage:
#   ./scripts/sync-to-podcli.sh <path-to-podcli>
#
# Behavior:
#   - Replaces podcli's .claude/commands/*.md with current PodStack commands
#     (deletes stale commands that no longer exist upstream)
#   - Copies any missing knowledge-base templates into podcli's knowledge/
#     (does NOT overwrite existing knowledge files — your edits are safe)
#   - Writes CLAUDE.md.podstack alongside podcli's CLAUDE.md for manual merge
#   - Does NOT touch podcli's CLAUDE.md, README, or source
#   - Does NOT commit — run `git status` in podcli afterward to review

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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
echo -e "${TEAL}  Sync PodStack v${VERSION_STR} → podcli${NC}"
echo -e "${DIM}  target: ${PODCLI_DIR}${NC}"
echo -e "${TEAL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Decide knowledge dir inside podcli (.podcli/knowledge if present, else knowledge/)
KNOWLEDGE_DIR="knowledge"
if [ -d "$PODCLI_DIR/.podcli/knowledge" ]; then
    KNOWLEDGE_DIR=".podcli/knowledge"
fi

# 1. Sync commands (replace + delete stale)
echo -e "\n${YELLOW}Syncing .claude/commands/ ...${NC}"
mkdir -p "$PODCLI_DIR/.claude/commands"

# Delete any command files in target that are NOT in source (stale upstream-removed files)
for existing in "$PODCLI_DIR/.claude/commands/"*.md; do
    [ -f "$existing" ] || continue
    name=$(basename "$existing")
    if [ ! -f "$SCRIPT_DIR/commands/$name" ]; then
        rm "$existing"
        echo -e "  ${RED}-${NC} $name (stale, removed upstream)"
    fi
done

# Copy current source commands, overwriting
for cmd in "$SCRIPT_DIR/commands/"*.md; do
    name=$(basename "$cmd")
    cp "$cmd" "$PODCLI_DIR/.claude/commands/$name"
    echo -e "  ${GREEN}✓${NC} $name"
done

# 2. Sync knowledge templates (never overwrite — user edits are sacred)
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

# 3. CLAUDE.md + AGENTS.md + ETHOS.md — write as .podstack.md suffix so podcli's own copy is preserved
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
