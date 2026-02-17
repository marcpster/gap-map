# GCSE Religious Studies (AQA 8062, Spec A) — Course Reference

## Subject

GCSE Religious Studies, AQA specification 8062, Specification A.

- **Paper 1** (1h 45m, 96 marks): The study of religions — Christianity and Islam
- **Paper 2** (1h 45m, 96 marks): Thematic studies — Themes A–F (students answer four of six in the exam; all six are built here — TODO: add per-student theme selection so diagnostics focus on the four they're sitting)

**Assessment objectives:**
- **AO1** (50%): Demonstrate knowledge and understanding of religions, beliefs, teachings, practices, sources of authority
- **AO2** (50%): Analyse and evaluate aspects of religion and belief, including their significance and influence

Each five-part question follows the structure: 1 + 2 + 4 + 5 + 12 marks.

## Three Modes

| Mode | Tool | Behaviour |
|------|------|-----------|
| **diagnostic** | `run-diagnostic.sh` → `/ks-assess-answers` | Shell script presents questions (no AI). Claude assesses afterwards. |
| **guided** | `/ks-check-topic` | Conversational revision-style chat. Hints and nudges allowed. Includes devil's advocate probes for AO2 practice. |
| **remediation** | `/ks-work-through` | Teaching mode targeting weak areas. Scripture references, argument structures, model paragraphs. |

## Topic Slug → File Mapping

| Slug | File | Component |
|------|------|-----------|
| christianity-beliefs | `curriculum/topics/1-christianity-beliefs.md` | Paper 1 |
| christianity-practices | `curriculum/topics/2-christianity-practices.md` | Paper 1 |
| islam-beliefs | `curriculum/topics/3-islam-beliefs.md` | Paper 1 |
| islam-practices | `curriculum/topics/4-islam-practices.md` | Paper 1 |
| theme-a-relationships | `curriculum/topics/5-theme-a-relationships.md` | Paper 2 |
| theme-b-religion-and-life | `curriculum/topics/6-theme-b-religion-and-life.md` | Paper 2 |
| theme-c-existence-of-god | `curriculum/topics/7-theme-c-existence-of-god.md` | Paper 2 |
| theme-d-peace-and-conflict | `curriculum/topics/8-theme-d-peace-and-conflict.md` | Paper 2 |
| theme-e-crime-and-punishment | `curriculum/topics/9-theme-e-crime-and-punishment.md` | Paper 2 |
| theme-f-human-rights | `curriculum/topics/10-theme-f-human-rights.md` | Paper 2 |

## Curriculum File Structure

Each topic file follows the same template:

1. **Key Concepts** — beliefs, teachings, practices with scripture/source references, organised by AQA spec subsections
2. **Common Misconceptions** — including misconceptions about other religions
3. **Diagnostic Script** — Sub-topic Coverage table (with AO and Exam Style columns), then questions with "Looking for" criteria:
   - Component 1 topics: 6 questions (Q1–Q6)
   - Component 2 topics: 7 questions (Q1–Q7, with Q7 as cross-religious evaluation)
   - Q1–Q2: factual recall (1–2 mark style) — binary criteria
   - Q3–Q4: "explain two" (4-mark style) — point + development, quality markers
   - Q5: "explain two with sources" (5-mark style) — requires scripture/source references
   - Q6: evaluation (12-mark style) — arguments FOR, arguments AGAINST, conclusion, level indicators
   - Q7 (Component 2 only): cross-religious evaluation — must reference both religions + non-religious views
4. **Guided Mode — Probe Questions** — conversational starters including at least one devil's advocate prompt

## Student Data

Student data lives under `students/[name]/gcse-rs/`:

```
students/[name]/gcse-rs/
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

RS tracks AO1 and AO2 confidence separately per topic, because a student can be strong on knowledge recall but weak on evaluation (or vice versa). This is the RS equivalent of "knows the concept but can't apply the formula."

```yaml
student: Name
subject: GCSE Religious Studies (AQA 8062)
last_session: YYYY-MM-DD

topics:
  topic-slug:
    status: assessed | partially_assessed | not_started
    ao1_confidence: strong | okay | weak | not_covered
    ao2_confidence: strong | okay | weak | not_covered
    mode: diagnostic | guided | remediation
    notes: "Specific observations about understanding and gaps"
    last_assessed: YYYY-MM-DD
    history:
      - date: YYYY-MM-DD
        mode: diagnostic | guided | remediation
        ao1_confidence: strong | okay | weak
        ao2_confidence: strong | okay | weak
        notes: "Assessment summary"
    sub_topics:
      "1.1_nature_of_god":
        ao1_confidence: okay
        ao2_confidence: weak
        notes: "Knows Trinity, can't evaluate monotheism vs Trinity tension"
    responses:                  # Diagnostic mode only
      Q1:
        question: "The question asked"
        answer: "Student's actual words"
        assessment: strong | okay | weak
        ao: AO1 | AO2
        notes: "What the answer reveals"
```

## AO1/AO2 Confidence Rubric

### AO1 — Knowledge and Understanding

| Level | What you observe |
|-------|-----------------|
| **strong** | Recalls teachings accurately with correct terminology, cites specific scripture/sources unprompted, connects beliefs to wider tradition |
| **okay** | Knows the general idea but vague on specifics, can name beliefs but not cite sources, partial terminology |
| **weak** | Confuses teachings between religions, factual errors about beliefs/practices, cannot recall key terms |
| **not_covered** | Not yet assessed |

### AO2 — Analysis and Evaluation

| Level | What you observe |
|-------|-----------------|
| **strong** | Develops arguments with reasoning and evidence, considers multiple viewpoints including non-religious, reaches justified conclusion, engages with counterarguments |
| **okay** | States opinions with some reasoning, limited range of viewpoints, conclusion present but undeveloped |
| **weak** | Asserts opinions without reasoning, one-sided arguments, no engagement with counterviews, "I think X because I think X" |
| **not_covered** | Not yet assessed |

### 12-Mark Evaluation — Levels of Response

| Level | Marks | Description |
|-------|-------|-------------|
| **4** | 10–12 | Well-argued, developed reasoning from multiple perspectives, justified conclusion, accurate use of specialist knowledge |
| **3** | 7–9 | Arguments from different viewpoints, some development, relevant knowledge but may lack balance |
| **2** | 4–6 | Arguments stated but not fully developed, limited viewpoints, some relevant knowledge |
| **1** | 1–3 | Simple opinion, little or no reasoning, few if any relevant facts |
| — | 0 | No relevant content |

Plus up to 3 marks for SPaG on 12-mark questions.

## Session Rules

1. **One topic per session** — avoid context fatigue
2. **Read progress file first** — check what's already been assessed
3. **Read curriculum file** — know what to ask and what misconceptions to watch for
4. **Read COURSE.md** — understand the AO1/AO2 split and rubric
5. **Write back to progress file** — update both `ao1_confidence` and `ao2_confidence`, notes, and per-question responses after session
6. **Be specific** — "can state the Five Pillars but confuses Sawm and Zakah" not "needs work on practices"
7. **Preserve actual words** — the shell script captures verbatim answers; never paraphrase them in assessments
8. **Track AO separately** — a student who knows every teaching but can't construct an argument needs AO2 remediation, not more revision

## Language

British English. Conversational register — "brilliant", "let's have a think about", "what do you reckon".
