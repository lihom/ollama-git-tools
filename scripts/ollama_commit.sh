#!/bin/bash

# 1. Get the staged changes
read -p "please enter your diff commit id or branch: " DIFF_COMMIT_ID_OR_BRANCH

if [ -z "$DIFF_COMMIT_ID_OR_BRANCH" ]; then
  DIFF_COMMIT_ID_OR_BRANCH="--cached"
fi

DIFF=$(git diff $DIFF_COMMIT_ID_OR_BRANCH ":(exclude)package-lock.json")

# If no changes are staged, just exit
if [ -z "$DIFF" ]; then
    exit 0
fi

echo "🤖 gemma3 is drafting your commit message..."

# 2. Construct the AI Prompt
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROMPT_FILE="$SCRIPT_DIR/../prompts/commit-v2.md"
REVIEW_PROMPTS=$(cat $PROMPT_FILE)
PROMPT="$REVIEW_PROMPTS

Git Diff:
$DIFF"

# 3. Generate message using Ollama
# We use a smaller/faster model here since commit messages should be quick
AI_MSG=$(echo "$PROMPT" | ollama run gemma3)

# 4. Prepend the AI message to the commit file
# We leave a comment so the user knows it was AI-generated
echo "$AI_MSG"
echo ""
echo "# --- AI Generated Message Above ---"
