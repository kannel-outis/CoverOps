# CoverOps 🚀

**Spot untested code like a pro with CoverOps — your go-to coverage companion for any project.**

CoverOps is a powerful, cross-platform CLI tool that helps you track test coverage on new or modified code. By combining Git diffs with LCOV or JSON coverage reports, it generates insightful **HTML**, **JSON**, and **console** reports that highlight what’s tested — and what’s not. Whether you’re building in Dart, Python, JavaScript, or anything else, CoverOps keeps your code accountable and clean.

---

## Why CoverOps?

* ✅ **Track New Code** – Pinpoints untested lines in changed or newly added code.
* 🔎 **Cross-language Coverage** – Supports any project using Git with LCOV or JSON coverage files.
* 🌐 **Multiple Report Formats** – Generates **HTML**, **JSON**, and **console** summaries.
* ⚡ **Lightweight & Fast** – Built with performance in mind.
* 🧩 **Plug & Play** – Use it directly or integrate into your CI pipeline.
* 🛠️ **Configurable** – Use a JSON config file to simplify complex commands.

---

## 📸 What It Looks Like

CoverOps highlights what’s tested — and what’s not — in your changed code.

![Screenshot 2025-05-17 at 9 30 28 PM](https://github.com/user-attachments/assets/16cca79b-dbd1-4847-beca-175f0aa6be4a) 
<video src='https://github.com/user-attachments/assets/54bfbeb0-9de4-4607-875e-ea3c9073bb3f' width=180/>

> ✅ **Green** = Covered lines in changed code
> ❌ **Red** = Missed lines in changed code
> 📄 **Grey** = Unchanged or ignored lines

### Clear, actionable insights:

* Track test coverage of **only new or modified code**.
* Works across languages (Dart, Python, JS, etc.).
* Easy-to-read, linkable **HTML reports**, machine-readable **JSON**, and quick **console** summaries.
* Supports multiple output formats: `html`, `json`, `console` — or even **all three at once**.
* Use a **JSON config file** for easy setup and reuse.

---

## Table of Contents

* [Quick Start](#quick-start)
* [What You Need](#what-you-need)
* [Installation](#installation)
* [Commands](#commands)
* [Report Types](#report-types)
* [Usage Example](#usage-example)
* [Script It Up](#script-it-up)
* [Contributing](#contributing)
* [License](#license)
* [Get in Touch](#get-in-touch)

---

## Quick Start

```bash
# Clone the repo
git clone https://github.com/kannel-outis/CoverOps.git
cd CoverOps

# Run coverage analysis
cover report --lcov=coverage/lcov.info --target-branch=main --source-branch=HEAD --output=coverage --report-format=html,console

# Or use a config file
cover report --config=config/coverops.json

# Open the HTML report
open file://$(pwd)/coverage/lcov_html/index.html
```

---

## What You Need

* **Git**: Required to detect changed files.
* **Coverage File**: LCOV (`lcov.info`) or JSON (`coverage-final.json`) from tools like `lcov`, `coverage.py`, or `jest`.
* **Optional – Dart SDK**: Only if you want to run it via `dart run`. Not required when using platform executables in [`bin/`](https://github.com/kannel-outis/CoverOps/tree/main/bin).

---

## Installation

### 🔧 Option 1: Use Prebuilt Executable (No Dart Required)

If your `bin/` folder already contains the appropriate `cover` binary for your platform, just run:

```bash
./install.sh # or (bash ./install.sh or zsh ./install.sh) to specify shell
```

This will:

* Ensure the `bin/` folder exists,
* Add it to your shell’s PATH (e.g., `.bashrc`, `.zshrc`, `.bash_profile`),
* Let you run `cover` from anywhere in your terminal.

After that, reload your shell:

```bash
source ~/.bashrc   # or ~/.zshrc or ~/.bash_profile
```

Now you can run:

```bash
cover --help # or cover -h
```

---

### 🛠 Option 2: Build Executable (Requires Dart SDK)

Want to build from source? Run:

```bash
./install.sh --build
```

This will:

* Detect your OS (Linux, macOS, or Windows),
* Build the `cover` binary using Dart,
* Set up your `bin/` directory for easy access.

Make sure the Dart SDK is installed and in your `PATH`. Get it here: [https://dart.dev/get-dart](https://dart.dev/get-dart)

---

## Commands

### `git`

Analyze code changes between branches.

```bash
cover git --target-branch=main --source-branch=feature-branch --output-dir=coverage
```

### `lcov`

Process LCOV or JSON coverage files and match against Git diff data.

```bash
cover lcov --lcov=coverage/lcov.info --gitParserFile=coverage/.gitparser.json --output=coverage
```

### `report`

Runs both `git` and `lcov` commands in one go.

```bash
cover report --lcov=coverage/lcov.info --target-branch=main --source-branch=feature-branch --output=coverage
```

You can also pass a config file instead of CLI arguments:

```bash
cover report --config=config/coverops.json
```

---

## Report Types

CoverOps supports **multiple report formats**, which can be combined with a comma-separated list.

| Format    | Description                                     |
| --------- | ----------------------------------------------- |
| `html`    | Fully styled, browsable report with annotations |
| `json`    | Structured, CI/CD-ready output                  |
| `console` | Human-readable summary printed to stdout        |

### Examples:

```bash
# Single format
cover report --report-format=html

# Multiple formats
cover report --report-format=html,console,json
```

Default format is `html` if none is specified.

---

## Configuration File Support

You can simplify command-line usage by placing arguments in a config file:

```bash
cover report --config=config/coverops.json
```

### Example `coverops.json`:

```json
{
  "lcov": "coverage/lcov.info"
  "targetBranch": "main"
  "sourceBranch": "HEAD"
  "output": "coverage"
  "reportFormat": ["html","console"]
}
```

Use this in scripts or CI for consistency and clarity.

---

## Usage Example

For different project types:

### Flutter

```bash
flutter test --coverage
lcov --remove coverage/lcov.info '*.g.dart' '*.part.dart' -o coverage/lcov.info
cover report --lcov=coverage/lcov.info --target-branch=main --output=coverage --report-format=html,console
```

### Python

```bash
pytest --cov=src --cov-report=lcov:coverage/lcov.info
cover report --lcov=coverage/lcov.info --target-branch=main --output=coverage --report-format=html
```

### JavaScript

```bash
jest --coverage --coverageReporters=json
cover report --lcov=coverage/coverage-final.json --target-branch=main --output=coverage --report-format=console
```

---

## Script It Up

Want to automate the workflow? Here's a generic script example for any project type:

```bash
#!/bin/bash
# run_coverops.sh

# Optional: Ensure coverage directory is ignored
item="coverage/"
if [ ! -f .gitignore ] || ! grep -q "^$item" .gitignore; then
  echo "$item" >> .gitignore
  echo "Added '$item' to .gitignore"
fi

# Run your own coverage command here
echo "Run your test suite and generate LCOV/JSON coverage..."
# Example: pytest --cov=src --cov-report=lcov:coverage/lcov.info

# Option 1: CLI flags
cover report --lcov=coverage/lcov.info --target-branch=main --source-branch=HEAD --output=coverage --report-format=html,console,json

# Option 2: Config file
# cover report --config=config/coverops.yaml

# Open the HTML report
report_path="coverage/lcov_html/index.html"
if [ -f "$report_path" ]; then
  echo "Coverage report generated at: file://$PWD/$report_path"
  read -p "Open report in browser? (y/n): " choice
  if [[ "$choice" == "y" ]]; then
    open "file://$PWD/$report_path"
  fi
else
  echo "Report not found at $report_path"
fi
```

Make executable:

```bash
chmod +x run_coverops.sh
./run_coverops.sh
```

---

## Contributing

We welcome contributions of all kinds!

1. Fork the repo
2. Create a feature branch
3. Use [Conventional Commits](https://www.conventionalcommits.org/)
4. Test your changes
5. Submit a pull request

---

## License

CoverOps is licensed under the [MIT License](LICENSE).

---

## Get in Touch

* [GitHub Issues](https://github.com/kannel-outis/CoverOps/issues)
* Maintainer: [kannel-outis](https://github.com/kannel-outis)

---

**CoverOps helps you keep your codebase covered, clean, and deployment-ready.** 💪
