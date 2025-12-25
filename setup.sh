#!/bin/bash
# setup.sh

read -p "please enter your git root path: " GIT_ROOT_PATH

echo "Installing Ollama Git hooks..."

# Create symlinks from the repo's hooks folder to the actual git hooks folder
ln -sf ./hooks/pre-commit $GIT_ROOT_PATH/.git/hooks/pre-commit
ln -sf ./hooks/prepare-commit-msg $GIT_ROOT_PATH/.git/hooks/prepare-commit-msg

# Ensure they are executable
chmod +x hooks/*

echo "Hooks installed! Make sure Ollama is running with 'ollama serve'."
