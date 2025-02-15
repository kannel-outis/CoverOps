import 'dart:io';

import 'package:lcov_cli/models/code_file.dart';
import 'package:lcov_cli/models/lcov_file_group.dart';
import 'package:lcov_cli/models/line.dart';
import 'package:lcov_cli/parsers/line_parser.dart';

/// A parser class that reads and processes LCOV coverage reports for files.
///
/// The `LcovFileLineParser` class is responsible for parsing a given LCOV file
/// and transforming it into a list of `CodeFile` objects. Each `CodeFile` contains
/// detailed information about the file, including its lines of code and coverage details.
///
/// This class extends `LineParser` and implements the `parsedLines` method to convert
/// the LCOV data into readable file contents, along with coverage statistics for each line.
class LcovFileLineParser extends LineParser {
  /// The LCOV file to be parsed.
  final File lcovFile;

  /// Creates an instance of [LcovFileLineParser].
  ///
  /// The [lcovFile] is the file that contains the LCOV coverage data that will be parsed.
  LcovFileLineParser(this.lcovFile);

  /// Parses the LCOV file and returns a list of [CodeFile] objects.
  ///
  /// Each [CodeFile] contains detailed information about the file's content, including:
  /// - Line numbers.
  /// - Line content.
  /// - Hit count for each line (how many times the line was executed).
  /// - Whether a line was hit or not.
  /// - Whether a line is eligible for coverage (if it's executable code).
  ///
  /// [rootPath] is an optional parameter used to specify the root path of files. If not provided,
  /// the paths in the LCOV file are assumed to be relative to the root.
  ///
  /// Returns a list of [CodeFile] objects, each representing a file and its coverage information.
  @override
  List<CodeFile> parsedLines([String? rootPath]) {
    // Parses the LCOV file content into groups representing individual files
    final lcovGroups = parseLCOV(lcovFile.readAsStringSync());

    // Maps each file group to its content lines and creates a FileGroup for further processing
    final fileGroups = lcovGroups.map((group) {
      return FileGroup(
        content: _parseFileContentIntoLines(File('$rootPath/${group.fileName}')),
        lcovGroup: group,
      );
    }).toList();

    // Holds the resulting list of CodeFile objects
    final codeFiles = <CodeFile>[];

    // Process each file group and map the coverage data to each line of code
    for (var group in fileGroups) {
      final lcovLine = <Line>[];

      // Create a map of line numbers to their coverage information (hit status and hit count)
      final coverageMap = {
        for (var line in group.lcovGroup.lines) line.lineNumber: (line.isLineHit, line.hitCount)
      };

      // Iterate through each line in the file content and populate the coverage data for each line
      for (var i = 0; i < group.content.length; i++) {
        final index = i + 1;

        lcovLine.add(
          Line(
            lineNumber: index,
            lineContent: group.content[i],
            hitCount: coverageMap[index]?.$2 ?? 0,
            isLineHit: coverageMap[index]?.$1 ?? false,
            canHitLine: group.lcovGroup.lines.map((line) => line.lineNumber).contains(index),
          ),
        );
      }

      // Add the processed file to the list of CodeFiles
      codeFiles.add(CodeFile(path: group.lcovGroup.fileName, codeLines: lcovLine));
    }

    return codeFiles;
  }

  /// Parses the content of an LCOV file into a list of [LcovGroup] objects.
  ///
  /// Each [LcovGroup] represents a file covered by the LCOV report, including details like
  /// the number of functions found, lines found, lines hit, and the coverage information for each line.
  ///
  /// The LCOV data is split into sections, each representing a file. Lines beginning with specific
  /// prefixes such as 'SF:', 'LF:', and 'DA:' are used to extract relevant information.
  ///
  /// The function returns a list of [LcovGroup] objects representing the parsed LCOV data.
  ///
  /// [lcovData] - A string containing the LCOV data to be parsed.
  List<LcovGroup> parseLCOV(String lcovData) {
    final coverageSections = <LcovGroup>[];
    String? currentFile;
    int functionsFound = 0;
    int linesFound = 0;
    int linesHit = 0;
    var lcovLines = <LcovLine>[];

    // Splitting LCOV data into lines
    final lines = lcovData.split('\n');
    for (final line in lines) {
      final prefix = line.length > 2 ? line.substring(0, 3) : line;

      // Switch based on the line prefix to extract relevant information
      switch (prefix) {
        case 'SF:':
          // If there was a previously processed file, add it to the list of coverage sections
          if (currentFile != null) {
            coverageSections.add(LcovGroup(
              fileName: currentFile,
              functionsFound: functionsFound,
              linesFound: linesFound,
              linesHit: linesHit,
              lines: lcovLines,
            ));
          }
          // Start a new file section
          currentFile = line.substring(3);
          functionsFound = 0;
          linesFound = 0;
          linesHit = 0;
          lcovLines = [];
          break;
        case 'FNF':
          // Number of functions found
          functionsFound = int.parse(line.substring(4));
          break;
        case 'LF:':
          // Number of lines found
          linesFound = int.parse(line.substring(3));
          break;
        case 'LH:':
          // Number of lines hit
          linesHit = int.parse(line.substring(3));
          break;
        case 'DA:':
          // Line coverage data (line number, hit count)
          final parts = line.substring(3).split(',');
          lcovLines.add(LcovLine(
            lineNumber: int.parse(parts[0]),
            hitCount: int.parse(parts[1]),
          ));
          break;
        default:
          // Handle other cases, if necessary
          break;
      }
    }

    // Add the final file section to the coverage sections
    if (currentFile != null) {
      coverageSections.add(LcovGroup(
        fileName: currentFile,
        functionsFound: functionsFound,
        linesFound: linesFound,
        linesHit: linesHit,
        lines: lcovLines,
      ));
    }

    return coverageSections;
  }

  /// Reads the content of a file and returns it as a list of lines.
  ///
  /// [file] - The file to be read.
  /// Returns a list of strings, where each string represents a line in the file.
  /// If the file does not exist, returns an empty list.
  List<String> _parseFileContentIntoLines(File file) {
    return file.existsSync() ? file.readAsStringSync().split('\n') : [];
  }
}