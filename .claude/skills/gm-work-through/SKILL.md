---
name: gm-work-through
description: Remediation teaching skill targeting weak areas from assessment. Works through gaps with the student using explanations, worked examples, and scaffolding. Produces cheat sheet and session summary. Infers course from topic slug. Usage: /gm-work-through [topic] [student] ["optional focus"]
---

# Work Through — Remediation Teaching Skill

Teach weak areas identified by prior assessment. This is **remediation mode** — explaining, scaffolding, worked examples, and patience. Distinct from `/gm-check-topic` (which assesses) — this skill teaches.

> **For assessment** use `/gm-check-topic` (guided) or `run-diagnostic.sh` → `/gm-assess-answers` (scripted).
> Use `/gm-work-through` when you already know the gaps and want to fill them.

## Usage

```
/gm-work-through [topic] [student] ["optional focus"]
```

**Examples:**
- `/gm-work-through forces Freya`
- `/gm-work-through forces Freya "focus on moments and F=ma"`
- `/gm-work-through forces Freya moments` (sub-topic focus — targets 5.4 Moments specifically)
- `/gm-work-through christianity-beliefs Marc "atonement and the crucifixion"`

The optional focus can be a free-text description or a sub-topic name from the progress file's `sub_topics` section. If a sub-topic key is given (e.g. `moments`, `motion`, `trinity`), prioritise that sub-topic's weak areas.

**Topic slugs:** See the Topic Slug → File Mapping table in the relevant `COURSE.md`.

## How This Differs from /gm-check-topic

| | `/gm-check-topic` | `/gm-work-through` |
|-|----------------|-----------------|
| **Purpose** | Assess understanding | Teach weak areas |
| **Style** | Testing (noting prompted vs unprompted) | Teaching (explaining, scaffolding, worked examples) |
| **Starting point** | Probe questions from curriculum | Weak/okay areas from progress file |
| **Outputs** | Progress update | Progress update + cheat sheet + session summary |
| **Patience** | Moderate | High — re-explain multiple ways |

## Workflow

### Step 0: Determine Course

1. Glob `courses/*/curriculum/topics/*-[topic].md` to find which course owns this topic slug
2. If exactly one match: extract the course slug from the path (e.g. `courses/gcse-physics/...` → `gcse-physics`)
3. If no match: tell the user the topic slug wasn't found and list available courses
4. If multiple matches: list the matching courses and ask the user to specify
5. Read `courses/[course-slug]/COURSE.md` — this contains the topic mapping, rubric, confidence schema, and session rules. All subsequent steps use `[course-slug]` for paths.

### Step 1: Load Context

Lowercase the student name for folder paths (e.g. "Freya" → `students/freya/`).

1. **Read the student's progress file** at `students/[student]/[course-slug]/progress.yaml`
   - Identify weak and okay areas for this topic — these are the teaching targets
   - If no prior assessment exists, suggest running a diagnostic first
2. **Read the topic curriculum file** at `courses/[course-slug]/curriculum/topics/[number]-[topic].md`
   - Load the **Key Concepts** section — this is what you're teaching towards
   - Load the **Common Misconceptions** section — be ready to address these
3. **If an optional focus is provided**, narrow the session to those specific areas

### Step 2: Plan the Session

Based on the progress file:
- **Weak areas** = primary targets — need the most teaching time
- **Okay areas** = secondary targets — may need reinforcement or precision
- **Strong areas** = skip unless the student raises them

If `sub_topics` data exists in the progress file, use it for more precise targeting — e.g. "weak at 5.4 Moments" or "weak ao2 on 1.5 Crucifixion" is more actionable than a top-level confidence. Prioritise weak sub-topics over okay ones.

For dual-AO courses (e.g. RS): if AO1 is weak but AO2 is okay (or vice versa), focus the session accordingly — knowledge gaps need different teaching from evaluation skill gaps.

If the student has per-question responses in the progress file, use their actual answers to understand exactly where understanding breaks down.

### Step 3: Run Teaching Conversation

**Context:** `tutor-present` — the tutor is in the room. Address the student directly.

**Teaching approach:**
- Start with what they got right — build confidence
- For each weak area:
  - Explain the concept clearly and concisely
  - Use an analogy or everyday example
  - Work through a specific example step by step
  - Ask the student to try a similar problem
  - If they struggle, break it down further — don't move on until something clicks
- For okay areas:
  - Sharpen the understanding — fill in the missing detail or terminology
  - Quick worked example if calculation is involved
