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

### 🚦 Severity Definitions

To ensure consistent reviews, the AI flags issues based on the following criteria:

| Level | Definition | Examples |
| --- | --- | --- |
| **P0 (Critical)** | **Must Fix.** Blocks commit. Security risks or logic that crashes the app. | Hardcoded API keys, SQL injection, null pointer risks, infinite loops. |
| **P1 (High)** | **Should Fix.** Highly recommended to resolve before pushing. | Breaking naming conventions, lack of error handling, redundant heavy loops. |
| **P2 (Minor)** | **Suggestion.** Does not block commit. | Typo in comments, slightly better way to write a function, style nits. |

### AI Code Review (`pre-commit`)

When you run `git commit`, AI analyzes your changes. If the AI detects **P0 / P1 issues**, the commit is automatically **aborted**.

* **To proceed:** Fix the identified issues and commit again.
* **To bypass:** Run `git commit --no-verify` to skip the AI review entirely.

### AI Commit Drafting (`prepare-commit-msg`)

If the review passes (or you bypass it), your text editor will open with a pre-filled commit message like:
`feat: add user authentication logic to login controller`

Simply save and exit to finish the commit.

### Manual Review Scripts

You can run a review or draft a commit message at any time without starting the actual commit process:

| Script | Command | Purpose |
| --- | --- | --- |
| **Code Review** | `./scripts/ollama_review.sh` | Analyzes **staged** files for bugs and P0 / P1 issues. |
| **Draft Commit** | `./scripts/ollama_commit.sh` | Generates a **Conventional Commit** message based on staged changes. |

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