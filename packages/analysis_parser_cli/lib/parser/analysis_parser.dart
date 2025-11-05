import 'dart:async';
import 'dart:io';

import 'package:analysis_parser_cli/models/file.dart';
import 'package:analysis_parser_cli/parser/parser.dart';
import 'package:analysis_parser_cli/utils/extensions.dart';
import 'package:collection/collection.dart';
import 'package:process/process.dart';


/// Parses analyzer output line-by-line and groups results by file.
///
/// This parser streams stdout from the analyzer process, detects when
/// a new file begins, and buffers the lines belonging to that file
/// until either a file switch occurs or the stream ends.
///
/// Typical usage:
///
/// ```dart
/// final parser = AnalysisParser(
///   config: AnalysisConfig(args: ['--fatal-infos']),
///   projectDir: './',
/// );
///
/// final results = await parser.parse();
/// for (final file in results) {
///   print('${file.path} → ${file.lines.length} issues');
/// }
/// ```
class AnalysisParser extends Parser {
  AnalysisParser({required super.config});

  /// Tracks the file currently being parsed (as reported by the line parser).
  String? _currentFile;

  /// Buffered lines belonging to the current file.
  final List<AnalysisLine> _currentFileLines = [];

  /// Final collection of parsed files. Uses a [Set] to avoid duplicates.
  final Set<AnalysisFile> files = {};

  /// Pushes the currently buffered file and its lines into [files].
  ///
  /// If the file already exists in the set, the new lines are merged.
  /// Clears the internal buffer after flushing.
  void _flushCurrentFile() {
    if (_currentFile == null || _currentFileLines.isEmpty) return;

    final existing = files.firstWhereOrNull((f) => f.path == _currentFile);

    if (existing != null) {
      final merged = existing.copyWith(
        lines: [...existing.lines, ..._currentFileLines],
      );
      files
        ..remove(existing)
        ..add(merged);
    } else {
      files.add(
        AnalysisFile(path: _currentFile!, lines: [..._currentFileLines]),
      );
    }

    totalAnalysisFound += _currentFileLines.length;
    _currentFileLines.clear();
  }

  /// Runs the analyzer command, streams its output, and returns parsed results.
  ///
  /// Returns a list of [AnalysisFile] objects grouped by file path.
  /// If the analyzer exits with a non-zero exit code and produces stderr,
  /// the process terminates and prints the collected error output.
  @override
  Future<List<AnalysisFile>> parse() async {
    final process = await Process.instance.start(
      commands.first,
      [...commands.sublist(1), ...config.arguments],
      workingDirectory: config.workingDirectory,
    );

    final errors = <String>[];

    final stdoutDone = process.stdout.splitForEach(_parseLine);
    final stderrDone = process.stderr.splitForEach(errors.add);

    await Future.wait([stdoutDone, stderrDone]);

    //Flush final file
    _flushCurrentFile();

    final exitCode = await process.exitCode;

    if (exitCode != 0 && errors.isNotEmpty) {
      stderr.writeln(errors.join('\n'));
      exit(exitCode);
    }

    return files.toList();
  }

  /// Parses a single analyzer line, detects file switches, and buffers content.
  void _parseLine(String line) {
    final detectedFile = lineParser.parseFileName(line);

    if (detectedFile != null && detectedFile != _currentFile) {
      _flushCurrentFile();
      _currentFile = detectedFile;
    }

    final parsed = lineParser.parseLine(line);
    if (parsed != null) {
      _currentFileLines.add(parsed);
    }
  }
}