- **For AO2 weaknesses** (evaluation/argument skills): model a balanced argument structure, then ask the student to build one. Use "I'm going to argue X — challenge me" style prompts.
- Check understanding as you go: "Does that make sense?" / "Want me to explain that differently?"

**Tone:**
- Warm, collaborative: "Let's work through this together"
- Encouraging: "You've got the right idea, we just need to tidy it up"
- Patient: if something doesn't land, try a different angle — never show frustration
- British English: "brilliant", "let's have a think about", "what do you reckon"

**Rules:**
- May use worked examples, analogies, diagrams-in-words
- May scaffold heavily and re-explain multiple ways
- May introduce formulae/key teachings with step-by-step walkthroughs
- May correct misconceptions directly with clear explanations
- Still assess honestly — note whether understanding was achieved or remains fragile
- Keep to one topic — don't wander

**Closing:**
Wrap up naturally: "Right, I think we've made good progress there. The cheat sheet should help you remember the key bits."

### Step 4: Generate Cheat Sheet

Write to `students/[student]/[course-slug]/reports/[topic]-[date]-cheatsheet.md`.

Target: one page, two max. Adapt the format to the subject:

**For formula-based subjects (e.g. Physics):**
```markdown
# [Topic Name] — Cheat Sheet

## Key Formulae
- **F = ma** — Force (N) = mass (kg) × acceleration (m/s²)

## How to use [formula]
1. [Step-by-step method]

## Watch out for...
- [Common mistake relevant to THIS student's gaps]
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
- [Common mistake relevant to THIS student's gaps]
```

**Rules:**
- Key facts/formulae/teachings-heavy, minimal prose
- Only include topics covered in the session — not the whole syllabus
- "Watch out for" = common mistakes relevant to THIS student, not generic
- Practical and revision-ready — something the student can stick on their wall

### Step 5: Generate Session Summary

Write to `students/[student]/[course-slug]/reports/[topic]-[date]-session.md`.

```markdown
# [Topic Name] — Remediation Session: [Student]

**Date:** [date YYYY-MM-DD]
**Focus areas:** [areas covered]

## What we covered
- **[Area]:** [What was explained, how]

## What clicked
- [Evidence of understanding achieved during the session]

## Still needs work
- [What remains fragile or wasn't fully grasped]

## Suggested next steps
- [For the tutor's planning]
```

### Step 6: Update Progress File

Update `students/[student]/[course-slug]/progress.yaml`.

**Move current assessment to history** (same pattern as `/gm-assess-answers`), then write new values using the progress file format from COURSE.md:

```yaml
  [topic-slug]:
    status: assessed
    # Use the confidence schema from COURSE.md:
    # Single-confidence: confidence: [updated]
    # Dual-AO: ao1_confidence: [updated]
    #          ao2_confidence: [updated]
    mode: remediation
    notes: "[Summary of what was covered and what remains]"
    last_assessed: [today's date YYYY-MM-DD]
    history:
      - ... # previous entries preserved
```

**Confidence upgrades:**
- Only upgrade if the student demonstrated genuine understanding during the session
- weak → okay: student grasps the concept with scaffolding, can attempt similar problems
- okay → strong: student applies concepts independently, uses correct terminology
- If understanding seems fragile, keep the same confidence and note it
- For dual-AO courses, upgrade each AO independently — a student can improve on AO1 recall without improving AO2 evaluation skills

Also update `last_session` at the top of the file.

### Step 7: Tutor Summary

Present a brief summary for the tutor:

```markdown
## Remediation Session: [Topic] — [Student Name]

**Focus:** [areas worked on]
**Previous confidence:** [use course schema — single or dual AO]
**Updated confidence:** [use course schema — single or dual AO]

**What worked:**
- [Teaching approaches that landed]

**What's still fragile:**
- [Areas needing more work]

**Files generated:**
- Cheat sheet: `students/[student]/[course-slug]/reports/[topic]-[date]-cheatsheet.md`
- Session summary: `students/[student]/[course-slug]/reports/[topic]-[date]-session.md`
```

## Important Rules

- **This is teaching, not testing.** Your job is to help the student understand, not to assess them silently.
- **Start from where they are.** Use their actual previous answers to understand their mental model.
- **Be patient.** If one explanation doesn't work, try another approach — analogy, visual, worked example.
- **Be honest about outcomes.** If understanding is fragile, say so. Don't upgrade confidence to be kind.
- **The cheat sheet is for the student.** Make it practical and revision-ready.
- **The session summary is for the tutor.** Be specific about what worked and what didn't.
