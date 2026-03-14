# PodStack

> One repo, one install, entire podcast content workflow — powered by Claude Code.

PodStack transforms [Claude Code](https://docs.anthropic.com/en/docs/claude-code) into a full podcast content team using slash commands. It gives you a Content Analyst, Title Writer, Copywriter, Art Director, Brand Guardian, Producer, Launch Manager, and Performance Analyst — all running inside your terminal.

Built for podcasters who use [podcli](https://github.com/nmbrthirteen/podcli) but works standalone with any Claude Code project.

Inspired by [gstack](https://github.com/garrytan/gstack) by Garry Tan.

---

## What You Get

| Command | Role | What It Does |
|---------|------|-------------|
| `/process-transcript` | Content Analyst | Ingests transcript → extracts best moments → scores → categorizes |
| `/generate-titles` | Title Writer | Generates 8 title options with full verification checklist |
| `/generate-descriptions` | Copywriter | Creates descriptions + hashtags + SEO keywords |
| `/plan-thumbnails` | Art Director | Plans thumbnail text + layout briefs for your designer |
| `/review-content` | Brand Guardian | Reviews output against your brand voice + quality gates |
| `/prep-episode` | Producer | Full pipeline: transcript → publish-ready package |
| `/publish-checklist` | Launch Manager | Pre/post-publish optimization checklist |
| `/retro-episode` | Analyst | Episode performance review + learnings |

---

## Install

### Option 1: With podcli (recommended)

If you already use [podcli](https://github.com/deeprise-ai/podcli):

```bash
# From your podcli project directory
npx podstack init
```

This installs slash commands into `.claude/commands/` and generates starter knowledge base templates in `.podcli/knowledge/`.

### Option 2: Standalone (any Claude Code project)

```bash
# Clone into your project
git clone https://github.com/nmbrthirteen/podstack.git .podstack

# Run setup
.podstack/setup.sh
```

Or manually:

```bash
# Copy slash commands
cp -r .podstack/commands/ .claude/commands/

# Copy starter knowledge base templates
cp -r .podstack/templates/ knowledge/

# Copy CLAUDE.md (or merge with your existing one)
cp .podstack/CLAUDE.md ./CLAUDE.md
```

### Option 3: Global install

```bash
# Install globally so it's available in any project
git clone https://github.com/nmbrthirteen/podstack.git ~/.podstack
```

Then from any project: `~/.podstack/setup.sh`

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
├── 10-internal-processing.md    ← Internal rules for Claude
├── 11-inspiration-channels.md   ← Reference channels you admire
└── 12-quick-reference.md        ← Copy-paste resources
```

Each file has starter templates with examples. Fill them in with your show's specifics.

### 2. Process your first episode

```
/prep-episode
```

Paste your transcript or point to a file. PodStack runs the full pipeline and delivers a publish-ready content package.

### 3. Or use individual commands

```
/process-transcript     ← Just extract moments from a transcript
/generate-titles        ← Just get title options for a specific clip
/review-content         ← Just review existing content for quality
```

---

## The Pipeline

```
/process-transcript  →  /generate-titles  →  /generate-descriptions  →  /plan-thumbnails  →  /review-content  →  /publish-checklist
         ↑                                                                                                              ↓
   Raw transcript                                                                                               Published content
```

Or run everything at once: **`/prep-episode`**

After publishing, analyze performance: **`/retro-episode`**

---

## How It Works

PodStack is a collection of **slash commands** (`.claude/commands/` markdown files) that shift Claude Code into specialized roles. Each command includes:

- **A clear role** — what Claude is acting as (analyst, writer, reviewer)
- **An execution protocol** — step-by-step instructions
- **Quality gates** — checks that must pass before output
- **Output format** — structured, consistent deliverables
- **Reference file pointers** — links to your knowledge base for detailed specs

The knowledge base files are your show's "brand brain" — they contain your voice, style, title formulas, banned words, and everything Claude needs to produce content that sounds like *you*, not generic AI.

---

## Customization

### Add your own commands

Create any `.md` file in `.claude/commands/` and it becomes a slash command:

```markdown
# /my-custom-command — My Role

> Instructions for Claude...

## Trigger
When to run this command...

## Execution Protocol
Step-by-step instructions...
```

### Modify existing commands

All commands are plain markdown. Edit them to match your workflow. Common customizations:

- Change the number of title options (default: 8)
- Add your own quality gates
- Modify output formats
- Add new content types beyond the default five

### podcli integration

When installed with podcli, slash commands automatically have access to:

- `transcribe_podcast` — Whisper transcription with speaker detection
- `suggest_clips` — AI-powered moment extraction
- `create_clip` — Render clips with captions and smart cropping
- `knowledge_base` — Read/write your brand files
- `clip_history` — Track what's been generated

---

## Project Structure

```
podstack/
├── README.md                 ← You are here
├── setup.sh                  ← One-command installer
├── CLAUDE.md                 ← Master config (copied to your project)
├── commands/                 ← Slash command skills
│   ├── process-transcript.md
│   ├── generate-titles.md
│   ├── generate-descriptions.md
│   ├── plan-thumbnails.md
│   ├── review-content.md
│   ├── prep-episode.md
│   ├── publish-checklist.md
│   └── retro-episode.md
└── templates/                ← Starter knowledge base files
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
    └── 12-quick-reference.md
```

---

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (Anthropic CLI)
- Optional: [podcli](https://github.com/nmbrthirteen/podcli) for video processing

---

## License

MIT
