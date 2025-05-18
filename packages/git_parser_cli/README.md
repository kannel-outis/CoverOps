# 🔍 Git Parser CLI

A CLI tool that parses Git diffs between branches and outputs a JSON map of modified lines—perfect for use in conjunction with coverage tools to highlight only changed lines of code.

This tool helps you generate `.gitparser.json` files that mark which lines of code have been modified in a given Git diff, making it easier to track test coverage on only the changes that matter.

---

## 🚀 Features

- ✅ Parses Git diffs between any two branches or commits
- 📄 Outputs a structured `.gitparser.json` file
- 🔍 Designed to work with **any project** (language/framework agnostic)
- 🔧 Easily pluggable into CI pipelines
- 🤝 Integrates well with code coverage tools for selective coverage analysis

---

## 📦 Installation

Clone the repository and run:

```bash
dart pub get
```

Make sure you have Dart installed. [Install Dart](https://dart.dev/get-dart) if needed.

---

## ⚙️ CLI Usage

```bash
dart run git_parser_cli.dart --targetBranch=master --sourceBranch=HEAD --outputDir=./output
```

This will output a `.gitparser.json` file to the `./output` directory with line-level modifications.

---

## 🧑‍💻 CLI Arguments

| Argument           | Alias | Description                                            | Default  |
| ------------------ | ----- | ------------------------------------------------------ | -------- |
| `--targetBranch`   | `-t`  | The Git branch to compare against                      | `master` |
| `--targetFallback` | `-a`  | A fallback branch if `--targetBranch` is not available | `main`   |
| `--sourceBranch`   | `-s`  | The source branch or commit to compare from            | `HEAD`   |
| `--projectPath`    | `-p`  | The root path of the Git project                       | `.`      |
| `--outputDir`      | `-o`  | Directory where `.gitparser.json` will be saved        | `.`      |

---

## 🧪 Example

Generate a diff file between `develop` and `main`:

```bash
dart run git_parser_cli.dart \
  --targetBranch=main \
  --sourceBranch=develop \
  --outputDir=./build
```

This will create:

```
./build/.gitparser.json
```

Containing a map of changed files and line numbers.

---

## 📁 Output Format

The generated `.gitparser.json` will contain a structure similar to:

```json
{
  "lib/file1.dart": [12, 13, 27],
  "lib/utils/helper.dart": [4, 5, 6]
}
```

This indicates which lines were modified per file.

---

## 🤝 Use with Coverage Tools

Pass the `.gitparser.json` file to tools that support per-line modified coverage. For example:

```bash
dart run lcov_cli.dart \
  --lcov=coverage/lcov.info \
  --gitParserFile=build/.gitparser.json \
  --output=report \
  --reportType=html
```


