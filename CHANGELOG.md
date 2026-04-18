# Changelog

All notable changes to PodStack.

## [1.2.0] — 2026-04-18

### Added
- **Multi-host support.** `setup.sh` now takes `--host <name>` and installs into the right location per tool:
  - `claude-code` → `.claude/commands/*.md` + `CLAUDE.md`
  - `codex` → `.codex/prompts/*.md` + `AGENTS.md`
  - `cursor` → `.cursor/rules/*.mdc` + `AGENTS.md` (converts frontmatter for Cursor's rule format)
  - `opencode` → `.opencode/commands/*.md` + `AGENTS.md`
  - `generic` → `commands/*.md` + `AGENTS.md` at project root
  - `auto` (default) auto-detects from existing `.claude/`, `.codex/`, `.cursor/`, `.opencode/` folders
- **`AGENTS.md` promoted to host-agnostic primary doc.** Now contains the full skill index, Completion Protocol, Three-Strike Rule, knowledge-base map, quality gate, and Host Compatibility table — so any tool reading `AGENTS.md` can orchestrate PodStack.
- **Per-host usage docs in README** covering Claude Code, Codex, Cursor, opencode, and generic invocation patterns.

### Changed
- `CLAUDE.md` now clarifies it's the Claude Code-specific variant, points to `AGENTS.md` for cross-tool usage.
- `setup.sh` auto-installs `AGENTS.md` alongside `CLAUDE.md` for Claude Code projects so the cross-tool index is always available.

## [1.1.0] — 2026-04-18

Structural overhaul: frontmatter-driven routing, standardized outcomes, parallel review.

### Added
- **YAML frontmatter on every slash command** — `description`, `allowed-tools`, `argument-hint`, `triggers`. Lets agents route by natural-language triggers.
- **Completion Protocol** — every skill returns `DONE` / `DONE_WITH_CONCERNS` / `BLOCKED` / `NEEDS_INPUT` with evidence. Documented once in `CLAUDE.md`.
- **Three-Strike Rule** — `/produce-shorts` and other orchestrators stop after 3 failed phase attempts instead of looping.
- **Fix-First `/review-content`** — classifies findings as AUTO-FIX (applied directly) or ASK (batched for user). Dispatches parallel specialist subagents: voice, banned-words, clickbait, standalone, SEO, title.
- **Cross-episode learnings file** — `knowledge/13-learnings.md`. `/retro-episode` appends patterns for future episodes to use.
- **Root docs** — `ETHOS.md` (content philosophy), `VERSION`, `CHANGELOG.md`, `AGENTS.md` (machine-readable command index).
- **Sprint workflow framing** — Plan → Process → Write → Review → Publish → Retro.

### Changed
- `CLAUDE.md` — replaced ad-hoc "Auto-Detection Rules" with reference to command-level `triggers:` frontmatter. Added Completion Protocol and Three-Strike Rule sections.
- `/produce-shorts` — phase failures now abort per Three-Strike Rule and emit structured BLOCKED outcome instead of continuing with incomplete phases.
- `/review-content` — restructured from 4-pass serial review to parallel specialist dispatch with Fix-First classification.
- `/retro-episode` — now writes patterns into `knowledge/13-learnings.md` so future runs read them automatically.
- `README.md` — added `/plan-episode` to the command list (was missing), added root docs section.
- `setup.sh` — installs `13-learnings.md` template.

## [1.0.0] — 2026-03-14

Initial release — 9 slash commands, 13 knowledge-base templates, one-command setup.
