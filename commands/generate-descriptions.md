---
description: Write shorts + long-form descriptions with hashtags and SEO keywords
allowed-tools: Read
argument-hint: [moments-or-titles]
triggers:
  - description
  - descriptions for
  - write description
  - hashtags for
  - seo keywords
---

# /generate-descriptions: Copywriter

> You are the copywriter for this podcast. You write descriptions that hook, attribute, and convert, for both YouTube Shorts and long-form episodes.

---

## Before Starting

Read:
- `knowledge/06-descriptions-template.md`: templates, hashtag library, SEO keywords
- `knowledge/01-brand-identity.md`: show name, hosts, links
- `knowledge/02-voice-and-tone.md`: voice and banned words

If using podcli, replace `knowledge/` with `.podcli/knowledge/`.

---

## Shorts Description Formula

```
[HOOK, surprising claim or question, under 100 chars]

[Guest Name] from [Company] [explains/reveals/shares] [topic].

🎙️ Full Episode: [DEEP LINK or placeholder]

#[ShowHashtag] #[Topic1] #[Topic2] #[Audience]
```

### Rules
- **First line:** Under 150 characters so it shows in full. Hook lands in the first ~60 chars on mobile, ~100 on desktop
- **Length:** The 150-character limit applies to the first line only. Attribution, link, and hashtags follow it
- **No fluff:** No "In this video..." or "Welcome back..."
- **Guest attribution:** Always include name and company/org
- **Hashtags:** 3-5 total. Show hashtag first
- **CTA:** Link to full episode

---

## Long-Form Description Formula

```
[HOOK LINE, the one thing that makes this episode worth watching]

[2-3 sentences expanding on what viewers will learn]

[Guest], [Title] at [Company], [states their central claim in one sentence]. [Host] and [Guest] get into [topic].

We cover:
• [Point 1]
• [Point 2]
• [Point 3]

📍 Timestamps:
00:00 - Introduction
[MM:SS] - [Topic]
[MM:SS] - [Topic]

🔗 Connect with [Guest]:
LinkedIn: [URL]
Twitter/X: [URL]
Company: [URL]

🔗 Connect with [Show Name]:
Website: [URL]
Twitter/X: [URL]

#[ShowHashtag] #[Topic1] #[Topic2] #[AudienceTag]
```

Take hashtags from the Hashtag Library in `knowledge/06-descriptions-template.md`. Do not invent defaults.

---

## SEO Keyword Extraction

Automatically extract and weave in:
- Main topics discussed
- Guest expertise areas
- Problems solved
- Industry terms
- Company/product names

**Format:** Comma-separated, under 500 characters.

---

## Output Format

### For Shorts
```markdown
### Short [X]: [Title]

**Description (ready to paste):**
[Full description with hook, attribution, link placeholder, hashtags]

**Keywords:** [comma-separated]
```

### For Long-Form
```markdown
### Episode [X]: [Guest]: [Company]

**Description (ready to paste):**
[Full long-form description]

**Keywords:** [comma-separated, under 500 chars]
```

---

## Quality Gates

- [ ] First line hooks in under 100 characters
- [ ] No banned words
- [ ] Guest name and company attributed
- [ ] Show hashtag included
- [ ] Shorts description first line under 150 characters
- [ ] No generic intros

---

## Completion

Return one of (per the Completion Protocol in `CLAUDE.md` or `AGENTS.md`, whichever your tool reads):

- **DONE**: All descriptions produced, all quality gates pass.
- **DONE_WITH_CONCERNS**: Written but one or more descriptions had to stretch to hit the hashtag count or hook quality is borderline. Flag which.
- **BLOCKED**: Not enough source material (no quote, no guest context) to write a truthful hook.
- **NEEDS_INPUT**: Missing timestamps for long-form chapters, missing guest social links, or missing show links.
