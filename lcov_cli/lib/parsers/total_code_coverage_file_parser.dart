import 'dart:async';

import 'package:lcov_cli/models/code_file.dart';
import 'package:lcov_cli/models/line.dart';
import 'package:lcov_cli/parsers/line_parser.dart';

/// A parser class that processes original code files by augmenting them with
/// coverage and line change information from coverage data and optionally JSON code files.
/// The result is a list of `CodeFile` objects that contain coverage and change data for each line.
@Deprecated('Use CodeCoverageFileParser instead')
class TotalCodeCoverageFileParser extends LineParser {
  /// Creates a new instance of [TotalCodeCoverageFileParser].
  ///
  /// The parser requires a list of [coverageCodeFiles] containing code coverage data,
  /// a list of [originalCodeFiles] which holds the original source files, and an optional
  /// list of [jsonCodeFiles] that may provide information about line changes (e.g., from a git diff).
  TotalCodeCoverageFileParser({
    required this.coverageCodeFiles,
    required this.originalCodeFiles,
    this.jsonCodeFiles,
  });

  /// A list of code files containing Coverage data for code coverage analysis.
  final List<CodeFile> coverageCodeFiles;

  /// A list of the original code files to be parsed.
  final List<CodeFile> originalCodeFiles;

  /// An optional list of code files containing data about which lines have changed (e.g., from git).
  final List<CodeFile>? jsonCodeFiles;

  /// Parses the lines of the original code files and returns a list of [CodeFile] objects
  /// with coverage and line change information.
  ///
  /// Each original file is paired with its corresponding coverage and JSON data (if available),
  /// and each line in the original file is augmented with coverage (hit count, whether it's hit or not)
  /// and line change information (whether it's a new or changed line).
  ///
  /// - [rootPath] is an optional parameter for specifying the root directory for the files.
  @override
  FutureOr<List<CodeFile>> parsedLines([String? rootPath]) {
    final results = <CodeFile>[];

    // Create a map of file paths to CodeFile objects for fast lookup
    final coverageFilesByPath = {for (var file in coverageCodeFiles) file.path: file};
    final jsonFilesByPath = {for (var file in (jsonCodeFiles ?? [])) file.path: file};

    // Iterate over each original file
    for (var originalFile in originalCodeFiles) {
      final codeLines = <Line>[];

      // Retrieve the corresponding coverage and JSON files, if available
      final coverageFile = coverageFilesByPath[originalFile.path];
      final jsonFile = jsonFilesByPath[originalFile.path];

      // Convert the code lines of coverage and JSON files into maps for quick lookup by line number
      final coverageLinesByNumber = {for (var line in coverageFile?.codeLines ?? []) line.lineNumber: line as CoverageLine};
      final jsonLinesByNumber = {for (var line in jsonFile?.codeLines ?? []) line.lineNumber: line as GitLine};

      // Iterate over each line in the original file
      for (final originalCodeLine in originalFile.codeLines) {
        final lineNumber = originalCodeLine.lineNumber;

        // Fetch corresponding coverage and JSON lines by line number
        final coverageLine = coverageLinesByNumber[lineNumber];
        final jsonLine = jsonLinesByNumber[lineNumber];

        // Add a new line object with coverage and change information
        codeLines.add(
          Line(
            lineNumber: lineNumber,
            lineContent: originalCodeLine.lineContent,
            canHitLine: coverageLine != null, // Whether the line can be hit (exists in coverage data)
            hitCount: coverageLine?.hitCount ?? 0, // Number of times the line was hit in tests
            isLineHit: coverageLine?.isLineHit ?? false, // Whether the line was actually hit in tests
            isModified: jsonLine?.hasLineChanged ?? false, // Whether the line is new or has changed (from JSON)
          ),
        );
      }

      // Add the parsed file to the result list
      results.add(CodeFile(path: originalFile.path, codeLines: codeLines));
    }

    return results;
  }
}
