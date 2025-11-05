import 'package:analysis_parser_cli/models/file.dart';
import 'package:analysis_parser_cli/utils/enums.dart';

/// Base class for all per-line analyzer output parsers.
///
/// An [AnalysisLineParser] is responsible for interpreting a single line
/// of analyzer output and deciding whether it represents:
///
/// * a new file start (`parseFileName`)
/// * a completed parsed analysis entry (`parseLine`)
/// * or neither (returns `null`)
///
/// Implementations may optionally support multiline parsing if a single
/// analysis entry spans multiple lines (e.g. Java, Python).
///
/// The parser itself does **not** handle file grouping or state — that is
/// the responsibility of [Parser]. This class is only concerned with
/// understanding what a *single line* means.
///
/// Example use inside a stream parser:
///
/// ```dart
/// final file = lineParser.parseFileName(line);
/// final entry = lineParser.parseLine(line);
/// ```
///
/// If you need to buffer lines before producing a parsed entry, override
/// [supportsMultiline] and manage internal state until `parseLine` can return
/// a completed `AnalysisLine`.
abstract class AnalysisLineParser {
  /// Returns a file path if the given line indicates a new file section,
  /// otherwise returns `null`.
  ///
  /// Example output:
  /// ```
  /// lib/foo.dart:10:3 • Something happened
  /// ```
  String? parseFileName(String line) => null;

  /// Parses a single analyzer output line and returns an [AnalysisLine]
  /// when the line contains a complete parsed item. Returns `null` if the
  /// line is either irrelevant or incomplete (for multiline parsers).
  AnalysisLine? parseLine(String line);

  /// Whether this parser requires multiple lines to form a full entry.
  ///
  /// If `true`, the caller should continue feeding lines until `parseLine`
  /// returns a non-null value.
  bool get supportsMultiline => false;


  AnalysisLine? flush() => null;
}

/// Parses output from `dart analyze`.
///
/// Example:
/// `warning • lib/foo.dart:10:3 • Unused import • unused_import`
class DartAnalysisLineParser extends AnalysisLineParser {
  final _pattern = RegExp(
    r'^(info|warning|error|hint)\s+-\s+(.+?):(\d+):(\d+)\s+-\s+(.*?)(?:\s+-\s+([\w\-_]+))?$',
  );

  RegExpMatch? _match(String line) => _pattern.firstMatch(stripAnsi(line.trim()));

  String stripAnsi(String input) => input.replaceAll(RegExp(r'\x1B\[[0-9;]*m'), '');

  @override
  String? parseFileName(String line) => _match(line)?.group(2);

  @override
  AnalysisLine? parseLine(String line) {
    final m = _match(line);
    if (m == null) return null;

    return AnalysisLine(
      type: AnalysisType.fromString(m.group(1)),
      lineNumber: int.tryParse(m.group(3) ?? '') ?? 0,
      columnNumber: int.tryParse(m.group(4) ?? '') ?? 0,
      message: m.group(5) ?? '',
      rule: m.group(6),
    );
  }
}

//Python
class PythonAnalysisLineParser extends AnalysisLineParser {
  // Matches: file:line:col: CODE: message (rule)
  final _singlePattern = RegExp(
    r'^(.+?):(\d+):(\d+):\s+([A-Z]\d+):\s+(.*?)(?:\s+\((.+)\))?$',
  );

  // Pylint module header, marks context but isn't an issue line
  final _moduleHeader = RegExp(r'^\*{5,}\s+Module\s+(.+)$');

  // Used to detect file boundary
  @override
  String? parseFileName(String line) {
    final m = _singlePattern.firstMatch(line);
    return m?.group(1);
  }

  @override
  bool get supportsMultiline => true;

  @override
  AnalysisLine? parseLine(String line) {
    // Skip pylint headers
    if (_moduleHeader.hasMatch(line)) return null;

    final m = _singlePattern.firstMatch(line);
    if (m == null) return null;

    final type = _mapCodeToType(m.group(4)!);
    return AnalysisLine(
      type: type,
      message: m.group(5) ?? '',
      lineNumber: int.parse(m.group(2)!),
      columnNumber: int.parse(m.group(3)!),
      rule: m.group(6),
    );
  }

  AnalysisType _mapCodeToType(String code) {
    switch (code[0]) {
      case 'E':
      case 'F':
        return AnalysisType.error;
      case 'W':
        return AnalysisType.warning;
      case 'C':
      case 'R':
        return AnalysisType.info;
      default:
        return AnalysisType.hint;
    }
  }
}


//JS
class JsAnalysisLineParser extends AnalysisLineParser {
  /// Matches file headers like:
  ///   src/app.js
  ///   ./lib/index.ts
  ///   packages/core/src/util/helper.jsx
  ///
  /// Supports: dots, slashes, dashes, @scoped folders, spaces.
  final _filePattern = RegExp(
    r'^[^:*?"<>|]+\.(js|jsx|ts|tsx)$',
  );

  /// Matches ESLint issue lines like:
  ///   "  10:5  error  Unexpected console statement  no-console"
  final _issuePattern = RegExp(
    r'^\s*(\d+):(\d+)\s+(error|warning)\s+(.*?)\s{2,}([\w\-/@]+)$',
  );

  AnalysisLine? _pendingIssue;

  @override
  bool get supportsMultiline => true;

  @override
  String? parseFileName(String line) {
    if (_filePattern.hasMatch(line.trim())) {
      return line.trim();
    }
    return null;
  }

  @override
  AnalysisLine? parseLine(String line) {
    final match = _issuePattern.firstMatch(line);

    // ✅ If this line starts a new issue
    if (match != null) {
      // If we had a pending multiline issue, flush it first
      final flushed = _pendingIssue;
      _pendingIssue = AnalysisLine(
        type: match.group(3) == 'error'
            ? AnalysisType.error
            : AnalysisType.warning,
        message: '${match.group(1)}:${match.group(2)}  ${match.group(3)}  ${match.group(4)}  ${match.group(5)}',
        lineNumber: int.parse(match.group(1)!),
        columnNumber: int.parse(match.group(2)!),
        rule: match.group(5),
      );
      return flushed;
    }

    // ✅ Continuation of previous issue (indented, not blank, not file header)
    if (_pendingIssue != null && line.trimLeft() != line) {
      _pendingIssue = _pendingIssue!.copyWith(
        message: '${_pendingIssue!.message}\n${line.trim()}',
      );
      return null;
    }

    // ✅ No match, no continuation
    return null;
  }

  /// Call this when switching files or finishing parsing
  @override
  AnalysisLine? flush() {
    final flushed = _pendingIssue;
    _pendingIssue = null;
    return flushed;
  }
}
