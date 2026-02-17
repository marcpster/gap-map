# gap-map

A diagnostic tool for tutors. Assesses student understanding across courses and produces structured strength/gap maps for lesson planning.

Built for [Claude Code](https://claude.ai/code). Not a course delivery platform — a tutor's measurement instrument.

## The problem

AI is too helpful to run a diagnostic. Even with explicit instructions not to give hints, Claude's helpfulness training leaks through — during a live session, the tutor had to physically block the screen to stop the student seeing Claude's encouraging nudges. You can't solve a training-level problem with a prompt-level fix.

## The solution

Split the work architecturally:

| Mode | Tool | What happens |
|------|------|-------------|
| **Diagnostic** | `run-diagnostic.sh` | A plain shell script reads questions aloud. No AI anywhere near the student. Captures raw answers to YAML. |
| **Assessment** | `/ks-assess-answers` | Claude grades the answers *afterwards*, with full access to the curriculum, marking criteria, and misconception lists. Generates three reports (student, tutor, parent). |
| **Guided revision** | `/ks-check-topic` | Conversational chat where hints and feedback are fine — this is teaching, not testing. |
| **Remediation** | `/ks-work-through` | Teaching mode targeting specific weak areas. Worked examples, scaffolding, cheat sheets. |

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
cd courses/how-bridges-work
./run-diagnostic.sh forces-and-loads Freya
```

The script presents questions one at a time, captures answers, then launches Claude to assess them automatically.

### Or run each step manually

```bash
# 1. Run the diagnostic (shell script — no AI)
cd courses/how-bridges-work
SKIP_ASSESS=true ./run-diagnostic.sh forces-and-loads Freya

# 2. Assess the answers (Claude)
claude
/ks-assess-answers Freya forces-and-loads 2026-02-17

# 3. Check the gap map
/ks-show-progress Freya

# 4. Teach the weak areas
/ks-work-through forces-and-loads Freya "focus on dead loads and load paths"
```

### View the example

The `students/example/` directory contains a worked example showing the full data flow — a diagnostic response, the resulting progress file, and all three generated reports. Have a look to see what the output looks like before running your own.

## Project structure

```
courses/
  how-bridges-work/            # Demo course (2 topics, 4 questions each)
    COURSE.md                  # Course reference (topic map, rubric, progress format)
    run-diagnostic.sh          # Shell script — no AI touches this
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

## Adding a new course

1. Copy `courses/how-bridges-work/` to `courses/your-course-slug/`
2. Edit `COURSE.md` with your subject details, topic list, and exam structure
3. Write curriculum topic files following the pattern in the existing topics
4. Update `run-diagnostic.sh` with your topic slugs and file mappings
5. Run `chmod +x courses/your-course-slug/run-diagnostic.sh`

Each topic file needs:
- **Key Concepts** — what the spec covers
- **Common Misconceptions** — what students typically get wrong (this is where the real value is)
- **Diagnostic Script** — open-ended questions with "Looking for" criteria
- **Guided Mode probes** — conversational starters for revision sessions

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
