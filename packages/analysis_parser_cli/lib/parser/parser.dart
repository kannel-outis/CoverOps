import 'dart:async';

import 'package:analysis_parser_cli/models/file.dart';
import 'package:analysis_parser_cli/parser/analysis_line_parser.dart';
import 'package:analysis_parser_cli/parser/config.dart';

/// Base class for all analyzer output parsers.
///
/// A [Parser] is responsible for executing an analyzer command,
/// streaming its output, and returning a list of parsed results.
///
/// Concrete implementations (e.g. `AnalysisParser`) handle the
/// process I/O and file grouping logic, while the `lineParser`
/// handles the language-specific line matching.
///
/// Example:
/// ```dart
/// final parser = AnalysisParser(config: AnalyzerConfig(command: 'dart analyze'));
/// final files = await parser.parse();
/// print('Found ${parser.totalAnalysisFound} issues');
/// ```
abstract class Parser {
  Parser({required this.config});

  /// Total number of parsed analysis results across all files.
  int totalAnalysisFound = 0;

  /// Configuration containing the analyzer command and line parser.
  final AnalyzerConfig config;

  /// Splits a command string into executable + arguments.
  ///
  /// Supports quoted segments, allowing paths with spaces:
  /// `"flutter analyze --write=out.json" "/Users/me/My Project/lib"`
  final RegExp _regex = RegExp(r'''(['"])(.*?)\1|(\S+)''');

  /// The parsed command as a list. Example:
  ///
  /// `'dart analyze lib'` → `['dart', 'analyze', 'lib']`
  List<String> get commands {
    return _regex.allMatches(config.command).map((m) {
      return m.group(2) ?? m.group(3) ?? '';
    }).toList();
  }

  /// Language-specific parser used to interpret individual lines.
  AnalysisLineParser get lineParser => config.parser;

  /// Starts the parsing process and returns analyzed files.
  FutureOr<List<AnalysisFile>> parse();
}
