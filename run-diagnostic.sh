#!/bin/bash
#
# Gap Map — Diagnostic Question Runner
# Presents scripted questions from a topic file and captures student answers.
# No AI involved — just a clean question-and-answer capture.
#
# Usage: ./run-diagnostic.sh [topic-slug] [student-name]
#        ./run-diagnostic.sh --worksheet [topic-slug] [student-name]
# Example: ./run-diagnostic.sh forces-and-loads Freya
#          ./run-diagnostic.sh --worksheet forces-and-loads Freya
#
# Discovers the course automatically from the topic slug.
# --worksheet generates a blank YAML response file for offline/handwritten answers.

set -e

# --- Resolve paths relative to script location ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Parse --worksheet flag ---
WORKSHEET=false
if [ "${1}" = "--worksheet" ]; then
    WORKSHEET=true
    shift
fi

TOPIC_SLUG="${1}"
STUDENT_NAME="${2}"
DATE=$(date +%Y-%m-%d)

# --- Usage / list topics ---
if [ -z "$TOPIC_SLUG" ] || [ -z "$STUDENT_NAME" ]; then
    echo ""
    echo "  Gap Map — Diagnostic Question Runner"
    echo "  ─────────────────────────────────────"
    echo ""
    echo "  Usage: ./run-diagnostic.sh [topic-slug] [student-name]"
    echo "         ./run-diagnostic.sh --worksheet [topic-slug] [student-name]"
    echo ""

    # Discover all topics across all courses
    for COURSE_DIR in "$SCRIPT_DIR"/courses/*/; do
        [ -d "$COURSE_DIR/curriculum/topics" ] || continue
        SLUG=$(basename "$COURSE_DIR")
        # Extract course name from first heading in COURSE.md
        NAME=$(head -1 "$COURSE_DIR/COURSE.md" 2>/dev/null | sed 's/^# //' | sed 's/ — .*//')
        echo "  ${NAME:-$SLUG}:"
        for TOPIC_PATH in "$COURSE_DIR"/curriculum/topics/*.md; do
            [ -f "$TOPIC_PATH" ] || continue
            FNAME=$(basename "$TOPIC_PATH" .md)
            # Strip leading number and dash (e.g. "1-forces-and-loads" → "forces-and-loads")
            T_SLUG=$(echo "$FNAME" | sed 's/^[0-9]*-//')
            # Extract topic name from first heading
            T_NAME=$(head -1 "$TOPIC_PATH" 2>/dev/null | sed 's/^# //')
            printf "    %-25s %s\n" "$T_SLUG" "$T_NAME"
        done
        echo ""
    done

    echo "  Example: ./run-diagnostic.sh forces-and-loads Freya"
    echo ""
    exit 1
fi

# --- Discover course from topic slug ---
CURRICULUM_PATH=""
COURSE_DIR=""
for CANDIDATE in "$SCRIPT_DIR"/courses/*/curriculum/topics/*-"${TOPIC_SLUG}".md; do
    if [ -f "$CANDIDATE" ]; then
        if [ -n "$CURRICULUM_PATH" ]; then
            echo "Error: Topic '$TOPIC_SLUG' found in multiple courses. This shouldn't happen."
            exit 1
        fi
        CURRICULUM_PATH="$CANDIDATE"
        # Extract course directory (go up from topics/ → curriculum/ → course/)
        COURSE_DIR="$(cd "$(dirname "$CANDIDATE")/../.." && pwd)"
    fi
done

if [ -z "$CURRICULUM_PATH" ]; then
    echo "Error: No topic matching '$TOPIC_SLUG' found in any course."
    echo "Run ./run-diagnostic.sh without arguments to see available topics."
    exit 1
fi

COURSE_SLUG=$(basename "$COURSE_DIR")

# Extract course name from first heading in COURSE.md
COURSE_NAME=$(head -1 "$COURSE_DIR/COURSE.md" 2>/dev/null | sed 's/^# //' | sed 's/ — .*//')
COURSE_NAME="${COURSE_NAME:-$COURSE_SLUG}"

# Extract topic name from first heading in curriculum file
TOPIC_NAME=$(head -1 "$CURRICULUM_PATH" 2>/dev/null | sed 's/^# //')
TOPIC_NAME="${TOPIC_NAME:-$TOPIC_SLUG}"

# Lowercase student name for folder lookup
STUDENT_LOWER=$(echo "$STUDENT_NAME" | tr '[:upper:]' '[:lower:]')

# Extract questions from curriculum file
QUESTIONS=()
while IFS= read -r line; do
    QUESTIONS+=("$line")
done < <(grep '^\*\*Question:\*\*' "$CURRICULUM_PATH" | sed 's/\*\*Question:\*\* "//;s/"$//')

