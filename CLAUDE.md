# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Diagnostic tool for a tutor. Assesses student understanding across GCSE courses and produces structured strength/gap maps for lesson planning. Not a course delivery platform — a tutor's measurement instrument.

Three modes:

| Mode | Tool | Behaviour |
|------|------|-----------|
| **diagnostic** | `run-diagnostic.sh` → `/ks-assess-answers` | Shell script presents questions (no AI). Claude assesses answers afterwards with full curriculum access. |
| **guided** | `/ks-check-topic` | Conversational revision-style chat with Claude. Hints and feedback allowed. Records progress. |
| **remediation** | `/ks-work-through` | Teaching mode targeting weak areas. Worked examples, scaffolding, cheat sheets. |

**Why the split?** Claude's helpfulness training makes it impossible to read scripted questions without eventually hinting at answers. The shell script removes AI from the question-asking phase entirely — problem solved architecturally.

## Architecture

```
courses/
  [course-slug]/               # e.g. gcse-physics, gcse-rs
    COURSE.md                  # Course-specific reference (topic map, rubric, confidence schema, etc.)
    run-diagnostic.sh          # Shell script — presents questions, captures answers, no AI
    curriculum/
      overview.md              # Full spec map
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
  ks-assess-answers/SKILL.md  # Post-diagnostic assessment skill
  ks-check-topic/SKILL.md     # Guided revision conversation skill
  ks-show-progress/SKILL.md   # Read-only progress display skill
  ks-work-through/SKILL.md    # Remediation teaching skill
```

**Data flow:**
- **Diagnostic:** `run-diagnostic.sh` reads questions from curriculum → captures raw answers to `students/[name]/[course]/responses/` → tutor runs `/ks-assess-answers` → Claude grades against curriculum, writes to `progress.yaml`, generates reports
- **Guided:** `/ks-check-topic` reads curriculum + progress → runs conversation → writes assessment to progress
- **Remediation:** `/ks-work-through` reads progress → teaches weak areas → writes cheat sheet + session summary + updates progress
- Curriculum files are read-only reference material. Git history captures student progression over time.

## Multi-Course Structure

Each course lives under `courses/[course-slug]/` with its own `COURSE.md` containing course-specific reference material (topic maps, rubrics, curriculum file structure). Skills should read the relevant `COURSE.md` when working with a course.

Student data lives under `students/[name]/[course-slug]/`. Student folder names are always lowercase.

### Currently supported courses

| Course | Path |
|--------|------|
| GCSE Physics (AQA 8463) | `courses/gcse-physics/` |
| GCSE Chemistry (AQA 8462) | `courses/gcse-chemistry/` |
| GCSE Religious Studies (AQA 8062, Spec A) | `courses/gcse-rs/` |

## Progress File Format

The confidence schema varies by course — see each course's `COURSE.md` for details.

**Single-confidence courses** (e.g. Physics):
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
    sub_topics:              # optional — added by /ks-assess-answers
      "5.1_forces_interactions":
        confidence: okay
        notes: "Knows mass vs weight, missing units"
    responses:       # diagnostic mode only
      Q1:
        question: "The question asked"
        answer: "Student's actual words"
        assessment: strong | okay | weak
        notes: "What the answer reveals"
```

**Dual-AO courses** (e.g. RS) — uses `ao1_confidence` and `ao2_confidence` instead of `confidence`:
```yaml
topics:
  topic-slug:
    status: assessed | partially_assessed | not_started
    ao1_confidence: strong | okay | weak | not_covered
    ao2_confidence: strong | okay | weak | not_covered
    mode: diagnostic | guided | remediation
    notes: "Specific observations"
    last_assessed: YYYY-MM-DD
```

When a student has no progress file, create one with all topics set to `not_started` / `not_covered`.

## Available Tools

| Command | Usage | Purpose |
|---------|-------|---------|
| `run-diagnostic.sh` | `cd courses/[course-slug] && ./run-diagnostic.sh [topic] [student]` | Shell script: present scripted questions, capture answers. No AI. |
| `/ks-assess-answers` | `/ks-assess-answers [student] [topic] [date]` | Grade raw diagnostic answers against curriculum. Generates three-audience reports. |
| `/ks-check-topic` | `/ks-check-topic [topic] [student]` | Guided revision conversation. Hints and nudges allowed. |
| `/ks-work-through` | `/ks-work-through [topic] [student] ["optional focus"]` | Remediation teaching targeting weak areas. Produces cheat sheet. |
| `/ks-show-progress` | `/ks-show-progress [student]` | Display strength/gap map. |

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
