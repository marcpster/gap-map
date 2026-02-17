#!/bin/bash
#
# Course Diagnostics — Question Runner ([COURSE NAME])
# Presents scripted questions from a topic file and captures student answers.
# No AI involved — just a clean question-and-answer capture.
#
# Usage: ./run-diagnostic.sh [topic-slug] [student-name]
# Example: ./run-diagnostic.sh example-topic Freya
#
# Output: students/[student]/[course-slug]/responses/[topic]-[date].yaml

set -e

# --- Resolve paths relative to script location ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROTO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# --- Config ---
# IMPORTANT: Change COURSE_SLUG to match your course folder name
COURSE_SLUG="template"
COURSE_NAME="Template Course"

TOPIC_SLUG="${1}"
STUDENT_NAME="${2}"
DATE=$(date +%Y-%m-%d)
CURRICULUM_DIR="${SCRIPT_DIR}/curriculum/topics"

# --- Validation ---
if [ -z "$TOPIC_SLUG" ] || [ -z "$STUDENT_NAME" ]; then
    echo ""
    echo "  Course Diagnostics — Question Runner"
    echo "  ─────────────────────────────────────"
    echo ""
    echo "  Usage: ./run-diagnostic.sh [topic] [student-name]"
    echo ""
    echo "  Topics:"
    echo "    example-topic     1. Example Topic"
    # Add your topics here
    echo ""
    echo "  Example: ./run-diagnostic.sh example-topic Freya"
    echo ""
    exit 1
fi

# Lowercase student name for folder lookup
STUDENT_LOWER=$(echo "$STUDENT_NAME" | tr '[:upper:]' '[:lower:]')

# Map slug to file — add your topics here
case "$TOPIC_SLUG" in
    example-topic) TOPIC_FILE="1-example-topic.md"; TOPIC_NAME="Example Topic" ;;
    # another-topic) TOPIC_FILE="2-another-topic.md"; TOPIC_NAME="Another Topic" ;;
    *)
        echo "Error: Unknown topic '$TOPIC_SLUG'"
        echo "Valid topics: example-topic"
        exit 1
        ;;
esac

CURRICULUM_PATH="${CURRICULUM_DIR}/${TOPIC_FILE}"

if [ ! -f "$CURRICULUM_PATH" ]; then
    echo "Error: Curriculum file not found: $CURRICULUM_PATH"
    exit 1
fi

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
RESPONSE_DIR="${PROTO_DIR}/students/${STUDENT_LOWER}/${COURSE_SLUG}/responses"
mkdir -p "$RESPONSE_DIR"

OUTPUT_FILE="${RESPONSE_DIR}/${TOPIC_SLUG}-${DATE}.yaml"

# --- Session ---
clear
echo ""
echo "  ┌─────────────────────────────────────────┐"
echo "  │  Course Diagnostics — ${COURSE_NAME}"
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
    echo "    /ks-assess-answers ${STUDENT_NAME} ${TOPIC_SLUG} ${DATE}"
    echo ""
else
    echo "  Launching Claude to assess answers..."
    echo ""
    CLAUDE_CMD="${CLAUDE_CMD:-$(command -v claude 2>/dev/null || echo "$HOME/.claude/local/claude")}"
    cd "$PROTO_DIR" && "$CLAUDE_CMD" "/ks-assess-answers ${STUDENT_NAME} ${TOPIC_SLUG} ${DATE}"
fi