if [ ${#QUESTIONS[@]} -eq 0 ]; then
    echo "Error: No questions found in $CURRICULUM_PATH"
    exit 1
fi

# Create student responses directory if it doesn't exist
RESPONSE_DIR="${SCRIPT_DIR}/students/${STUDENT_LOWER}/${COURSE_SLUG}/responses"
mkdir -p "$RESPONSE_DIR"

OUTPUT_FILE="${RESPONSE_DIR}/${TOPIC_SLUG}-${DATE}.yaml"

# --- Worksheet mode: generate markdown worksheet and exit ---
if [ "$WORKSHEET" = true ]; then
    WORKSHEET_DIR="${SCRIPT_DIR}/students/${STUDENT_LOWER}/${COURSE_SLUG}/worksheets"
    mkdir -p "$WORKSHEET_DIR"
    WORKSHEET_FILE="${WORKSHEET_DIR}/${TOPIC_SLUG}-${DATE}.md"

    {
        echo "# ${COURSE_NAME} — ${TOPIC_NAME}"
        echo ""
        echo "**Student:** ${STUDENT_NAME}  "
        echo "**Date:** ${DATE}"
        echo ""
        echo "---"
        for i in "${!QUESTIONS[@]}"; do
            Q_NUM=$((i + 1))
            QUESTION="${QUESTIONS[$i]}"
            echo ""
            echo "## Question ${Q_NUM}"
            echo ""
            echo "${QUESTION}"
            echo ""
            echo "**Answer:**"
            echo ""
            echo ""
            echo ""
            echo "---"
        done
    } > "$WORKSHEET_FILE"

    echo ""
    echo "  Worksheet saved to: ${WORKSHEET_FILE}"
    echo ""
    echo "  Once answered, run:"
    echo "    claude"
    echo "    /gm-assess ${STUDENT_NAME} ${TOPIC_SLUG} ${DATE}"
    echo ""
    exit 0
fi

# --- Interactive session ---
clear
echo ""
echo "  ┌─────────────────────────────────────────┐"
echo "  │  ${COURSE_NAME}"
echo "  │  Topic: ${TOPIC_NAME}"
printf "  │  Student: %s\n" "$STUDENT_NAME"
echo "  │  Date: ${DATE}"
echo "  └─────────────────────────────────────────┘"
echo ""
echo "  Right, I'm going to ask you ${#QUESTIONS[@]} questions about ${TOPIC_NAME}."
echo "  Just tell me what you think — there's no pass or fail here."
echo "  Type your answer and press Enter. If you don't know, just type 'skip'."
echo ""
echo "  Ready? Press Enter to start."
read -r

# Start YAML output
{
    echo "student: ${STUDENT_NAME}"
    echo "topic: ${TOPIC_SLUG}"
    echo "topic_name: ${TOPIC_NAME}"
    echo "date: ${DATE}"
    echo "mode: diagnostic"
    echo "assessed: false"
    echo ""
    echo "responses:"
} > "$OUTPUT_FILE"

# Ask each question
for i in "${!QUESTIONS[@]}"; do
    Q_NUM=$((i + 1))
    QUESTION="${QUESTIONS[$i]}"

    echo ""
    echo "  ─────────────────────────────────────────"
    echo "  Question ${Q_NUM} of ${#QUESTIONS[@]}"
    echo "  ─────────────────────────────────────────"
    echo ""
    echo "  ${QUESTION}"
    echo ""

    echo "  (Type your answer below. Press Enter when done.)"
    echo ""

    ANSWER=""
    BLANK_COUNT=0
    while true; do
        read -r -p "  > " LINE
        if [ -z "$LINE" ]; then
            BLANK_COUNT=$((BLANK_COUNT + 1))
            if [ $BLANK_COUNT -ge 1 ]; then
                break
            fi
        else
            BLANK_COUNT=0
            if [ -n "$ANSWER" ]; then
                ANSWER="${ANSWER} ${LINE}"
            else
                ANSWER="${LINE}"
            fi
        fi
    done

    # Handle skip/don't know
    if [ -z "$ANSWER" ] || [ "$ANSWER" = "skip" ] || [ "$ANSWER" = "Skip" ]; then
        ANSWER="[no answer given]"
    fi

    # Write to YAML
    {
        echo "  Q${Q_NUM}:"
        echo "    question: \"${QUESTION}\""
        echo "    answer: \"${ANSWER}\""
        echo "    assessment:"
        echo "    notes:"
    } >> "$OUTPUT_FILE"

    # Neutral acknowledgement
    if [ $Q_NUM -lt ${#QUESTIONS[@]} ]; then
        echo "  Okay, cheers. Next one."
    fi
done

echo ""
echo "  ─────────────────────────────────────────"
echo "  That's all ${#QUESTIONS[@]} — cheers for going through those."
echo "  Your tutor will go through the results with you."
echo "  ─────────────────────────────────────────"
echo ""
echo "  Answers saved to: ${OUTPUT_FILE}"
echo ""

# --- Auto-launch assessment ---
if [ "${SKIP_ASSESS:-}" = "true" ]; then
    echo "  To assess these answers, run:"
    echo "    claude"
    echo "    /gm-assess ${STUDENT_NAME} ${TOPIC_SLUG} ${DATE}"
    echo ""
else
    echo "  Launching Claude to assess answers..."
    echo ""
    CLAUDE_CMD="${CLAUDE_CMD:-$(command -v claude 2>/dev/null || echo "$HOME/.claude/local/claude")}"
    cd "$SCRIPT_DIR" && "$CLAUDE_CMD" "/gm-assess ${STUDENT_NAME} ${TOPIC_SLUG} ${DATE}"
fi
