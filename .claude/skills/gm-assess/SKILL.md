---
name: gm-assess
description: Assess student answers captured by the diagnostic shell script. Reads raw answers and the full curriculum, grades each response, and writes results to the student's progress file. Infers course from topic slug. Usage: /gm-assess [student-name] [topic-slug] [date]
---

# Assess Answers — Post-Diagnostic Assessment Skill

Assess a student's raw answers (captured by `run-diagnostic.sh`) against the curriculum marking criteria. This is where all the intelligence lives — you have full access to the answer key, misconception lists, and marking criteria.

## Usage

```
/gm-assess [student-name] [topic-slug] [date] ["optional tutor comment"]
```

**Examples:**
- `/gm-assess` (lists all unassessed responses across all students and courses)
- `/gm-assess Freya` (lists unassessed responses for Freya)
- `/gm-assess Freya forces 2026-02-02`
- `/gm-assess Freya christianity-beliefs 2026-02-09`
- `/gm-assess Freya energy` (uses most recent file if date omitted)
- `/gm-assess Freya forces 2026-02-08 "seemed hesitant on calculations"`

## Workflow

### Step 0: Resolve Parameters and Course

**If no topic is provided** (just `/gm-assess` or `/gm-assess [student]`):

1. Find response YAML files across all courses. Use `ls` to discover student and course directories (don't use Glob for `students/` paths — student folders may be symlinks which Glob doesn't follow), then read `responses/*.yaml` from each:
   - No student: list `students/`, then each student's course dirs, then their response files
   - Student given: list `students/[student]/*/responses/*.yaml` via `ls`
2. Read each file and check `assessed: false`
3. Display a summary:

```markdown
## Unassessed Responses

| Student | Topic | Course | Date | File |
|---------|-------|--------|------|------|
| Freya | forces | gcse-physics | 2026-02-08 | students/freya/gcse-physics/responses/forces-2026-02-08.yaml |
| Marc | christianity-beliefs | gcse-rs | 2026-02-09 | students/marc/gcse-rs/responses/christianity-beliefs-2026-02-09.yaml |

Run: `/gm-assess [student] [topic] [date]` to assess one.
```

If no unassessed responses exist, say so: "All responses have been assessed. Nothing to do."

Then stop — don't proceed to assessment.

**If a topic is provided**, determine the course:

1. Glob `courses/*/curriculum/topics/*-[topic].md` to find which course owns this topic slug
2. If exactly one match: extract the course slug from the path (e.g. `courses/gcse-physics/...` → `gcse-physics`)
3. If no match: tell the user the topic slug wasn't found and list available courses
4. If multiple matches: list the matching courses and ask the user to specify
5. Read `courses/[course-slug]/COURSE.md` — this contains the topic mapping, rubric, confidence schema, exam structure, and progress file format. All subsequent steps use `[course-slug]` for paths.

### Step 1: Load Files

Lowercase the student name for folder paths (e.g. "Freya" → `students/freya/`).

1. **Read the raw response file** at `students/[student]/[course-slug]/responses/[topic]-[date].yaml`
   - If no date given, find the most recent file matching `students/[student]/[course-slug]/responses/[topic]-*.yaml`
   - Confirm `assessed: false` — don't re-assess unless the tutor asks
2. **Read the topic curriculum file** at `courses/[course-slug]/curriculum/topics/[number]-[topic].md`
   - Load the **Diagnostic Script** section — match each Q number to its "Looking for" criteria
   - Load the **Common Misconceptions** section — check if any student answers match known misconceptions
3. **Read the student's progress file** at `students/[student]/[course-slug]/progress.yaml`
   - Check for prior assessments on this topic for context

### Step 2: Assess Each Answer

For each question in the response file (Q1 through QN — the number varies by course and topic; count the questions in the curriculum file), compare the student's answer against the "Looking for" criteria:

**Per-question assessment:**

| Level | Criteria |
|-------|----------|
| **strong** | Answer covers the key points without prompting. Uses correct terminology. May go beyond what's expected. |
| **okay** | Partially correct. Gets the main idea but misses important details, uses imprecise language, or only covers part of the concept. |
| **weak** | Wrong, significantly incomplete, contains misconceptions, or student gave no answer. |

**Write specific notes for each question.** Examples:
- "Correctly identified GPE store but called it 'height energy' — terminology gap, concept understood"
- "Said current gets used up — classic misconception (see Common Misconceptions #1)"
- "Names heaven and hell but no development — needs to explain significance, not just list"
- "No answer given — topic may not have been covered in class yet"

**Check for misconceptions:** Cross-reference each answer against the Common Misconceptions list in the curriculum file. If a student's answer matches a known misconception, flag it explicitly — these are high-value findings for the tutor.

**AO tagging:** When the Sub-topic Coverage table in the curriculum file includes an AO column, tag each question assessment with its AO (AO1 or AO2). This is used in Step 3 to determine per-AO confidence.

### Step 3: Determine Overall Confidence

Based on all answers, assign overall confidence. **Read COURSE.md to determine the confidence schema:**

- **Single confidence** (e.g. Physics): Assign one `confidence` level based on all answers.
- **Dual AO confidence** (e.g. RS): Assign `ao1_confidence` based on AO1-tagged questions and `ao2_confidence` based on AO2-tagged questions separately.

| Overall | Rule of thumb |
|---------|--------------|
| **strong** | 4+ questions assessed as strong, no weak answers |
| **okay** | Mix of strong and okay, or mostly okay, max 1 weak |
| **weak** | 2+ weak answers, or fundamental misconceptions present |

For dual-AO courses, apply these rules independently to the AO1 and AO2 question sets.

### Step 4: Update Progress File

Update `students/[student]/[course-slug]/progress.yaml`.

