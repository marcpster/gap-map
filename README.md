# gap-map

A diagnostic tool for learning. Assesses understanding across courses and produces structured strength/gap maps for further learning, lesson plans, etc. Run with [Claude Code](https://claude.ai/code), specific Claude skills.

> **Tip:** When you are running the skills (after the diagnostic), type something short on the keyboard as soon as possible. If you don't Claude will auto-suggest a great answer in the prompt, which is not useful for learning!

## The solution

| Mode | Tool | What happens |
|------|------|-------------|
| **1. Diagnostic** | `run-diagnostic.sh` | A plain shell script reads questions and captures raw answers. |
| **2. Assessment** | `/gm-assess-answers` | Claude then grades the answers and generates reports. |
| **3a. Guided revision** | `/gm-revise` | A proper chat with hints and feedback — teaching, not testing. |
| **3b. Remediation** | `/gm-work-through` | Teaching mode targeting specific weak areas. Worked examples, scaffolding, cheat sheets. |

The three-mode loop — **diagnose → assess → teach** — is the core of the system. Each mode feeds the next.

## What you get

After a diagnostic session, gap-map produces:

- **`progress.yaml`** — a structured strength/gap map per student per course, with per-question breakdowns and sub-topic confidence levels
- **Student review** — encouraging, specific feedback with no scores or grades
- **Tutor brief** — direct analysis with misconception flags, gap analysis, and recommended focus areas
- **Parent update** — jargon-free progress summary with practical suggestions

All tracked in git, so you can see how understanding develops over time.

## Quick start

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- Bash (macOS/Linux — the diagnostic script uses standard shell)

### Setup

```bash
git clone https://github.com/[your-username]/gap-map.git
cd gap-map
```

### Run a diagnostic

```bash
./run-diagnostic.sh forces-and-loads Freya
```

The script presents questions one at a time, captures answers, then launches Claude to assess them automatically.

### Or run each step manually

```bash
# 1. Run the diagnostic (shell script — no AI)
SKIP_ASSESS=true ./run-diagnostic.sh forces-and-loads Freya

# 2. Assess the answers (Claude)
claude
/gm-assess-answers Freya forces-and-loads 2026-02-17

# 3. Check the gap map
/gm-show-progress Freya

# 4. Teach the weak areas
/gm-work-through forces-and-loads Freya "focus on dead loads and load paths"
```

### View the example

The `students/example/` directory contains a worked example showing the full data flow — a diagnostic response, the resulting progress file, and all three generated reports. Have a look to see what the output looks like before running your own.

## Project structure

```
run-diagnostic.sh              # Diagnostic shell script — no AI touches this

courses/
  how-bridges-work/            # Demo course (2 topics, 4 questions each)
    COURSE.md                  # Course reference (topic map, rubric, progress format)
    curriculum/
      overview.md              # Topic map
      topics/
        1-forces-and-loads.md  # Compression, tension, equilibrium, loads
        2-bridge-types.md      # Beam, arch, suspension, cable-stayed

students/
  example/                     # Worked example showing full data flow
    how-bridges-work/
      progress.yaml            # The gap map
      responses/               # Raw diagnostic captures
      reports/                 # Generated reports (student, tutor, parent)

.claude/skills/                # Claude Code skills that power the AI modes
```

## Course structure

A course is just a folder of markdown files:

```
courses/your-course-slug/
  COURSE.md                        # Course reference: topic list, rubric, progress format
  curriculum/
    overview.md                    # Topic map (what's in the course)
    topics/
      1-first-topic.md             # One file per topic
      2-second-topic.md
```

Each topic file has four sections:

| Section | What it does |
|---------|-------------|
| **Key Concepts** | The actual content — what the student should know, broken into numbered sub-topics |
| **Common Misconceptions** | What students typically get wrong (this is where the real assessment value is) |
| **Diagnostic Script** | Open-ended questions with "Looking for" criteria — the answer key for `/gm-assess-answers` |
| **Guided Mode probes** | Conversational starters for `/gm-revise` revision sessions |

See `courses/how-bridges-work/` for a complete working example.

## Adding a new course

The easiest way: point Claude at the exam board spec (or any syllabus/textbook) and ask it to generate the course files following the pattern in `courses/how-bridges-work/`. It will create the `COURSE.md`, topic files, and misconception lists from the source material.

Manually:

1. Copy `courses/how-bridges-work/` to `courses/your-course-slug/`
2. Edit `COURSE.md` with your subject details, topic list, and confidence schema
3. Write topic files following the same four-section pattern

The diagnostic script (`run-diagnostic.sh`) discovers courses automatically — no config needed.

## Student data

Student data is gitignored by default — the `students/` directory is excluded except for `students/example/`. Your students' responses and progress files stay local to your machine.

If you want to track student progress in version control (useful for seeing development over time), either:
- Add specific student folders to git tracking: `git add -f students/[name]/`
- Or keep a separate private repo for student data and symlink the `students/` directory

## Design principles

**The shell script split is non-negotiable.** Claude is too helpful for diagnostic mode. The shell script removes AI from question-asking entirely. This is an architectural solution to a training-level problem.

**Specific notes, not just grades.** `progress.yaml` preserves specific, quotable observations — "said current gets used up" not just "weak on electricity". This makes cross-session comparison powerful and gives the tutor something concrete to reference.

**Three audiences, three reports.** Students need encouragement and actionable next steps. Tutors need misconception flags and gap analysis. Parents need jargon-free reassurance. Same data, different lenses.

**Curriculum files are the answer key.** Every question has explicit "Looking for" criteria and every topic has a misconceptions list. The AI grades against these, not against its own knowledge — making assessments consistent and auditable.

## Licence

MIT
