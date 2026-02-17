# GCSE Chemistry (AQA 8462) — Course Reference

## Subject

GCSE Chemistry, AQA specification 8462.

- **Paper 1** (1h 45m, 100 marks): Topics 1–5
- **Paper 2** (1h 45m, 100 marks): Topics 6–10

Note: Questions in Paper 2 may draw on fundamental concepts from Topics 1–3.

## Three Modes

| Mode | Tool | Behaviour |
|------|------|-----------|
| **diagnostic** | `run-diagnostic.sh` → `/ks-assess-answers` | Shell script presents questions (no AI). Claude assesses afterwards. |
| **guided** | `/ks-check-topic` | Conversational revision-style chat. Hints and nudges allowed. |
| **remediation** | `/ks-work-through` | Teaching mode targeting weak areas. Worked examples, scaffolding, cheat sheets. |

## Topic Slug → File Mapping

| Slug | File |
|------|------|
| atomic-structure-pt | `curriculum/topics/1-atomic-structure-pt.md` |
| bonding | `curriculum/topics/2-bonding.md` |
| quantitative | `curriculum/topics/3-quantitative.md` |
| chemical-changes | `curriculum/topics/4-chemical-changes.md` |
| energy-changes | `curriculum/topics/5-energy-changes.md` |
| rates | `curriculum/topics/6-rates.md` |
| organic | `curriculum/topics/7-organic.md` |
| chemical-analysis | `curriculum/topics/8-chemical-analysis.md` |
| atmosphere | `curriculum/topics/9-atmosphere.md` |
| using-resources | `curriculum/topics/10-using-resources.md` |

## Curriculum File Structure

Each topic file follows the same template:

1. **Key Concepts** — syllabus breakdown with subsections matching AQA spec (e.g. 4.1, 4.2)
2. **Common Misconceptions** — 5–7 items, essential for interpreting student answers
3. **Diagnostic Script** — exactly 6 open-ended questions, each with area reference and "Looking for" criteria
4. **Guided Mode — Probe Questions** — 6 conversational starters for revision-style sessions

## Student Data

Student data lives under `students/[name]/gcse-chemistry/`:

```
students/[name]/gcse-chemistry/
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
subject: GCSE Chemistry (AQA 8462)
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
      "4.1_atomic_structure":
        confidence: okay
        notes: "Knows proton/neutron/electron but unsure on isotopes"
      "4.4_electrolysis":
        confidence: weak
        notes: "Confused about which electrode attracts which ion"
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
5. **Be specific** — "confused about oxidation vs reduction" not "needs work"
6. **Preserve actual words** — the shell script captures verbatim answers; never paraphrase them in assessments

## Language

British English. Conversational register — "brilliant", "let's have a think about", "what do you reckon".
