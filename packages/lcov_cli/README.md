
# 📊 LCOV Cli Coverage Reporter

A CLI tool to generate **test coverage reports** (HTML, JSON, or Console) from LCOV or JSON files. It also supports showing coverage **on modified lines**.

Designed to work with **any programming language or project** — as long as coverage data is provided.

---

## ✨ Features

- ✅ Supports **LCOV** and **JSON** coverage formats
- 📄 Outputs **HTML**, **JSON**, and **Console** reports
- 🔍 Highlights **coverage on modified lines** via Git diff
- 🧩 Works in any language, framework, or CI environment
- ⚡ CLI-first, composable, and easily scriptable

---

## 🚀 Getting Started

### Prerequisites

- Dart SDK installed (used to run the tool)
- A valid coverage file (`lcov.info` or structured JSON)

---

## ⚙️ Usage

```bash
dart run bin/main.dart [options]
```

### CLI Options

| Option            | Abbr | Description                                          |
| ----------------- | ---- | ---------------------------------------------------- |
| `--lcov`          | `-l` | Path to the LCOV coverage file                       |
| `--json`          | `-j` | Path to the JSON coverage file (alternative to LCOV) |
| `--output`        | `-o` | Output directory for generated reports               |
| `--projectPath`   | `-p` | Path to the root of the project                      |
| `--gitParserFile` | `-g` | Path to Git diff file in JSON format (optional)      |
| `--reportType`    | `-r` | Comma-separated list: `html`, `json`, `console`      |

---

## 📦 Examples

### Generate All Reports

```bash
dart run bin/main.dart \
  --lcov coverage/lcov.info \
  --output coverage_report \
  --reportType html,json,console
```

### Use JSON Coverage + Git Diff

```bash
dart run bin/main.dart \
  --json build/coverage.json \
  --gitParserFile git_diff.json \
  --output out \
  --reportType json
```

### Console Report Only

```bash
dart run bin/main.dart \
  --lcov coverage/lcov.info \
  --output ./out \
  --reportType console
```

---

## 📁 Report Output Types

| Type    | Description                                 |
| ------- | ------------------------------------------- |
| HTML    | Visual, browser-viewable interactive report |
| JSON    | Machine-readable format for automation/CI   |
| Console | Simple table printed to the terminal        |

---

## 🛠 How It Works

1. Parses LCOV/JSON test coverage
2. Optionally parses Git diff data
3. Computes per-file, per-line coverage metrics
4. Outputs the report in chosen format(s)

---

## 🧠 Internals

* **ArgumentSettings**: Parses and validates CLI options
* **LcovCli**: Orchestrates coverage processing and report generation
* **ReportGenerator**: Strategy interface for different output types
* **LineParser**: Parses raw coverage into logical line units
* **CodeCoverageFileParser**: Merges raw + diff data for enriched reporting

---

## 🤝 Contributing

All contributions welcome! Whether it's bug fixes, new features, or docs — open a PR or file an issue.
