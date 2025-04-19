import 'dart:async';
import 'dart:convert';
import 'dart:io' hide exitCode;
import 'dart:math';

import 'package:git_parser_cli/models/git_file.dart';
import 'package:git_parser_cli/parser/git_parser.dart';
import 'package:git_parser_cli/utils/utils.dart';

/// A parser for Git `diff` output, used to compare files between branches.
///
/// This class takes a source branch and an optional target and fallback branch,
/// then parses the diff output to extract modified files and their content.
///
/// The parsing is based on Git's standard diff output, where each diff segment
/// starts with a file path and includes line-level changes.
class GitDiffParser extends GitParser<List<GitFile>> {
  /// The target branch to compare against. This is optional and if not provided,
  /// the fallback branch will be used for comparison.
  final String? targetBranch;

  /// The branch from which to compare changes.
  final String sourceBranch;

  /// A fallback branch in case the diff with [targetBranch] fails.
  final String? fallbackBranch;

  /// The project directory where the Git repository is located.
  final String projectDir;

  /// Creates an instance of `GitDiffParser`.
  ///
  /// The [projectDir] is the directory of the Git repository.
  /// The [sourceBranch] is mandatory, while [targetBranch] and [fallbackBranch]
  /// are optional branches to be used for comparison.
  GitDiffParser({
    required this.projectDir,
    required this.sourceBranch,
    this.targetBranch,
    this.fallbackBranch,
  });

  /// A list of parsed `GitFile` objects that hold the diff output.
  final List<GitFile> _files = [];

  /// Holds the current file path being parsed.
  String? _currentFilePath;

  /// A list of content lines (differences) for the currently parsed file.
  final _content = <GitLine>[];

  /// Line number from the left side (removal side) of the diff segment.
  int _leftLineNumber = 0;

  /// Line number from the right side (addition side) of the diff segment.
  int _rightLineNumber = 0;

  /// Indicates whether the parser is currently reading the content of a file.
  bool _isReadingContent = false;

  /// Parses the Git diff output for the specified branches and returns a list of [GitFile] objects.
  ///
  /// This method compares the source branch against the target branch (or fallback branch if necessary),
  /// collects file changes, and stores them in the [_files] list.
  ///
  /// Returns a [Future] containing the list of parsed `GitFile` objects.
  @override
  Future<List<GitFile>> parse() async {
    // Construct the diff command for the target and fallback branches
    final command = ['diff', '$targetBranch..$sourceBranch'];
    final fallBack = ['diff', '$fallbackBranch..$sourceBranch'];

    // Run the Git command and fallback if necessary
    await _runGitCommand(command, fallbackCommand: fallBack);

    // If there is an unprocessed file, add it to the list of files
    if (_currentFilePath != null && _content.isNotEmpty) {
      _files.add(GitFile(path: _currentFilePath ?? '', content: List.of(_content)));
    }

    return _files;
  }

  /// Parses a line of the Git diff output.
  ///
  /// This method processes various line types from the diff output, including
  /// file paths, line numbers, and actual content changes (additions, removals, or unchanged lines).
  ///
  /// The parsed data is stored in [_content] and each file's changes are added to [_files].
  void _parseLine(String line) {
    if (_deletedFileLine(line)) return;

    // Start of a new diff segment
    if (line.startsWith('diff --git')) {
      if (_currentFilePath != null && _content.isNotEmpty && _isReadingContent) {
        _files.add(GitFile(path: _currentFilePath ?? '', content: List.of(_content)));
        _content.clear();
      }
      _isReadingContent = false;
    } else if (line.startsWith('--- a/')) {
      // Old file path (not needed)
    } else if (line.startsWith('+++ b/')) {
      // New file path
      _currentFilePath = line.replaceFirst('+++ b/', '');
      _leftLineNumber = 0;
      _rightLineNumber = 0;
      _isReadingContent = true;
    } else if (RegExp(r'^@@ -([0-9]+),[0-9]+ \+([0-9]+),[0-9]+ @@').hasMatch(line)) {
      // Diff line containing line numbers
      final match = RegExp(r'^@@ -([0-9]+),[0-9]+ \+([0-9]+),[0-9]+ @@').firstMatch(line);
      if (match != null) {
        _leftLineNumber = int.parse(match.group(1)!);
        _rightLineNumber = int.parse(match.group(2)!);
      }
      _content.add(GitLine(lineContent: line, lineNumber: (Random().nextInt(40000) + 70000).toString()));
    } else if (line.startsWith('-')) {
      // Removed line
      _content.add(GitLine(lineContent: line, lineNumber: _leftLineNumber.toString()));
      _leftLineNumber++;
    } else if (line.startsWith('+')) {
      // Added line
      _content.add(GitLine(lineContent: line, lineNumber: _rightLineNumber.toString()));
      _rightLineNumber++;
    } else if (line.startsWith(' ')) {
      // Unchanged line
      _content.add(GitLine(lineContent: line, lineNumber: _rightLineNumber.toString()));
      _leftLineNumber++;
      _rightLineNumber++;
    }
  }

  /// Runs a Git command and retries with a fallback command if the initial command fails.
  ///
  /// The [command] parameter specifies the Git command to run, while [fallbackCommand]
  /// is used as a fallback if the original command fails due to a missing revision or path.
  ///
  /// Returns a [Future] that completes with the `Process` object once the command succeeds or fails.
  Future<Process> _runGitCommand(List<String> command, {List<String>? fallbackCommand}) async {
    final process = await Process.start(
      'git',
      command,
      runInShell: true,
      workingDirectory: projectDir,
    );

    final errorOutput = <String>[];

    // Capture stderr to detect errors
    process.stderr.transform(utf8.decoder).transform<String>(const LineSplitter()).listen((line) {
      errorOutput.add(line);
    });

    // Process stdout lines and parse each one
    process.stdout.transform(utf8.decoder).transform<String>(const LineSplitter()).listen(_parseLine);

    final exitCode = await process.exitCode;
    final unKnownError = errorOutput.any((line) => line.contains('unknown revision or path not in the working tree'));

    // Retry with fallback command if the first one fails
    if (exitCode != 0 && errorOutput.isNotEmpty && fallbackCommand != null && unKnownError) {
      exitWithMessage("Git command failed. Retrying with fallback command: git ${fallbackCommand.join(' ')}", shouldExit: false);
      return await _runGitCommand(fallbackCommand);
    } else if (exitCode != 0) {
      final buffer = StringBuffer()..writeAll(errorOutput, '\n');
      if (unKnownError) {
        buffer.write('\n');
        buffer.write('Please provide a valid branch name or commit hash. You can also provide a fallback branch name.');
      }
      exitWithMessage(buffer.toString(), shouldExit: true);
    }

    return process;
  }

  /// Detects if the line indicates a deleted file in the diff output.
  ///
  /// The line is considered a deleted file if it matches the `/dev/null` pattern.
  /// Returns `true` if the line matches the pattern, otherwise returns `false`.
  bool _deletedFileLine(String line) {
    return RegExp(r'^\+\+\+ \/dev\/null$').hasMatch(line);
  }

  /// Navigates to the project directory and lists its contents using `ls -l`.
  ///
  /// This method demonstrates running a simple shell command within the project's directory.
  Future<void> gotoDirectory() async {
    final process = await Process.start('ls', ['-l'], workingDirectory: projectDir, runInShell: true);
    await process.exitCode;
  }
}
