---
name: gm-diagnostic
description: Discover available courses and topics, then provide the command to run a diagnostic session. The diagnostic script is interactive (student types answers) so it must be run directly in the terminal. Usage: /gm-diagnostic [topic] [student-name]
---

# Diagnostic — Launch a Diagnostic Session

Help the user pick a course and topic, then give them the exact command to run the diagnostic shell script. The script is interactive — the student types answers into the terminal — so it cannot be run through Claude's Bash tool.

## Usage

```
/gm-diagnostic [topic] [student-name]
```

**Examples:**
- `/gm-diagnostic` (show available courses and topics)
- `/gm-diagnostic forces-and-loads Freya`

## Workflow

### Step 1: Discover Courses and Topics

Glob `courses/*/COURSE.md` to find all courses.

For each course found:
1. Read `courses/[course-slug]/COURSE.md` — extract the **Topic Slug -> File Mapping** table to list available topics
2. Collect the course name from the `## Subject` section

### Step 2: Resolve Parameters

**If topic and student are provided as arguments**, skip to Step 3.

**If not**, present the available options:

```markdown
## Available Diagnostics

### [Course Name]

| Topic | Slug |
|-------|------|
| Forces and Loads | `forces-and-loads` |
| Bridge Types | `bridge-types` |

### [Another Course Name]
...
```

Then ask the user which topic and student name they want.

### Step 3: Validate

1. Confirm the topic slug exists in a course by globbing `courses/*/curriculum/topics/*-[topic].md`
2. If no match, show available topics and ask again
3. Extract the course slug from the matching path

### Step 4: Output the Command

Copy the command to the clipboard using `pbcopy`, then tell the user it's ready to paste:

```bash
echo "./run-diagnostic.sh [topic-slug] [student-name]" | pbcopy
```

Then display:

```markdown
## Ready — copied to clipboard

Paste into your terminal to start.

The script will present questions one at a time (no AI), capture answers, then launch Claude to assess automatically.

To assess manually later, add `SKIP_ASSESS=true` before the command, then run `/gm-assess-answers [student] [topic]` when ready.
```

## Important Rules

- **Never run the diagnostic script through Bash.** It's interactive — the student needs to type answers.
- **Copy to clipboard, keep it brief.** The user knows what a diagnostic is.
