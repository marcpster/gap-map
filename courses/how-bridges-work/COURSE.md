# How Bridges Work — Course Reference

## Subject

How Bridges Work — introductory engineering concepts. No exam board. Designed as a demonstration course for the gap-map system.

Two topics covering the fundamentals of bridge engineering: how forces travel through structures, and how different bridge types distribute those forces.

## Three Modes

| Mode | Tool | Behaviour |
|------|------|-----------|
| **diagnostic** | `run-diagnostic.sh` → `/ks-assess-answers` | Shell script presents questions (no AI). Claude assesses afterwards. |
| **guided** | `/ks-check-topic` | Conversational revision-style chat. Hints and nudges allowed. |
| **remediation** | `/ks-work-through` | Teaching mode targeting weak areas. Worked examples, scaffolding, cheat sheets. |

## Topic Slug → File Mapping

| Slug | File |
|------|------|
| forces-and-loads | `curriculum/topics/1-forces-and-loads.md` |
| bridge-types | `curriculum/topics/2-bridge-types.md` |

## Curriculum File Structure

Each topic file follows the same template:

1. **Key Concepts** — core ideas with subsections
2. **Common Misconceptions** — 5–7 items, essential for interpreting student answers
3. **Diagnostic Script** — 4 open-ended questions, each with area reference and "Looking for" criteria
4. **Guided Mode — Probe Questions** — conversational starters for revision-style sessions

## Student Data

Student data lives under `students/[name]/how-bridges-work/`:

```
students/[name]/how-bridges-work/
  progress.yaml          # Current strength/gap map
  responses/             # Raw answer captures from diagnostic shell script
    [topic]-[date].yaml
  reports/               # Generated reports (student, tutor, parent)
    [topic]-[date]-student.md
    [topic]-[date]-tutor.md
    [topic]-[date]-parent.md
```

Student folder names are always lowercase (e.g. `freya`, `marc`).

## Progress File Format

```yaml
student: Name
subject: How Bridges Work
last_session: YYYY-MM-DD

topics:
  topic-slug:
    status: assessed | partially_assessed | not_started
    confidence: strong | okay | weak | not_covered
    mode: diagnostic | guided | remediation
    notes: "Specific observations about understanding and gaps"
    last_assessed: YYYY-MM-DD
    history:                    # Previous assessments (most recent first)
      - date: YYYY-MM-DD
        mode: diagnostic | guided | remediation
        confidence: strong | okay | weak
        notes: "Assessment summary"
    sub_topics:                 # Optional — added by /ks-assess-answers from Sub-topic Coverage tables
      "1.1_compression_and_tension":
        confidence: okay
        notes: "Understands pushing vs pulling but mixes up terms"
    responses:                  # Diagnostic mode only
      Q1:
        question: "The question asked"
        answer: "Student's actual words"
        assessment: strong | okay | weak
        notes: "What the answer reveals"
```

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
5. **Be specific** — "confuses compression and tension" not "needs work"
6. **Preserve actual words** — the shell script captures verbatim answers; never paraphrase them in assessments

## Language

British English. Conversational register — "brilliant", "let's have a think about", "what do you reckon".
