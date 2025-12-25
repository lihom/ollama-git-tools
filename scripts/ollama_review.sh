#!/bin/bash

# 1. Get the staged changes (diff)
read -p "please enter your diff commit id or branch: " DIFF_COMMIT_ID_OR_BRANCH

if [ -z "$DIFF_COMMIT_ID_OR_BRANCH" ]; then
  DIFF_COMMIT_ID_OR_BRANCH="--cached"
fi

STAGED_DIFF=$(git diff "$DIFF_COMMIT_ID_OR_BRANCH")

# If no changes are staged, exit early
if [ -z "$STAGED_DIFF" ]; then
  exit 0
fi

echo "🤖 gemma3 is reviewing your changes..."

# 2. Define the prompt for gemma3
PROMPT="Review this Git Diff focusing on:
1. SECURITY & BUGS: Vulnerabilities and logic errors.
2. CLEAN CODE: Readability and simplicity.
3. BEST PRACTICES: Language-specific standards.
4. PERFORMANCE: Bottlenecks and patterns.

Severity Levels: CRITICAL, HIGH, MEDIUM, LOW.

Formatting:
- Start each issue with: ISSUE: [SEVERITY] - [Description]
- Include: Explanation, Suggestion, Code Example, and Rationale.
- If no issues: 'APPROVED - Code follows good practices with no significant issues detected.'

Git Diff:
$STAGED_DIFF"

# 3. Send to Ollama and capture response
# We use the 'instruct' variant for better adherence to the prompt
REVIEW=$(echo "$PROMPT" | ollama run gemma3)

echo ""
echo "\033[1;37m📋 COMPREHENSIVE CODE REVIEW RESULTS\033[0m"
echo "\033[1;37m==========================================\033[0m"
echo "$REVIEW"
echo "\033[1;37m==========================================\033[0m"

# Count actual issues only
criticalCount=$(echo "$REVIEW" | grep -c "ISSUE: CRITICAL")
highCount=$(echo "$REVIEW" | grep -c "ISSUE: HIGH")
mediumCount=$(echo "$REVIEW" | grep -c "ISSUE: MEDIUM")
lowCount=$(echo "$REVIEW" | grep -c "ISSUE: LOW")

echo ""
echo "\033[1;37m📈 REVIEW SUMMARY:\033[0m"
echo "\033[1;31m  🔴 Critical Issues: $criticalCount\033[0m"
echo "\033[0;33m  🟠 High Severity: $highCount\033[0m"
echo "\033[1;33m  🟡 Medium Severity: $mediumCount\033[0m"
echo "\033[0;32m  🟢 Low Severity: $lowCount\033[0m"
echo ""

# Check if the review was approved (should only happen when no issues found)
if echo "$REVIEW" | grep -q "APPROVED"; then
  echo "\033[0;32m✅ Excellent! Code follows best practices.\033[0m"
  echo ""
  echo "\033[0;32m🎉 Commit approved! Keep up the good coding practices!\033[0m"
  echo ""
  echo "\033[1;42;30m ✓ COMMIT WILL PROCEED ✓ \033[0m"
  exit 0
fi

# Block commits based on NEW severity rules
if [ "$criticalCount" -gt 0 ]; then
  echo "\033[1;31m🚫 COMMIT BLOCKED: Critical issues found ($criticalCount). Fix them before committing.\033[0m"
  echo ""
  echo "\033[1;41;37m ✗ COMMIT REJECTED ✗ \033[0m"
  exit 1
elif [ "$highCount" -gt 0 ]; then
  echo "\033[1;31m🚫 COMMIT BLOCKED: High severity issues found ($highCount). Must be resolved.\033[0m"
  echo ""
  echo "\033[1;41;37m ✗ COMMIT REJECTED ✗ \033[0m"
  exit 1
elif [ "$mediumCount" -ge 3 ]; then
  echo "\033[0;33m⚠️  COMMIT BLOCKED: Too many medium issues ($mediumCount found). Please address some before committing.\033[0m"
  echo "\033[0;90m   To override, use: git commit --no-verify\033[0m"
  echo ""
  echo "\033[1;41;37m ✗ COMMIT REJECTED ✗ \033[0m"
  exit 1
elif [ "$mediumCount" -gt 0 ]; then
  echo "\033[1;33m⚠️  Medium severity issues detected ($mediumCount found). Consider fixing, but commit allowed.\033[0m"
  echo ""
  echo "\033[0;32m🎉 Commit approved with minor concerns!\033[0m"
  echo ""
  echo "\033[1;42;30m ✓ COMMIT WILL PROCEED ✓ \033[0m"
  exit 0
elif [ "$lowCount" -gt 0 ]; then
  echo "\033[0;32m✅ Minor improvements suggested ($lowCount found). Good code quality overall.\033[0m"
  echo ""
  echo "\033[0;32m🎉 Commit approved! Keep up the good coding practices!\033[0m"
  echo ""
  echo "\033[1;42;30m ✓ COMMIT WILL PROCEED ✓ \033[0m"
  exit 0
else
  # No issues found but also no explicit approval (shouldn't happen with updated prompt)
  echo "\033[0;32m✅ Code review completed. No blocking issues found.\033[0m"
  echo ""
  echo "\033[0;32m🎉 Commit approved! Keep up the good coding practices!\033[0m"
  echo ""
  echo "\033[1;42;30m ✓ COMMIT WILL PROCEED ✓ \033[0m"
  exit 0
fi
