#!/bin/bash

# 1. Get the staged changes (diff)
read -p "please enter your diff commit id or branch: " DIFF_COMMIT_ID_OR_BRANCH

if [ -z "$DIFF_COMMIT_ID_OR_BRANCH" ]; then
  DIFF_COMMIT_ID_OR_BRANCH="--cached"
fi

STAGED_DIFF=$(git diff $DIFF_COMMIT_ID_OR_BRANCH ":(exclude)package-lock.json")

# If no changes are staged, exit early
if [ -z "$STAGED_DIFF" ]; then
  exit 0
fi

echo "🤖 gemma3 is reviewing your changes..."

# 2. Define the prompt for gemma3
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROMPT_FILE="$SCRIPT_DIR/../prompts/review-v2.md"
REVIEW_PROMPTS=$(cat $PROMPT_FILE)
PROMPT="$REVIEW_PROMPTS

Git Diff:
$STAGED_DIFF"

# 3. Send to Ollama and capture response
# We use the 'instruct' variant for better adherence to the prompt
REVIEW=$(echo "$PROMPT" | ollama run gemma3)

echo ""
echo "📋 COMPREHENSIVE CODE REVIEW RESULTS"
echo "=========================================="
echo "$REVIEW"
echo "=========================================="

# Count actual issues only
criticalCount=$(echo "$REVIEW" | grep -c "ISSUE: CRITICAL")
highCount=$(echo "$REVIEW" | grep -c "ISSUE: HIGH")
mediumCount=$(echo "$REVIEW" | grep -c "ISSUE: MEDIUM")
lowCount=$(echo "$REVIEW" | grep -c "ISSUE: LOW")

echo ""
echo "📈 REVIEW SUMMARY:"
echo "  🔴 Critical Issues: $criticalCount"
echo "  🟠 High Severity: $highCount"
echo "  🟡 Medium Severity: $mediumCount"
echo "  🟢 Low Severity: $lowCount"
echo ""

# Check if the review was approved (should only happen when no issues found)
if echo "$REVIEW" | grep -q "RESULT: APPROVED" && [ "$criticalCount" -eq 0 ] && [ "$mediumCount" -eq 0 ]; then
  echo "✅ Excellent! Code follows best practices."
  echo ""
  echo "🎉 Commit approved! Keep up the good coding practices!"
  echo ""
  echo " ✓ COMMIT WILL PROCEED ✓ "
  exit 0
fi

# Block commits based on NEW severity rules
if [ "$criticalCount" -gt 0 ]; then
  echo "🚫 COMMIT BLOCKED: Critical issues found ($criticalCount). Fix them before committing."
  echo ""
  echo " ✗ COMMIT REJECTED ✗ "
  exit 1
elif [ "$highCount" -gt 0 ]; then
  echo "🚫 COMMIT BLOCKED: High severity issues found ($highCount). Must be resolved."
  echo ""
  echo " ✗ COMMIT REJECTED ✗ "
  exit 1
elif [ "$mediumCount" -ge 3 ]; then
  echo "⚠️  COMMIT BLOCKED: Too many medium issues ($mediumCount found). Please address some before committing."
  echo "   To override, use: git commit --no-verify"
  echo ""
  echo " ✗ COMMIT REJECTED ✗ "
  exit 1
elif [ "$mediumCount" -gt 0 ]; then
  echo "⚠️  Medium severity issues detected ($mediumCount found). Consider fixing, but commit allowed."
  echo ""
  echo "🎉 Commit approved with minor concerns!"
  echo ""
  echo " ✓ COMMIT WILL PROCEED ✓ "
  exit 0
elif [ "$lowCount" -gt 0 ]; then
  echo "✅ Minor improvements suggested ($lowCount found). Good code quality overall."
  echo ""
  echo "🎉 Commit approved! Keep up the good coding practices!"
  echo ""
  echo " ✓ COMMIT WILL PROCEED ✓ "
  exit 0
else
  # No issues found but also no explicit approval (shouldn't happen with updated prompt)
  echo "✅ Code review completed. No blocking issues found."
  echo ""
  echo "🎉 Commit approved! Keep up the good coding practices!"
  echo ""
  echo " ✓ COMMIT WILL PROCEED ✓ "
  exit 0
fi
