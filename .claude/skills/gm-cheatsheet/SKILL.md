---
name: gm-cheatsheet
description: Generate a standalone cheat sheet for a student based on their weak and okay areas. Reads progress data and curriculum to produce a targeted, revision-ready reference. Infers course from topic slug. Usage: /gm-cheatsheet [student] [topic] [date]
---

# Cheat Sheet — Standalone Generation Skill

Generate a targeted cheat sheet from a student's progress data without running a full remediation session. Useful after a diagnostic or guided session, or to regenerate a cheat sheet with updated content.

> **For teaching** use `/gm-work-through` (which also generates a cheat sheet as part of the session).
> Use `/gm-cheatsheet` when you already have assessment data and just want the revision sheet.

## Usage

```
/gm-cheatsheet [student] [topic] [date]
```

All arguments are optional — the skill discovers what's available when args are missing.

**Examples:**
- `/gm-cheatsheet` (lists students with assessed topics)
- `/gm-cheatsheet Freya` (lists Freya's assessed topics across all courses)
- `/gm-cheatsheet Freya theme-b-religion-and-life` (generates cheat sheet using most recent assessment)
- `/gm-cheatsheet Freya forces 2026-02-08` (generates cheat sheet for a specific assessment date)

**Topic slugs:** See the Topic Slug → File Mapping table in the relevant `COURSE.md`.

## Workflow

### Step 0: Resolve Parameters

**If no arguments provided** (`/gm-cheatsheet`):

1. List student directories with `ls students/` (don't use Glob — student folders may be symlinks which Glob doesn't follow). For each student, list their course directories and read any `progress.yaml` files found.
2. For each progress file, read it and list topics with `status: assessed` or `status: partially_assessed`
3. Display a summary:

```markdown
## Students with Assessed Topics

| Student | Course | Topic | Confidence | Last Assessed |
|---------|--------|-------|------------|---------------|
| Freya | gcse-rs | theme-b-religion-and-life | AO1: okay, AO2: weak | 2026-02-15 |
| Marc | gcse-physics | forces | okay | 2026-02-08 |

Run: `/gm-cheatsheet [student] [topic]` to generate a cheat sheet.
```

If no assessed topics exist, say so: "No assessed topics found. Run a diagnostic or guided session first."

Then stop — don't proceed to generation.

**If student only** (`/gm-cheatsheet Freya`):

1. Lowercase the student name for folder paths (e.g. "Freya" → `students/freya/`)
2. List course directories with `ls students/[student]/` (don't use Glob — student folders may be symlinks). Read `progress.yaml` from each course directory found.
3. For each progress file, read it and list assessed topics with confidence levels and last assessed dates
4. Read each course's `COURSE.md` to get proper course and topic names
5. Display a summary:

```markdown
## Assessed Topics for [Student]

| Course | Topic | Confidence | Last Assessed |
|--------|-------|------------|---------------|
| GCSE RS | theme-b-religion-and-life | AO1: okay, AO2: weak | 2026-02-15 |
| GCSE RS | christianity-beliefs | AO1: strong, AO2: okay | 2026-02-09 |

Run: `/gm-cheatsheet [student] [topic]` to generate a cheat sheet.
```

Then stop — don't proceed to generation.

**If student + topic** (with or without date):

1. Glob `courses/*/curriculum/topics/*-[topic].md` to find which course owns this topic slug
2. If exactly one match: extract the course slug from the path (e.g. `courses/gcse-rs/...` → `gcse-rs`)
3. If no match: tell the user the topic slug wasn't found and list available courses
4. If multiple matches: list the matching courses and ask the user to specify
5. Read `courses/[course-slug]/COURSE.md` — this contains the topic mapping, rubric, confidence schema, and subject type. All subsequent steps use `[course-slug]` for paths.
6. If no date provided: use `last_assessed` from the topic entry in the progress file
7. If date provided: use that specific date

### Step 1: Load Context

Lowercase the student name for folder paths (e.g. "Freya" → `students/freya/`).

1. **Read the student's progress file** at `students/[student]/[course-slug]/progress.yaml`
   - Find the topic entry — check it has been assessed (`status: assessed` or `status: partially_assessed`)
   - If the topic hasn't been assessed, suggest running a diagnostic or guided session first and stop
   - Identify weak and okay areas — these are the cheat sheet targets
   - If `sub_topics` data exists, use it for more precise targeting
   - If `responses` data exists, note specific misconceptions from the student's actual answers
2. **Read the topic curriculum file** at `courses/[course-slug]/curriculum/topics/[number]-[topic].md`
   - Load the **Key Concepts** section — source material for the cheat sheet
   - Load the **Common Misconceptions** section — feeds the "Watch out for" section

### Step 2: Generate Cheat Sheet

Write to `students/[student]/[course-slug]/reports/[topic]-[date]-cheatsheet.md`.

Target: one page, two max. Adapt the format to the subject type (determined by COURSE.md):

**For formula-based subjects (e.g. Physics):**
```markdown
# [Topic Name] — Cheat Sheet

## Key Formulae
- **F = ma** — Force (N) = mass (kg) × acceleration (m/s²)

## How to use [formula]
1. [Step-by-step method]

## Key Facts
- [Important facts relevant to weak/okay areas]

## Watch out for...
- [Common mistake relevant to THIS student's gaps, drawn from progress notes]
```

**For essay-based subjects (e.g. RS):**
```markdown
# [Topic Name] — Cheat Sheet

## Key Teachings
- **Christianity:** [teaching + scripture reference]
- **Islam:** [teaching + source reference]

## Argument Structure (12-mark questions)
1. Arguments FOR with evidence
2. Arguments AGAINST with evidence
3. Your justified conclusion

## Watch out for...
- [Common mistake relevant to THIS student's gaps, drawn from progress notes]
```

**Rules:**
- Key facts/formulae/teachings-heavy, minimal prose
- Only covers weak and okay areas — not strong ones
- "Watch out for" = common mistakes relevant to THIS student, not generic. Use their actual misconceptions from progress notes and response data where available
- Practical and revision-ready — something the student can stick on their wall

### Step 3: Present Summary

Display a summary for the tutor:

```markdown
## Cheat Sheet Generated: [Topic] — [Student Name]

**Date:** [date]
**Based on:** [mode] assessment from [last_assessed date]
**Confidence:** [use course schema — single or dual AO]

**Areas covered:**
- [List of weak/okay areas included in the cheat sheet]

**Areas excluded (strong):**
- [List of strong areas not included, if any]

**File:** `students/[student]/[course-slug]/reports/[topic]-[date]-cheatsheet.md`
```

## Important Rules

- **This is a generation tool, not a teaching tool.** No conversation with the student — just produce the cheat sheet.
- **Only cover weak and okay areas.** Strong areas don't need revision support.
- **Use the student's actual misconceptions.** Generic "watch out for" advice is less useful than referencing what THIS student actually got wrong.
- **Keep it concise.** One page ideal, two max. Dense with facts, light on prose.
- **Match the subject type.** Formula-based and essay-based subjects need different cheat sheet structures.
- **Overwrite existing cheat sheets.** If a cheat sheet already exists at the same path (e.g. from a work-through session), overwrite it — the new one uses the latest progress data.
