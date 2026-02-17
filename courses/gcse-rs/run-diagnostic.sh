#!/bin/bash
#
# Course Diagnostics — Question Runner (GCSE Religious Studies)
# Presents scripted questions from a topic file and captures student answers.
# No AI involved — just a clean question-and-answer capture.
#
# Usage: ./run-diagnostic.sh [topic-slug] [student-name]
# Example: ./run-diagnostic.sh christianity-beliefs Freya
#
# Output: students/[student]/gcse-rs/responses/[topic]-[date].yaml

set -e

# --- Resolve paths relative to script location ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROTO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# --- Config ---
TOPIC_SLUG="${1}"
STUDENT_NAME="${2}"
DATE=$(date +%Y-%m-%d)
CURRICULUM_DIR="${SCRIPT_DIR}/curriculum/topics"

# --- Validation ---
if [ -z "$TOPIC_SLUG" ] || [ -z "$STUDENT_NAME" ]; then
    echo ""
    echo "  Course Diagnostics — Question Runner (GCSE Religious Studies)"
    echo "  ──────────────────────────────────────────────────────────────"
    echo ""
    echo "  Usage: ./run-diagnostic.sh [topic] [student-name]"
    echo ""
    echo "  Topics:"
    echo "    christianity-beliefs       1. Christianity: Beliefs and Teachings"
    echo "    christianity-practices     2. Christianity: Practices"
    echo "    islam-beliefs              3. Islam: Beliefs and Teachings"
    echo "    islam-practices            4. Islam: Practices"
    echo "    theme-a-relationships      5. Theme A: Relationships and Families"
    echo "    theme-b-religion-and-life  6. Theme B: Religion and Life"
    echo "    theme-c-existence-of-god   7. Theme C: The Existence of God and Revelation"
    echo "    theme-d-peace-and-conflict 8. Theme D: Religion, Peace and Conflict"
    echo "    theme-e-crime-and-punishment 9. Theme E: Religion, Crime and Punishment"
    echo "    theme-f-human-rights       10. Theme F: Religion, Human Rights and Social Justice"
    echo ""
    echo "  Example: ./run-diagnostic.sh christianity-beliefs Freya"
    echo ""
    exit 1
fi

# Lowercase student name for folder lookup
STUDENT_LOWER=$(echo "$STUDENT_NAME" | tr '[:upper:]' '[:lower:]')

# Map slug to file (Bash 3.2 compatible — no associative arrays)
case "$TOPIC_SLUG" in
    christianity-beliefs)       TOPIC_FILE="1-christianity-beliefs.md";       TOPIC_NAME="Christianity: Beliefs and Teachings" ;;
    christianity-practices)     TOPIC_FILE="2-christianity-practices.md";     TOPIC_NAME="Christianity: Practices" ;;
    islam-beliefs)              TOPIC_FILE="3-islam-beliefs.md";              TOPIC_NAME="Islam: Beliefs and Teachings" ;;
    islam-practices)            TOPIC_FILE="4-islam-practices.md";            TOPIC_NAME="Islam: Practices" ;;
    theme-a-relationships)      TOPIC_FILE="5-theme-a-relationships.md";      TOPIC_NAME="Theme A: Relationships and Families" ;;
    theme-b-religion-and-life)  TOPIC_FILE="6-theme-b-religion-and-life.md";  TOPIC_NAME="Theme B: Religion and Life" ;;
    theme-c-existence-of-god)   TOPIC_FILE="7-theme-c-existence-of-god.md";   TOPIC_NAME="Theme C: The Existence of God and Revelation" ;;
    theme-d-peace-and-conflict) TOPIC_FILE="8-theme-d-peace-and-conflict.md"; TOPIC_NAME="Theme D: Religion, Peace and Conflict" ;;
    theme-e-crime-and-punishment) TOPIC_FILE="9-theme-e-crime-and-punishment.md"; TOPIC_NAME="Theme E: Religion, Crime and Punishment" ;;
    theme-f-human-rights)       TOPIC_FILE="10-theme-f-human-rights.md";      TOPIC_NAME="Theme F: Religion, Human Rights and Social Justice" ;;
    *)
        echo "Error: Unknown topic '$TOPIC_SLUG'"
        echo "Valid topics: christianity-beliefs, christianity-practices, islam-beliefs, islam-practices,"
        echo "  theme-a-relationships, theme-b-religion-and-life, theme-c-existence-of-god,"
        echo "  theme-d-peace-and-conflict, theme-e-crime-and-punishment, theme-f-human-rights"
        exit 1
        ;;
esac

CURRICULUM_PATH="${CURRICULUM_DIR}/${TOPIC_FILE}"

if [ ! -f "$CURRICULUM_PATH" ]; then
    echo "Error: Curriculum file not found: $CURRICULUM_PATH"
    exit 1
fi

# Extract questions from curriculum file (Bash 3.2 compatible — no mapfile)
# Questions are on lines starting with **Question:** "..."
QUESTIONS=()
while IFS= read -r line; do
    QUESTIONS+=("$line")
done < <(grep '^\*\*Question:\*\*' "$CURRICULUM_PATH" | sed 's/\*\*Question:\*\* "//;s/"$//')

if [ ${#QUESTIONS[@]} -eq 0 ]; then
    echo "Error: No questions found in $CURRICULUM_PATH"
    exit 1
fi

QUESTION_COUNT=${#QUESTIONS[@]}

# Create student responses directory if it doesn't exist
RESPONSE_DIR="${PROTO_DIR}/students/${STUDENT_LOWER}/gcse-rs/responses"
mkdir -p "$RESPONSE_DIR"

OUTPUT_FILE="${RESPONSE_DIR}/${TOPIC_SLUG}-${DATE}.yaml"

# --- Session ---
clear
echo ""
echo "  ┌────────────────────────────────────────────────────────┐"
echo "  │  Course Diagnostics — GCSE Religious Studies            │"
echo "  │  Topic: ${TOPIC_NAME}"
printf "  │  Student: %s\n" "$STUDENT_NAME"
echo "  │  Date: ${DATE}"
echo "  └────────────────────────────────────────────────────────┘"
echo ""
echo "  Right, I'm going to ask you ${QUESTION_COUNT} questions about ${TOPIC_NAME}."
echo "  Some are short, some ask you to explain things, and one is a bigger"
echo "  essay-style question."
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
    echo "  Question ${Q_NUM} of ${QUESTION_COUNT}"
    echo "  ─────────────────────────────────────────"
    echo ""
    echo "  ${QUESTION}"
    echo ""

    # Collect answer (blank line to finish)
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
    if [ $Q_NUM -lt ${QUESTION_COUNT} ]; then
        echo "  Okay, cheers. Next one."
    fi
done

echo ""
echo "  ─────────────────────────────────────────"
echo "  That's all ${QUESTION_COUNT} — cheers for going through those."
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
