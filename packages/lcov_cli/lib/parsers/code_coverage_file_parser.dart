// Import necessary libraries
import 'dart:async';
import 'dart:io';

import 'package:lcov_cli/models/code_file.dart';
import 'package:lcov_cli/models/lcov_file_group.dart';
import 'package:lcov_cli/models/line.dart';
import 'package:lcov_cli/parsers/line_parser.dart';

/// CodeCoverageFileParser class
///
/// This class is responsible for parsing code coverage files and optionally
/// modified files, and then merging them into a list of CodeFile objects.
/// It extends the LineParser class to inherit parsing behavior.
class CodeCoverageFileParser extends LineParser {
  // List of code files that have been modified (if any).
  final List<CodeFile>? modifiedCodeFiles;

  // List of code files containing coverage information.
  final List<CodeFile> coverageCodeFiles;

  /// Constructor for CodeCoverageFileParser
  ///
  /// [modifiedCodeFiles]: A list of files that have been modified (can be null).
  /// [coverageCodeFiles]: A list of files with code coverage data.
  CodeCoverageFileParser({required this.modifiedCodeFiles, required this.coverageCodeFiles});

  /// Parses the lines of code in the provided coverage files and modified files (if any).
  ///
  /// Returns a list of CodeFile objects with parsed information about each line,
  /// including whether the line was hit, modified, and the hit count.
  ///
  /// [rootPath] (optional): The root path for files, not used directly in this method.
  @override
  FutureOr<List<CodeFile>> parsedLines([String? rootPath]) {
    // Extract paths from coverage files.
    final fileRootPath = rootPath != null ? '$rootPath/' : '';

    // Returns the relative file path or the original path with root path prepended if no root path is found.
    String getLcovFilePath(String path) => path.contains(fileRootPath) ? path : fileRootPath + path;
    final filePaths = coverageCodeFiles.map((file) => getLcovFilePath(file.path)).toList();

    final codeFiles = <CodeFile>[];

    final fileGroups = filePaths.map((path) {
      return FileGroup(
        content: _parseFileContentIntoLines(File(path)),
        filePath: path,
      );
    }).toList();

    // Map of modified files by file path (if any modified files are provided).
    final modifiedFilesByPath = {for (var file in modifiedCodeFiles ?? <CodeFile>[]) file.path: file};

    // Map of coverage files by file path.
    final coverageFilesByPath = {for (var file in coverageCodeFiles) getLcovFilePath(file.path): file};

    // Process each file group (coverage files).
    for (var group in fileGroups) {
      final fileLines = <Line>[];

      // Map lines in the coverage file by line number.
      final coverageLinesByNumber = {for (var line in coverageFilesByPath[group.filePath]?.codeLines ?? <Line>[]) line.lineNumber: line};

      // Map modified lines by line number (if the file has been modified).
      final modifiedLinesByNumber = {for (var line in modifiedFilesByPath[group.filePath]?.codeLines ?? <Line>[]) line.lineNumber: line};

      for (var i = 0; i < group.content.length; i++) {
        final index = i + 1; // Line number (1-based index).

        // Create a Line object with the necessary metadata (coverage and modification details).
        fileLines.add(
          Line(
            lineNumber: index,
            lineContent: group.content[i],
            canHitLine: coverageLinesByNumber[index]?.canHitLine ?? false,
            hitCount: coverageLinesByNumber[index]?.hitCount ?? 0,
            isLineHit: coverageLinesByNumber[index]?.isLineHit ?? false,
            isModified: modifiedLinesByNumber[index]?.isModified ?? false,
          ),
        );
      }

      codeFiles.add(CodeFile(path: group.filePath, codeLines: fileLines));
    }

    return codeFiles;
  }

  /// Helper method to read the file content and split it into individual lines.
  ///
  /// [file]: The File object to read.
  /// Returns a list of strings, where each string represents a line in the file.
  List<String> _parseFileContentIntoLines(File file) {
    // Check if the file exists, read its content, and split it into lines.
    // If the file doesn't exist, return an empty list.
    return file.existsSync() ? file.readAsStringSync().split('\n') : [];
  }
}
