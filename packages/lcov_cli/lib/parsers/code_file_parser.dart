import 'dart:async';
import 'dart:io';

import 'package:lcov_cli/lcov_cli.dart';
import 'package:lcov_cli/models/code_file.dart';
import 'package:lcov_cli/models/lcov_file_group.dart';
import 'package:lcov_cli/models/line.dart';

/// A parser that reads multiple files and converts them into a list of [CodeFile] objects,
/// where each file is represented by its path and the content split into individual lines.
class CodeFileParser extends LineParser {
  /// The list of file paths to be parsed.
  final List<String> filePaths;

  /// Creates an instance of [CodeFileParser].
  ///
  /// - [filePaths]: A list of file paths that need to be parsed.
  CodeFileParser({required this.filePaths});

  /// Parses the files from the provided [filePaths] and returns a list of [CodeFile] objects.
  ///
  /// - [rootPath]: An optional root directory path. This parameter is currently not used,
  ///   but can be used to resolve file paths relative to a root directory.
  ///
  /// Returns a list of [CodeFile] objects, where each contains the file path and its
  /// corresponding content lines.
  @override
  FutureOr<List<CodeFile>> parsedLines([String? rootPath]) {
    final codeFiles = <CodeFile>[];

    // Create a list of FileGroup objects, each representing a file and its parsed content
    final fileGroups = filePaths.map((path) {
      return FileGroup(
        content: _parseFileContentIntoLines(File(path)),
        filePath: path,
      );
    }).toList();

    // For each file group, process its content and store the file lines
    for (var group in fileGroups) {
      final fileLines = <Line>[];

      // Iterate through each line in the file's content
      for (var i = 0; i < group.content.length; i++) {
        final index = i + 1; // Line number starts from 1

        // Create a FileLine object with the line number and content, then add to the list
        fileLines.add(
          FileLine(
            lineNumber: index,
            lineContent: group.content[i],
          ),
        );
      }

      // Add the CodeFile object to the result list
      codeFiles.add(CodeFile(path: group.filePath, codeLines: fileLines));
    }

    return codeFiles;
  }

  /// Parses the content of a file into a list of strings, where each string represents a line.
  ///
  /// - [file]: The file whose content needs to be parsed.
  ///
  /// Returns a list of lines (strings). If the file doesn't exist, it returns an empty list.
  List<String> _parseFileContentIntoLines(File file) {
    // Check if the file exists; if so, read and split it into lines; otherwise, return an empty list.
    return file.existsSync() ? file.readAsStringSync().split('\n') : [];
  }
}
