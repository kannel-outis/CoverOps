# CoverOps 🚀

**Spot untested code like a pro with CoverOps — your go-to coverage companion for any project.**

CoverOps is a powerful, cross-platform CLI tool that helps you track test coverage on new or modified code. By combining Git diffs with LCOV or JSON coverage reports, it generates insightful HTML reports that highlight what’s tested — and what’s not. Whether you’re building in Dart, Python, JavaScript, or anything else, CoverOps keeps your code accountable and clean.

---

## Why CoverOps?

* ✅ **Track New Code** – Pinpoints untested lines in changed or newly added code.
* 🔎 **Cross-language Coverage** – Supports any project using Git with LCOV or JSON coverage files.
* 🌐 **Visual Reports** – Generates clean, browsable HTML reports.
* ⚡ **Lightweight & Fast** – Built with performance in mind.
* 🧩 **Plug & Play** – Use it directly or integrate into your CI pipeline. *(coming soon)*

---

## Table of Contents

* [Quick Start](#quick-start)
* [What You Need](#what-you-need)
* [Installation](#installation)
* [Commands](#commands)
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
bin/cover_ops.dart run --lcov coverage/lcov.info --target-branch main --source-branch HEAD --output coverage

# Open the report
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


Make sure the Dart SDK is installed and in your `PATH`. Check out the dart home page to get started: [https://dart.dev/get-dart](https://dart.dev/get-dart)
*Follow Option 1 for installation instructions when done.*

---

## Commands

### `git`

Analyze code changes between branches.

```bash
cover git --target-branch main --source-branch feature-branch --output-dir coverage
```

### `lcov`

Process LCOV or JSON coverage files and match against Git diff data.

```bash
cover lcov --lcov coverage/lcov.info --gitParserFile coverage/.gitparser.json --output coverage
```

### `run`

Runs both `git` and `lcov` commands in one go.

```bash
cover report --lcov coverage/lcov.info --target-branch main --source-branch feature-branch --output coverage
```

---

## Usage Example

For different project types:

### Flutter

```bash
flutter test --coverage
lcov --remove coverage/lcov.info '*.g.dart' '*.part.dart' -o coverage/lcov.info
cover report --lcov coverage/lcov.info --target-branch main --output coverage
```

### Python

```bash
pytest --cov=src --cov-report=lcov:coverage/lcov.info
cover report --lcov coverage/lcov.info --target-branch main --output coverage
```

### JavaScript

```bash
jest --coverage --coverageReporters=json
cover report --json coverage/coverage-final.json --target-branch main --output coverage
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

# Run CoverOps
cover report --lcov coverage/lcov.info --target-branch main --source-branch HEAD --output coverage

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

Please follow the [Code of Conduct](CODE_OF_CONDUCT.md) and [Style Guide](STYLE_GUIDE.md).

---

## License

CoverOps is licensed under the [MIT License](LICENSE).

---

## Get in Touch

* [GitHub Issues](https://github.com/kannel-outis/CoverOps/issues)
* Maintainer: [kannel-outis](https://github.com/kannel-outis)

---

**CoverOps helps you keep your codebase covered, clean, and deployment-ready.** 💪
