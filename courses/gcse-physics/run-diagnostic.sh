#!/bin/bash
#
# Course Diagnostics — Question Runner (GCSE Physics)
# Presents scripted questions from a topic file and captures student answers.
# No AI involved — just a clean question-and-answer capture.
#
# Usage: ./run-diagnostic.sh [topic-slug] [student-name]
# Example: ./run-diagnostic.sh forces Freya
#
# Output: students/[student]/gcse-physics/responses/[topic]-[date].yaml

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
    echo "  Course Diagnostics — Question Runner"
    echo "  ─────────────────────────────────────"
    echo ""
    echo "  Usage: ./run-diagnostic.sh [topic] [student-name]"
    echo ""
    echo "  Topics:"
    echo "    energy            1. Energy"
    echo "    electricity       2. Electricity"
    echo "    particle-model    3. Particle Model of Matter"
    echo "    atomic-structure  4. Atomic Structure"
    echo "    forces            5. Forces"
    echo "    waves             6. Waves"
    echo "    magnetism         7. Magnetism and Electromagnetism"
    echo "    space             8. Space Physics"
    echo ""
    echo "  Example: ./run-diagnostic.sh forces Freya"
    echo ""
    exit 1
fi

# Lowercase student name for folder lookup
STUDENT_LOWER=$(echo "$STUDENT_NAME" | tr '[:upper:]' '[:lower:]')

# Map slug to file (Bash 3.2 compatible — no associative arrays)
case "$TOPIC_SLUG" in
    energy)            TOPIC_FILE="1-energy.md";          TOPIC_NAME="Energy" ;;
    electricity)       TOPIC_FILE="2-electricity.md";     TOPIC_NAME="Electricity" ;;
    particle-model)    TOPIC_FILE="3-particle-model.md";  TOPIC_NAME="Particle Model of Matter" ;;
    atomic-structure)  TOPIC_FILE="4-atomic-structure.md"; TOPIC_NAME="Atomic Structure" ;;
    forces)            TOPIC_FILE="5-forces.md";          TOPIC_NAME="Forces" ;;
    waves)             TOPIC_FILE="6-waves.md";           TOPIC_NAME="Waves" ;;
    magnetism)         TOPIC_FILE="7-magnetism.md";       TOPIC_NAME="Magnetism and Electromagnetism" ;;
    space)             TOPIC_FILE="8-space.md";           TOPIC_NAME="Space Physics" ;;
    *)
        echo "Error: Unknown topic '$TOPIC_SLUG'"
        echo "Valid topics: energy, electricity, particle-model, atomic-structure, forces, waves, magnetism, space"
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

# Create student responses directory if it doesn't exist
RESPONSE_DIR="${PROTO_DIR}/students/${STUDENT_LOWER}/gcse-physics/responses"
mkdir -p "$RESPONSE_DIR"

OUTPUT_FILE="${RESPONSE_DIR}/${TOPIC_SLUG}-${DATE}.yaml"

# --- Session ---
clear
echo ""
echo "  ┌─────────────────────────────────────────┐"
echo "  │  Course Diagnostics — GCSE Physics       │"
echo "  │  Topic: ${TOPIC_NAME}"
printf "  │  Student: %s\n" "$STUDENT_NAME"
echo "  │  Date: ${DATE}"
echo "  └─────────────────────────────────────────┘"
echo ""
echo "  Right, I'm going to ask you 6 questions about ${TOPIC_NAME}."
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
