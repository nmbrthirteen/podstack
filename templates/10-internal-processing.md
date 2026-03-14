# [Your Show Name] — Internal Processing Rules

> For Claude: Execute automatically based on input type. Do not ask unnecessary questions.

---

## Task: Full Transcript Processing

**Trigger:** User provides transcript text or file

**Auto-execute:**
1. Identify guest, company, episode number
2. Scan for 15-20 potential moments
3. Score each moment
4. Select top moments
5. Generate titles, thumbnails, descriptions for each
6. Check `03-episodes-database.md` for duplicates
7. Output in structured format

---

## Task: Title Generation

**Trigger:** User asks for titles or provides a moment

**Auto-execute:**
1. Apply formulas from `05-title-formulas.md`
2. Generate 8 options
3. Run verification checklist
4. Flag top 2 picks

---

## Task: Thumbnail Text

**Trigger:** User asks for thumbnails

**Auto-execute:**
1. Reference `07-thumbnail-guide.md`
2. Two-line format (Line 1 = setup, Line 2 = payoff)
3. Both podcast and shorts versions
4. Max 4-6 words total

---

## Task: Description Writing

**Trigger:** User asks for descriptions

**Auto-execute:**
1. Hook first line (under 100 chars)
2. Guest attribution
3. Full episode link placeholder
4. 3-5 hashtags (show hashtag first)

---

## Task: Quality Check

**Trigger:** Before final output

**Auto-verify:**
1. Brand voice matches `02-voice-and-tone.md`
2. Titles meet spec from `05-title-formulas.md`
3. Descriptions have hooks and hashtags
4. Thumbnails are two-line, readable small
5. No duplicates
6. No banned words

**Fix issues before outputting.**

---

## Task: Episode Database Update

**Trigger:** New episode processed

**Auto-execute:**
1. Add to `03-episodes-database.md`
2. Include guest, company, topic, shorts count

---

## Self-Correction Rules

1. If generic → add specificity from transcript
2. If title over 60 chars → cut words, not meaning
3. If moment needs context → skip it
4. If thumbnail text >6 words → cut ruthlessly
5. If description buries hook → restructure
