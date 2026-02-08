#!/bin/bash

# 1. Parse arguments
MODEL="gemma3"
CUSTOM_TASK="general commit"
COMMIT_MSG_FILE=""
COMMIT_SOURCE=""
IS_GIT_HOOK=false

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --prompt) 
      CUSTOM_TASK=$(echo "$2" | sed 's/[;\"`$&]/ /g'); shift ;;
    --prompt-file) 
      if [[ -f "$2" ]]; then
        CUSTOM_TASK=$(cat "$2")
      else
        echo "❌ Error: File $2 not found or inaccessible."
        exit 1
      fi
      shift ;;
    --model)  
      MODEL="$2"; shift ;;
    --commit-file)
      COMMIT_MSG_FILE="$2"; IS_GIT_HOOK=true; shift ;;
    --commit-source)
      COMMIT_SOURCE="$2"; shift ;;
    --git-hook)
      IS_GIT_HOOK=true ;;
    *) echo "❌ Error: Invalid parameter: $1"; exit 1 ;;
  esac
  shift
done

# 2. 處理 Git hook 模式或獨立模式
# Git hook 模式：自動使用 --cached，無互動提示
# 獨立模式：提示用戶輸入（如果有終端可用）
if [[ "$IS_GIT_HOOK" == "true" ]]; then
  # Git Hook 模式：只在 COMMIT_SOURCE 為空時執行（不影響用戶自定義訊息）
  if [ -z "$COMMIT_SOURCE" ]; then
    # User didn't provide a message, use AI-generated one
    DIFF_COMMIT_ID_OR_BRANCH="--cached"
  else
    # User provided a message, skip AI generation
    exit 0
  fi
else
  # 獨立模式：提示用戶輸入 commit ID 或分支（僅在互動終端中執行）
  if [[ -t 0 ]]; then
    read -p "please enter your diff commit id or branch: " DIFF_COMMIT_ID_OR_BRANCH
  else
    DIFF_COMMIT_ID_OR_BRANCH="--cached"
  fi

  if [ -z "$DIFF_COMMIT_ID_OR_BRANCH" ]; then
    DIFF_COMMIT_ID_OR_BRANCH="--cached"
  fi
fi

STAGED_DIFF=$(git diff $DIFF_COMMIT_ID_OR_BRANCH ":(exclude)package-lock.json")

# If no changes are staged, just exit
if [ -z "$STAGED_DIFF" ]; then
    exit 0
fi

echo "🤖 $MODEL is drafting your commit message..."

# 3. Construct the AI Prompt
PROMPT="You are an expert Git manager. Write a professional 'Conventional Commit' message based on the provided Git Diff.

### INSTRUCTIONS
1. **Specific Task**: **$CUSTOM_TASK**
2. **Format**: Use the format: '<type>: <description>'
3. **Tone**: Use the imperative mood (e.g., 'fix' instead of 'fixed', 'add' instead of 'added').
4. **Length**: Keep the message concise and under 72 characters (One-liner).
5. **Strict Rule**: Output ONLY the commit message. DO NOT include any preamble, explanations, or quotes.

### TYPE DEFINITIONS
Choose the most appropriate type:
- **feat**: A new feature or significant change.
- **fix**: A bug fix.
- **docs**: Changes only to documentation.
- **style**: Formatting, missing semi-colons, etc. (No logic change).
- **refactor**: Code changes that neither fix a bug nor add a feature.
- **perf**: A code change that improves performance.
- **test**: Adding missing tests or correcting existing tests.
- **chore**: Updating build tasks, package manager configs, etc.

---
Git Diff to commit:
$STAGED_DIFF"

# 4. Generate message using Ollama
# We use a smaller/faster model here since commit messages should be quick
AI_MSG=$(echo "$PROMPT" | ollama run $MODEL)

# 5. Output or write to file based on mode
if [[ -n "$COMMIT_MSG_FILE" && -f "$COMMIT_MSG_FILE" ]]; then
  # Git Hook 模式：寫入 commit 訊息檔案
  echo "$AI_MSG" > "$COMMIT_MSG_FILE"
  echo "" >> "$COMMIT_MSG_FILE"
  echo "# --- AI Generated Message Above ---" >> "$COMMIT_MSG_FILE"
else
  # 獨立模式：輸出到標準輸出
  echo "$AI_MSG"
  echo ""
  echo "# --- AI Generated Message Above ---"
fi