**If the topic has an existing assessment**, move the current values to the `history` array before overwriting:

```yaml
    history:
      - date: [previous last_assessed]
        mode: [previous mode]
        # confidence fields match the course schema
        notes: "[previous notes]"
```

Then write the new assessment. **Use the progress file format defined in COURSE.md** — this determines which confidence fields to use:

```yaml
  [topic-slug]:
    status: assessed
    # Single-confidence courses (e.g. Physics):
    #   confidence: [strong|okay|weak]
    # Dual-AO courses (e.g. RS):
    #   ao1_confidence: [strong|okay|weak]
    #   ao2_confidence: [strong|okay|weak]
    mode: diagnostic
    notes: "[Overall summary — 1-2 sentences on strengths and gaps]"
    last_assessed: [date from response file]
    history:
      - ...  # any previous entries preserved
    sub_topics:
      "[section]_[slug]":
        # Same confidence fields as the course schema
        notes: "[observation for this sub-topic]"
    responses:
      Q1:
        question: "[from response file]"
        answer: "[from response file]"
        assessment: [strong|okay|weak]
        ao: [AO1|AO2]          # only if COURSE.md defines AO columns
        notes: "[your assessment notes]"
      Q2:
        ...
```

**Building sub_topics:** After grading all questions, use the **Sub-topic Coverage** table in the curriculum file to aggregate results by sub-topic. Each question maps to a curriculum section. If multiple questions map to the same sub-topic, combine the assessments (weakest answer determines the sub-topic confidence). The sub-topic key format is `[section]_[short_slug]` — e.g. `5.1_forces_interactions`, `1.2_trinity`.

Also update `last_session` at the top of the file.

### Step 5: Mark Response File as Assessed

Update the raw response file to set `assessed: true` so it doesn't get re-assessed accidentally.

### Step 5.5: Generate Reports

Create three report files in `students/[student]/[course-slug]/reports/`. Create the reports directory if it doesn't exist.

**1. Student review** (`[topic]-[date]-student.md`)

```markdown
# [Topic Name] — What You Showed

**Date:** [date formatted as D Month YYYY]

## What you did well
- [Specific praise with evidence from their answers]
- [Another strength]

## What to focus on next
- [Concrete, actionable next steps — no jargon]
- [Another focus area]

## Key things to remember
- [1-2 key facts/formulae/teachings relevant to their weak areas]
```

Rules: Encouraging, specific, no scores/grades. British English, warm tone.

**2. Tutor brief** (`[topic]-[date]-tutor.md`)

```markdown
# [Topic Name] — Tutor Brief: [Student]

**Date:** [date YYYY-MM-DD]
**Mode:** diagnostic
**Overall confidence:** [use course schema — single or dual AO]
**Tutor observation:** "[tutor comment if provided, or omit this line]"

## Per-Question Breakdown

| Q | Area | Confidence | Observation |
|---|------|-----------|-------------|
| 1 | [area ref] | [strong/okay/weak] | [one-line observation] |
...

## Misconceptions Detected
- [Mapped to Common Misconceptions list in curriculum]

## Gap Analysis
- [Specific curriculum subsections where understanding is missing]

## Recommended Focus for Next Session
1. [Priority area with specific curriculum subsection reference]
2. [Second priority]
```

**3. Parent update** (`[topic]-[date]-parent.md`)

```markdown
# [Subject Name] Progress Update — [Student]

**Topic:** [Topic Name]
**Date:** [date formatted as D Month YYYY]

## What [Student] demonstrated well
- [Jargon-free, positive framing]

## Areas for development
- [Accessible language, practical suggestions]

## How you can help at home
- [Concrete, supportive suggestions]
```

Use the subject name from the `## Subject` section of COURSE.md (e.g. "GCSE Physics" or "GCSE Religious Studies").

Rules: Standalone report. Jargon-free, positive, practical.

### Step 6: Present Results to Tutor

Display a clear summary for the tutor. This is interactive — the tutor may want to discuss or drill into specific answers.

```markdown
## Assessment: [Topic Name] — [Student Name]
**Date:** [date]
**Overall confidence:** [use course schema — single or dual AO]

### Per-question breakdown

| Q | Area | Grade | Key observation |
|---|------|-------|-----------------|
| 1 | [area from curriculum] | strong/okay/weak | [one-line note] |
| 2 | ... | ... | ... |
...

### Misconceptions detected
- [Any answers matching the Common Misconceptions list, with the misconception named]

### Strengths
- [What the student clearly understands]

### Priority gaps for teaching
- [Specific areas the tutor should focus on, ranked by importance]

### Reports generated
- Student review: `students/[student]/[course-slug]/reports/[topic]-[date]-student.md`
- Tutor brief: `students/[student]/[course-slug]/reports/[topic]-[date]-tutor.md`
- Parent update: `students/[student]/[course-slug]/reports/[topic]-[date]-parent.md`

### Raw answers
[Show all questions with the student's actual words for the tutor to review]
```

**After presenting results**, invite the tutor to discuss:
- "Want me to dig into any of these answers in more detail?"
- "Anything you'd adjust in the assessment based on what you know about this student?"

The tutor may override your assessment based on context you don't have (e.g., "they only started this topic last week, so weak on Q5 is expected"). Update the progress file if asked.

## Important Rules

- **Be generous but honest.** A partially correct answer with the right instinct is "okay", not "weak". But don't inflate — misconceptions are "weak" regardless of how confidently stated.
- **Flag misconceptions explicitly.** These are the most actionable findings for the tutor.
- **Preserve the student's actual words.** Copy them from the response file exactly.
- **This is a tutor-facing conversation.** Be direct, technical, and specific. No need for student-friendly language here.
- **Invite discussion.** The tutor knows their student better than you do.
