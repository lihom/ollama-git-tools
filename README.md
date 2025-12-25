# Ollama Git Tools: Local AI-Powered Git Hooks

**Ollama Git Tools** brings the power of Large Language Models (LLMs) directly into your local development workflow. By leveraging **Ollama** and **gemma3**, this repository provides automated code reviews and commit message generation—all running 100% on your machine. No APIs, no tokens, and no code ever leaves your computer.

---

## ✨ Features

* **AI Code Review (`pre-commit`):** Automatically analyzes your staged changes for bugs, security risks, and code smells before you commit.
* **Auto-Commit Messages (`prepare-commit-msg`):** Drafts high-quality, Conventional Commit messages based on your `git diff`.
* **Privacy First:** Everything runs locally via Ollama.
* **Human-in-the-Loop:** The AI suggests, but you always have the final say (edit the message or bypass the review).

---

## 🚀 Getting Started

### 1. Prerequisites
* **Git:** Installed and configured.
* **Ollama:** [Download and install Ollama](https://ollama.com/).
* **Model:** Pull the recommended model (lightweight and fast):
    ```bash
    ollama pull gemma3
    ```

### 2. Installation
Clone this repository and run the setup script to link the hooks to your current project.

```bash
git clone [https://github.com/lihom/ollama-git-tools.git](https://github.com/lihom/ollama-git-tools.git)
cd ollama-git-tools
chmod +x setup.sh
./setup.sh

```

> **Note:** The `setup.sh` script creates symbolic links from `.git/hooks/` to the `hooks/` directory in this repo.

---

## 🛠️ Usage

### Automated Code Review

When you run `git commit`, the `pre-commit` hook triggers. gemma3 will scan your diff:

* If it finds issues, it will prompt: `AI found potential issues. Commit anyway? (y/n)`
* If it passes, it proceeds to the next step.

### AI Commit Drafting

If the review passes (or you bypass it), your text editor will open with a pre-filled commit message like:
`feat: add user authentication logic to login controller`

Simply save and exit to finish the commit.

---

## ⚙️ Configuration

You can customize the AI's behavior by editing the scripts in the `hooks/` folder:

| Script | Purpose | Model Used |
| --- | --- | --- |
| `pre-commit` | Reviewing code for bugs | `gemma3` |
| `prepare-commit-msg` | Writing the commit summary | `gemma3` |

---

## 🤝 Contributing

Found a way to make the prompts better? Open a Pull Request! I'm always looking to improve the "senior developer" persona of the AI.

## 📄 License

MIT