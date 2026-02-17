---
name: gm-show-progress
description: Display the current strength/gap map for a student. Shows all courses with progress data, or a specific course if specified. Usage: /gm-show-progress [student-name] [course-slug]. Example: /gm-show-progress Jamie
---

# Show Progress — Strength/Gap Map Skill

Display a clear overview of a student's assessed understanding across their course syllabuses.

## Usage

```
/gm-show-progress [student-name] [course-slug]
```

**Examples:**
- `/gm-show-progress Jamie` (shows all courses with progress data)
- `/gm-show-progress Jamie gcse-physics` (shows only Physics progress)
- `/gm-show-progress` (if only one student exists, use that)

## Workflow

### Step 0: Determine Course(s)

Lowercase the student name for folder paths (e.g. "Jamie" → `students/jamie/`).

1. Glob `students/[student]/*/progress.yaml` to find all courses this student has progress data for
2. If a specific course slug was provided as a second argument, filter to just that course
3. For each course found, read `courses/[course-slug]/COURSE.md` for the exam structure, topic grouping, confidence schema, and topic slug → file mapping
4. If no student name provided, check `students/` for available folders and list them
5. If no progress files exist, report that no progress has been recorded yet

### Step 1: Display Strength Map

For each course with progress data, present a clear visual overview.

**Read COURSE.md to determine:**
- **Exam structure** for grouping topics (e.g. Paper 1 / Paper 2, or Component 1 / Component 2)
- **Topic list** from the Topic Slug → File Mapping table — show all topics, even unassessed ones
- **Confidence schema** — single `confidence` column or dual `AO1` / `AO2` columns

```markdown
## Progress Map: [Student Name]
### [Course Name from COURSE.md]

**Last session:** [date]
```

**For single-confidence courses (e.g. Physics):**

Group by exam paper/component, then show:

| Topic | Confidence | Status | Last Assessed |
|-------|-----------|--------|---------------|
| 1. Energy | strong | Assessed | 2026-02-02 |
| 2. Electricity | weak | Assessed | 2026-02-01 |
| 3. Particle Model | — | Not started | — |

**For dual-AO courses (e.g. RS):**

Group by exam paper/component, then show:

| Topic | AO1 | AO2 | Status | Last Assessed |
|-------|-----|-----|--------|---------------|
| 1. Christianity Beliefs | okay | weak | Assessed | 2026-02-09 |
| 2. Christianity Practices | — | — | Not started | — |

### Summary

Count topics by confidence level. For dual-AO courses, summarise each AO separately:

```markdown
**AO1 (Knowledge):** 2 strong, 1 okay, 1 weak, 6 not started
**AO2 (Evaluation):** 1 strong, 1 okay, 2 weak, 6 not started
```

For single-confidence courses:
```markdown
**Strong:** 1 topic — **Okay:** 1 topic — **Weak:** 1 topic — **Not started:** 5 topics
```

### Session History

Where history entries exist, show the trajectory:

```markdown
**Forces** (okay — previously weak)
- 2026-02-08: okay (diagnostic) — "Improved on F=ma, moments still weak"
- 2026-02-02: weak (diagnostic) — "No answers given, topic not yet covered"
```

### Detailed Notes

Show the specific notes from the progress file for each assessed topic, including sub-topic breakdowns where available:

```markdown
**Energy** (strong)
Clear on energy stores and transfers. Good understanding of conservation.

**Christianity Beliefs** (AO1: okay, AO2: weak)
Knows the Trinity and Incarnation at a surface level but can't construct evaluation arguments. Needs AO2 practice.

Sub-topics (where available):
| Sub-topic | Confidence |
|-----------|-----------|
| 1.2 Trinity | AO1: okay |
| 1.5 Crucifixion | AO1: weak |
| 1.8 Sin & salvation | AO2: weak |
```

### Step 2: Recommendations (Optional)

If there are enough assessed topics (3+), add a brief recommendation:

```markdown
### Suggested Next Steps

- **Priority teaching:** [weakest topic with brief reason]
- **Next to assess:** [an unstarted topic, ideally one that links to a strength]
- **Reassess soon:** [any partially assessed topics]
```

## Display Rules

- Use the confidence rubric consistently (strong/okay/weak/not_covered)
- Show all topics from COURSE.md, even unassessed ones — gaps in coverage are useful information
- Include the specific notes from the progress file — these are the valuable part
- Group by exam component as defined in COURSE.md (Paper 1/Paper 2, etc.)
- Show session history where available — the trajectory matters (weak → okay is progress)
- Keep the format clean and scannable — this is a planning tool for the tutor
- Don't add interpretation beyond what's in the progress file notes
- If a topic is `partially_assessed`, note what areas haven't been covered yet
- When `sub_topics` data exists, show a nested breakdown under that topic's detailed notes
- For dual-AO courses, always show both AO columns — a student strong on AO1 but weak on AO2 needs very different support from the reverse
