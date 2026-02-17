# [Course Name] — Course Reference

## Subject

[Full course name and exam board, e.g. "GCSE Biology, AQA specification 8461."]

- **Paper 1** (Xh Ym, N marks): Topics 1–N
- **Paper 2** (Xh Ym, N marks): Topics N–M

## Three Modes

| Mode | Tool | Behaviour |
|------|------|-----------|
| **diagnostic** | `run-diagnostic.sh` → `/ks-assess-answers` | Shell script presents questions (no AI). Claude assesses afterwards. |
| **guided** | `/ks-check-topic` | Conversational revision-style chat. Hints and nudges allowed. |
| **remediation** | `/ks-work-through` | Teaching mode targeting weak areas. Worked examples, scaffolding, cheat sheets. |

## Topic Slug → File Mapping

| Slug | File |
|------|------|
| topic-one | `curriculum/topics/1-topic-one.md` |
| topic-two | `curriculum/topics/2-topic-two.md` |

## Curriculum File Structure

Each topic file follows the same template:

1. **Key Concepts** — syllabus breakdown with subsections matching the spec
2. **Common Misconceptions** — 5–7 items, essential for interpreting student answers
3. **Diagnostic Script** — open-ended questions, each with area reference and "Looking for" criteria
4. **Guided Mode — Probe Questions** — conversational starters for revision-style sessions

## Student Data

Student data lives under `students/[name]/[course-slug]/`:

```
students/[name]/[course-slug]/
  progress.yaml          # Current strength/gap map
  responses/             # Raw answer captures from diagnostic shell script
    [topic]-[date].yaml
  reports/               # Generated reports (student, tutor, parent)
    [topic]-[date]-student.md
    [topic]-[date]-tutor.md
    [topic]-[date]-parent.md
```

Student folder names are always lowercase.

## Progress File Format

```yaml
student: Name
subject: [Full course name]
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
    sub_topics:
      "1.1_sub_topic_slug":
        confidence: okay
        notes: "Observation for this sub-topic"
    responses:
      Q1:
        question: "The question asked"
        answer: "Student's actual words"
        assessment: strong | okay | weak
        notes: "What the answer reveals"
```

### Dual-AO courses (optional)

If your course splits assessment objectives (e.g. AO1 knowledge recall vs AO2 analysis/evaluation), replace the single `confidence` field with:

```yaml
    ao1_confidence: strong | okay | weak | not_covered
    ao2_confidence: strong | okay | weak | not_covered
```

Add an `AO` column to each topic's Sub-topic Coverage table so the assessment skill knows which questions map to which objective.

## Confidence Rubric

| Level | What you observe |
|-------|-----------------|
| **strong** | Explains unprompted, applies to unfamiliar scenarios, uses correct terminology naturally |
| **okay** | Understands when prompted, struggles with application or transfer, some terminology gaps |
| **weak** | Misconceptions present, recalls only fragments, confuses related concepts |
| **not_covered** | Not yet assessed |

## Session Rules

1. **One topic per session** — avoid context fatigue
2. **Read progress file first** — check what's already been assessed
3. **Read curriculum file** — know what to ask and what misconceptions to watch for
4. **Write back to progress file** — update confidence, notes, and per-question responses after session
5. **Be specific** — "struggles with osmosis vs diffusion" not "needs work"
6. **Preserve actual words** — the shell script captures verbatim answers; never paraphrase them

## Language

British English. Conversational register.
