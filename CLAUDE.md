# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Diagnostic tool for a tutor. Assesses student understanding across courses and produces structured strength/gap maps for lesson planning. Not a course delivery platform — a tutor's measurement instrument.

Three modes:

| Mode | Tool | Behaviour |
|------|------|-----------|
| **diagnostic** | `./run-diagnostic.sh [topic] [student]` → `/gm-assess-answers` | Shell script presents questions (no AI). Claude assesses answers afterwards with full curriculum access. |
| **guided** | `/gm-revise` | Conversational revision-style chat with Claude. Hints and feedback allowed. Records progress. |
| **remediation** | `/gm-work-through` | Teaching mode targeting weak areas. Worked examples, scaffolding, cheat sheets. |

**Why the split?** Claude's helpfulness training makes it impossible to read scripted questions without eventually hinting at answers. The shell script removes AI from the question-asking phase entirely — problem solved architecturally.

## Architecture

```
run-diagnostic.sh              # Shell script — presents questions, captures answers, no AI
                               # Discovers course from topic slug automatically

courses/
  [course-slug]/               # e.g. how-bridges-work
    COURSE.md                  # Course-specific reference (topic map, rubric, confidence schema, etc.)
    curriculum/
      overview.md              # Topic map
      topics/
        [number]-[slug].md     # One file per topic with concepts, misconceptions, questions

students/
  [name]/                      # Lowercase folder per student
    [course-slug]/
      progress.yaml            # Strength/gap map for this course
      responses/
        [topic]-[date].yaml    # Raw answer capture from shell script
      reports/
        [topic]-[date]-student.md   # Student-facing review
        [topic]-[date]-tutor.md     # Tutor brief with gap analysis
        [topic]-[date]-parent.md    # Parent-friendly update

.claude/skills/
  gm-diagnostic/SKILL.md      # Launch diagnostic session (outputs terminal command)
  gm-assess-answers/SKILL.md  # Post-diagnostic assessment skill
  gm-revise/SKILL.md     # Guided revision conversation skill
  gm-show-progress/SKILL.md   # Read-only progress display skill
  gm-work-through/SKILL.md    # Remediation teaching skill
```

**Data flow:**
- **Diagnostic:** `run-diagnostic.sh` reads questions from curriculum → captures raw answers to `students/[name]/[course]/responses/` → tutor runs `/gm-assess-answers` → Claude grades against curriculum, writes to `progress.yaml`, generates reports
- **Guided:** `/gm-revise` reads curriculum + progress → runs conversation → writes assessment to progress
- **Remediation:** `/gm-work-through` reads progress → teaches weak areas → writes cheat sheet + session summary + updates progress
- Curriculum files are read-only reference material. Git history captures student progression over time.

## Multi-Course Structure

Each course lives under `courses/[course-slug]/` with its own `COURSE.md` containing course-specific reference material (topic maps, rubrics, curriculum file structure). Skills should read the relevant `COURSE.md` when working with a course.

Student data lives under `students/[name]/[course-slug]/`. Student folder names are always lowercase.

### Included courses

| Course | Path |
|--------|------|
| How Bridges Work (demo, 2 topics) | `courses/how-bridges-work/` |

## Progress File Format

The confidence schema varies by course — see each course's `COURSE.md` for details.

**Single-confidence courses** (e.g. How Bridges Work):
```yaml
student: Name
subject: Course name
last_session: YYYY-MM-DD

topics:
  topic-slug:
    status: assessed | partially_assessed | not_started
    confidence: strong | okay | weak | not_covered
    mode: diagnostic | guided | remediation
    notes: "Specific observations about understanding and gaps"
    last_assessed: YYYY-MM-DD
    history:
      - date: YYYY-MM-DD
        mode: diagnostic | guided | remediation
        confidence: strong | okay | weak
        notes: "Assessment summary"
    sub_topics:              # optional — added by /gm-assess-answers
      "1.1_compression_and_tension":
        confidence: okay
        notes: "Understands pushing vs pulling but mixes up terms"
    responses:       # diagnostic mode only
      Q1:
        question: "The question asked"
        answer: "Student's actual words"
        assessment: strong | okay | weak
        notes: "What the answer reveals"
```

Courses with dual assessment objectives (e.g. knowledge vs evaluation) can use `ao1_confidence` and `ao2_confidence` instead of `confidence` — see the relevant course's `COURSE.md` for details.

When a student has no progress file, create one with all topics set to `not_started` / `not_covered`.

## Available Tools

| Command | Usage | Purpose |
|---------|-------|---------|
| `/gm-diagnostic` | `/gm-diagnostic [topic] [student]` | Discover courses/topics, output the terminal command to run a diagnostic. |
| `/gm-assess-answers` | `/gm-assess-answers [student] [topic] [date]` | Grade raw diagnostic answers against curriculum. Generates three-audience reports. |
| `/gm-revise` | `/gm-revise [topic] [student]` | Guided revision conversation. Hints and nudges allowed. |
| `/gm-work-through` | `/gm-work-through [topic] [student] ["optional focus"]` | Remediation teaching targeting weak areas. Produces cheat sheet. |
| `/gm-show-progress` | `/gm-show-progress [student]` | Display strength/gap map. |

## Design Insights (from live sessions)

### Terminology weaving works
Guided mode naturally introduces correct terminology and units through conversation — not as a lecture, but woven into feedback and follow-up questions (e.g. correcting "N/m" to "Nm", naming Newton's First Law when the student describes the concept but can't name it). This emerged naturally from the conversational format and is one of its strongest features.

### Cross-session comparison is powerful
Referencing previous diagnostic answers during a guided session ("last time that formula tripped you up") makes progress visible to both student and tutor in real time. This works because `progress.yaml` preserves specific, quotable observations in the history array — not just confidence levels. **Design principle: always write specific notes, not just grades.**

### The three-mode loop validates the architecture
The diagnose → assess → guided chat loop proved powerful in practice. The assessment step creates the bridge between raw answers and meaningful teaching conversation. Each mode feeds the next.

### The shell script split is essential
Even with explicit instructions not to hint, Claude's helpfulness leaks through in diagnostic mode. During a live session, the tutor had to physically block the screen to prevent the student seeing Claude's output. The shell script removes AI from question-asking entirely — this is an architectural solution to a training-level problem.

### Question design matters
- **Calculation questions:** use "Calculate..." not "What is..." — signals a numerical answer is expected.
- **Open-ended questions:** add constraints to close creative workarounds that dodge the target concept (e.g. "without adding weight" forces the moments/distance answer rather than "just add mass to the lighter child").

## Language

British English. Conversational register — "brilliant", "let's have a think about", "what do you reckon".
