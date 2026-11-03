# Changelog

All notable changes to PodStack.

## [1.2.1] - 2026-11-03

### Added
- **`setup.sh --update`** overwrites commands PodStack installed earlier. Files you edited are saved as `<file>.bak` first.
- **`.podstack-manifest`** in each commands folder records installed files with SHA-256 checksums. `setup.sh` and `scripts/sync-to-podcli.sh` share the helpers in `scripts/manifest.sh`.
- **podcli MCP tools in the commands.** `/process-transcript` and `/produce-shorts` use `transcribe_podcast`, `suggest_clips`, `clip_history`, `knowledge_base`, and `create_clip` when available, and fall back to text files.

### Changed
- `sync-to-podcli.sh` deletes only stale files listed in the previous manifest, never your own commands, and backs up commands you edited before overwriting.
- Title length limit is 60 characters everywhere. It is defined once in `templates/12-quick-reference.md`; other files point to it.
- Shorts descriptions: the 150-character limit applies to the first line only.
- Long-form description template opens on the guest's claim instead of "In this episode".
- Commands cite the Completion Protocol in `CLAUDE.md` or `AGENTS.md`. `/review-content` and `/produce-shorts` allow `AskUserQuestion` and give a fallback for hosts without `AskUserQuestion` or `Task`.
- Knowledge base path uses one rule in both scripts: `.podcli/knowledge` when `.podcli/` exists, else `knowledge/`. Every command that reads the knowledge base carries the podcli note.
- `/plan-episode` reads reference channels from `11-inspiration-channels.md`. `/generate-descriptions` reads hashtags from `06-descriptions-template.md`.
- `templates/13-learnings.md` ships without example entries.
- Docs: `triggers:` is guidance, and trigger phrases belong in `description`. README install section leads with `setup.sh`, and "Global install" is now "Shared clone for several projects".
- `AGENTS.md` no longer claims Claude Code reads it.

### Fixed
- `setup.sh` Codex detection checked `-d .codex` or `AGENTS.md` mentioning codex with the wrong operator precedence. It now checks `-d .codex` only.
- `setup.sh` Cursor conversion deleted every `---` line in the command body and kept the unsupported `argument-hint` key.
- `setup.sh` run from inside the clone installed into the clone. It now installs into the parent of a `.podstack` clone, or exits with an error.
- `setup.sh --host` without a value now prints an error.
- Both scripts use `set -euo pipefail`.
- `sync-to-podcli.sh` header named `CLAUDE.md.podstack`; the files are `CLAUDE.podstack.md`, `AGENTS.podstack.md`, and `ETHOS.podstack.md`.
- Removed the Auto-Detection Rules section from `templates/00-master-instructions.md`. It contradicted command-level routing.
- `CLAUDE.md` moment count now reads "4-15, scaled by length".
- README no longer recommends `npx podstack init`, which does not exist. The project tree lists `scripts/`.

## [1.2.0]: 2026-04-18

### Added
- **Multi-host support.** `setup.sh` now takes `--host <name>` and installs into the right location per tool:
  - `claude-code` → `.claude/commands/*.md` + `CLAUDE.md`
  - `codex` → `.codex/prompts/*.md` + `AGENTS.md`
  - `cursor` → `.cursor/rules/*.mdc` + `AGENTS.md` (converts frontmatter for Cursor's rule format)
  - `opencode` → `.opencode/commands/*.md` + `AGENTS.md`
  - `generic` → `commands/*.md` + `AGENTS.md` at project root
  - `auto` (default) auto-detects from existing `.claude/`, `.codex/`, `.cursor/`, `.opencode/` folders
- **`AGENTS.md` promoted to host-agnostic primary doc.** Now contains the full skill index, Completion Protocol, Three-Strike Rule, knowledge-base map, quality gate, and Host Compatibility table, so any tool reading `AGENTS.md` can orchestrate PodStack.
- **Per-host usage docs in README** covering Claude Code, Codex, Cursor, opencode, and generic invocation patterns.

### Changed
- `CLAUDE.md` now clarifies it's the Claude Code-specific variant, points to `AGENTS.md` for cross-tool usage.
- `setup.sh` auto-installs `AGENTS.md` alongside `CLAUDE.md` for Claude Code projects so the cross-tool index is always available.

## [1.1.0]: 2026-04-18

Structural overhaul: frontmatter-driven routing, standardized outcomes, parallel review.

### Added
- **YAML frontmatter on every slash command**: `description`, `allowed-tools`, `argument-hint`, `triggers`. Lets agents route by natural-language triggers.
- **Completion Protocol**: every skill returns `DONE` / `DONE_WITH_CONCERNS` / `BLOCKED` / `NEEDS_INPUT` with evidence. Documented once in `CLAUDE.md`.
- **Three-Strike Rule**: `/produce-shorts` and other orchestrators stop after 3 failed phase attempts instead of looping.
- **Fix-First `/review-content`**: classifies findings as AUTO-FIX (applied directly) or ASK (batched for user). Dispatches parallel specialist subagents: voice, banned-words, clickbait, standalone, SEO, title.
- **Cross-episode learnings file**: `knowledge/13-learnings.md`. `/retro-episode` appends patterns for future episodes to use.
- **Root docs**: `ETHOS.md` (content philosophy), `VERSION`, `CHANGELOG.md`, `AGENTS.md` (machine-readable command index).
- **Sprint workflow framing**: Plan → Process → Write → Review → Publish → Retro.

### Changed
- `CLAUDE.md`: replaced ad-hoc "Auto-Detection Rules" with reference to command-level `triggers:` frontmatter. Added Completion Protocol and Three-Strike Rule sections.
- `/produce-shorts`: phase failures now abort per Three-Strike Rule and emit structured BLOCKED outcome instead of continuing with incomplete phases.
- `/review-content`: restructured from 4-pass serial review to parallel specialist dispatch with Fix-First classification.
- `/retro-episode`: now writes patterns into `knowledge/13-learnings.md` so future runs read them automatically.
- `README.md`: added `/plan-episode` to the command list (was missing), added root docs section.
- `setup.sh`: installs `13-learnings.md` template.

## [1.0.0]: 2026-03-14

Initial release: 9 slash commands, 13 knowledge-base templates, one-command setup.
