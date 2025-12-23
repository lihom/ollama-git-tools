#!/bin/bash

# 1. Get the staged changes
read -p "please enter your diff commit id or branch: " DIFF_COMMIT_ID_OR_BRANCH
DIFF=$(git diff $DIFF_COMMIT_ID_OR_BRANCH --no-color)

# If no changes are staged, just exit
if [ -z "$DIFF" ]; then
    exit 0
fi

echo "🤖 gemma3 is drafting your commit message..."

# 2. Construct the AI Prompt
PROMPT="Context: You are a helpful assistant writing a git commit message.
Instructions:
- Use the 'Conventional Commits' format (e.g., feat: description, fix: description).
- Be concise (one line if possible).
- Do not include any preamble like 'Here is your message'.
- Base the message on this diff:

$DIFF"

# 3. Generate message using Ollama
# We use a smaller/faster model here since commit messages should be quick
AI_MSG=$(echo "$PROMPT" | ollama run gemma3)

# 4. Prepend the AI message to the commit file
# We leave a comment so the user knows it was AI-generated
echo "$AI_MSG"
echo ""
echo "# --- AI Generated Message Above ---"
