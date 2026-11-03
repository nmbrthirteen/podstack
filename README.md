# PodStack

> One repo, one install, entire podcast content workflow. It works with Claude Code, OpenAI Codex, Cursor, opencode, or any AI tool that reads markdown.

PodStack turns your AI coding tool into a full podcast content team using structured skill files. It gives you an Episode Architect, Content Analyst, Title Writer, Copywriter, Art Director, Brand Guardian, Producer, Launch Manager, and Performance Analyst, all driven from your terminal or editor.

Built for podcasters who use [podcli](https://github.com/nmbrthirteen/podcli) but works standalone with any project.

Inspired by [gstack](https://github.com/garrytan/gstack) by Garry Tan.

---

## What You Get

| Command | Role | What It Does |
|---------|------|-------------|
| `/plan-episode` | Episode Architect | Designs questions, story arc, moment map BEFORE recording |
| `/process-transcript` | Content Analyst | Ingests transcript → extracts best moments → scores → categorizes |
| `/generate-titles` | Title Writer | Generates 8 title options with full verification checklist |
| `/generate-descriptions` | Copywriter | Creates descriptions + hashtags + SEO keywords |
| `/plan-thumbnails` | Art Director | Plans thumbnail text + layout briefs for your designer |
| `/review-content` | Brand Guardian | Fix-First review: auto-fixes + parallel specialist dispatch |
| `/produce-shorts` | Producer | Full pipeline: transcript → publish-ready package |
| `/publish-checklist` | Launch Manager | Pre/post-publish optimization checklist |
| `/retro-episode` | Analyst | Episode performance review + appends patterns to `knowledge/13-learnings.md` |

---

## Host Compatibility

PodStack ships one source-of-truth in `commands/` and installs to the right location for whichever tool you use:

| Host | Install location | Primary instruction doc |
|------|-----------------|------------------------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (default) | `.claude/commands/*.md` | `CLAUDE.md` |
| [OpenAI Codex](https://github.com/openai/codex) | `.codex/prompts/*.md` | `AGENTS.md` |
| [Cursor](https://cursor.com) | `.cursor/rules/*.mdc` | `AGENTS.md` |
| [opencode](https://opencode.ai) | `.opencode/commands/*.md` | `AGENTS.md` |
| Generic (anything else) | `commands/*.md` | `AGENTS.md` |

`setup.sh` auto-detects your tool based on existing `.claude/`, `.codex/`, `.cursor/`, or `.opencode/` folders. Override with `--host`.

---

## Install

### Quick install (auto-detects your tool)

Clone PodStack into your project as `.podstack`, then run its installer from the project root:

```bash
git clone https://github.com/nmbrthirteen/podstack.git .podstack
.podstack/setup.sh
```

The installer picks the host from existing `.claude/`, `.codex/`, `.cursor/`, or `.opencode/` folders and defaults to Claude Code. In a [podcli](https://github.com/nmbrthirteen/podcli) project (a `.podcli/` folder exists) it puts the knowledge base in `.podcli/knowledge/`.

Running `setup.sh` from inside a clone named `.podstack` installs into the parent folder. Any other clone location needs the project path: `setup.sh <project-dir>`.

### Explicit host

```bash
# For Claude Code
.podstack/setup.sh --host claude-code

# For OpenAI Codex
.podstack/setup.sh --host codex

# For Cursor (converts .md → .mdc rules)
.podstack/setup.sh --host cursor

# For opencode
.podstack/setup.sh --host opencode

# For any other tool (copies to project-root commands/ + AGENTS.md)
.podstack/setup.sh --host generic
```

### Update

```bash
git -C .podstack pull
.podstack/setup.sh --update
```

`--update` overwrites the commands PodStack installed. It records them in a `.podstack-manifest` file in the commands folder. If you edited an installed command, `--update` saves your version as `<file>.bak` first. Without `--update`, existing files are skipped.

### Shared clone for several projects

```bash
git clone https://github.com/nmbrthirteen/podstack.git ~/.podstack
cd ~/my-podcast && ~/.podstack/setup.sh
```

Each project gets its own copy of the commands. Run `setup.sh` once per project.

---

## Usage by Host

### Claude Code

```
/plan-episode
/produce-shorts
/retro-episode
```

Commands appear in `/help`. Claude reads `CLAUDE.md` automatically.

### OpenAI Codex

Codex reads `AGENTS.md` at project root on startup. Invoke skills by reference:

```
Run the produce-shorts playbook on transcripts/ep42.txt
Use the generate-titles skill for this clip: [paste]
```

Codex loads the referenced file from `.codex/prompts/` and follows it.

### Cursor

Rules live in `.cursor/rules/*.mdc`. Invoke in chat:

```
Use the produce-shorts rule on this transcript
Apply the review-content rule to the content package at episodes/ep42.md
```

Cursor matches rules by description.

### opencode

Commands work like Claude Code slash commands:

```
/plan-episode
/produce-shorts
```

### Generic tool

Point your AI at `AGENTS.md` and reference skills by path:

```
Follow the instructions in commands/produce-shorts.md using this transcript: [paste]
```

---

## Quick Start

### 1. Set up your brand

Edit the knowledge base files in `knowledge/` (or `.podcli/knowledge/` if using podcli):

```
knowledge/
├── 00-master-instructions.md    ← Your show's AI operating system
├── 01-brand-identity.md         ← Who you are, positioning, hosts
├── 02-voice-and-tone.md         ← How you sound, banned words
├── 03-episodes-database.md      ← Track episodes and existing shorts
├── 04-shorts-creation-guide.md  ← Moment selection criteria
├── 05-title-formulas.md         ← Your title patterns and rules
├── 06-descriptions-template.md  ← Description templates + hashtags
├── 07-thumbnail-guide.md        ← Visual specs for your brand
├── 08-topics-themes.md          ← Your content categories
├── 09-content-workflow.md       ← End-to-end workflow
├── 10-internal-processing.md    ← Internal rules for your AI
├── 11-inspiration-channels.md   ← Reference channels you admire
├── 12-quick-reference.md        ← Copy-paste resources
└── 13-learnings.md              ← Cross-episode learnings (auto-updated by /retro-episode)
```

Each file ships as a starter template with examples. Fill them in with your show's specifics.

### 2. Process your first episode

```
/produce-shorts
```

Paste your transcript or point to a file. PodStack runs the full pipeline and delivers a publish-ready content package.

### 3. Or use individual commands

```
/process-transcript     ← Just extract moments from a transcript
/generate-titles        ← Just get title options for a specific clip
/review-content         ← Just review existing content for quality
```

---

## The Pipeline (Sprint Workflow)

```
Plan → Process → Write → Review → Publish → Retro
```

```
/plan-episode  →  [record]  →  /process-transcript  →  /generate-titles  →  /generate-descriptions
                                                                                    ↓
             /retro-episode  ←  [published]  ←  /publish-checklist  ←  /review-content  ←  /plan-thumbnails
```

Or run everything at once: **`/produce-shorts`**

After publishing: **`/retro-episode`** also appends cross-episode learnings so future runs get smarter.

---

## How It Works

PodStack skills are plain markdown files with YAML frontmatter. Each one shifts your AI into a specialized role. Every skill includes:

- **Frontmatter**: `description`, `allowed-tools`, `argument-hint`, `triggers`. Claude Code reads `description`, so put trigger phrases there. `triggers` is guidance for people and for tools that read it; Claude Code ignores that key
- **A clear role**: what the agent is acting as (analyst, writer, reviewer)
- **An execution protocol**: step-by-step instructions
- **Quality gates**: checks that must pass before output
- **Output format**: structured, consistent deliverables
- **Completion Protocol**: every skill returns `DONE`, `DONE_WITH_CONCERNS`, `BLOCKED`, or `NEEDS_INPUT` with evidence
- **Three-Strike Rule**: orchestrators abort after 3 consecutive phase failures instead of looping
- **Reference file pointers**: links to your knowledge base for detailed specs

The knowledge base files are your show's "brand brain". They contain your voice, style, title formulas, banned words, and everything needed to produce content that sounds like *you*, not generic AI.

`/review-content` also uses **Fix-First** with parallel specialist dispatch. It auto-applies mechanical fixes (banned words, hashtag dedup, casing) and batches human-decision items into one question.

---

## Customization

### Add your own skills

Create any `.md` file in `commands/` (or your host's command folder) with the frontmatter format:

```markdown
---
description: What the skill does. Use when the user says phrase 1 or phrase 2.
allowed-tools: Read, Write
argument-hint: [what the user types]
triggers:
  - natural language phrase 1
  - natural language phrase 2
---

# /my-custom-skill: My Role

> Instructions for the agent...

## Execution Protocol
...

## Completion
Return DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_INPUT per CLAUDE.md or AGENTS.md.
```

If you add the file to the PodStack clone's `commands/`, run `.podstack/setup.sh` to install it for your host. A file placed directly in your host's command folder works as is. `--update` never touches files PodStack did not install.

### Modify existing skills

All skills are plain markdown. Edit them to match your workflow. Common customizations:

- Change the number of title options (default: 8)
- Add your own quality gates
- Add new specialists to `/review-content`
- Modify output formats
- Add new content types beyond the default five

### podcli integration

When the podcli MCP server is connected, `/process-transcript` and `/produce-shorts` use its tools. Without it they work from text files.

- `transcribe_podcast`: transcribes an audio or video file when you have no transcript
- `suggest_clips`: adds AI-suggested moments to the candidate pool
- `clip_history`: checks which clips already exist, to avoid duplicates
- `knowledge_base`: reads your brand files when they are not on disk
- `create_clip`: renders approved moments with captions at the end of `/produce-shorts`

---

## Project Structure

```
podstack/
├── README.md                    ← You are here
├── CLAUDE.md                    ← Claude Code-specific primary doc
├── AGENTS.md                    ← Host-agnostic primary doc (Codex, Cursor, opencode, generic)
├── ETHOS.md                     ← Content philosophy (the why behind every rule)
├── CHANGELOG.md                 ← Release history
├── VERSION                      ← Current version
├── LICENSE
├── setup.sh                     ← Host-detecting installer (--host, --update)
├── scripts/
│   ├── sync-to-podcli.sh        ← Sync commands and templates into a podcli project
│   └── manifest.sh              ← Shared helpers: install manifest and checksums
├── commands/                    ← Skill files (with YAML frontmatter), source of truth
│   ├── plan-episode.md
│   ├── process-transcript.md
│   ├── generate-titles.md
│   ├── generate-descriptions.md
│   ├── plan-thumbnails.md
│   ├── review-content.md
│   ├── produce-shorts.md
│   ├── publish-checklist.md
│   └── retro-episode.md
└── templates/                   ← Starter knowledge base files
    ├── 00-master-instructions.md
    ├── 01-brand-identity.md
    ├── 02-voice-and-tone.md
    ├── 03-episodes-database.md
    ├── 04-shorts-creation-guide.md
    ├── 05-title-formulas.md
    ├── 06-descriptions-template.md
    ├── 07-thumbnail-guide.md
    ├── 08-topics-themes.md
    ├── 09-content-workflow.md
    ├── 10-internal-processing.md
    ├── 11-inspiration-channels.md
    ├── 12-quick-reference.md
    └── 13-learnings.md
```

---

## Requirements

- One of: [Claude Code](https://docs.anthropic.com/en/docs/claude-code), [OpenAI Codex](https://github.com/openai/codex), [Cursor](https://cursor.com), [opencode](https://opencode.ai), or any AI tool that reads markdown
- Optional: [podcli](https://github.com/nmbrthirteen/podcli) for video processing

---

## License

MIT
