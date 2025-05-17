import 'dart:io';

import 'package:lcov_cli/models/code_file.dart';
import 'package:lcov_cli/models/lcov_file_group.dart';
import 'package:lcov_cli/models/line.dart';
import 'package:lcov_cli/parsers/line_parser.dart';


/// A parser that reads an LCOV coverage file and converts it into a list of [CodeFile] objects.
/// Each file contains the coverage data, such as lines hit and missed, extracted from the LCOV format.
class LcovFileLineParser extends LineParser {
  /// The LCOV file being parsed.
  final File lcovFile;

  /// Creates an instance of [LcovFileLineParser].
  ///
  /// - [lcovFile]: The LCOV coverage file to be parsed.
  LcovFileLineParser(this.lcovFile);

  /// Parses the LCOV file and returns a list of [CodeFile] objects, each representing a source file
  /// with its corresponding coverage data.
  ///
  /// - [rootPath] is an optional parameter, but it is not used in this implementation.
  /// Returns a list of [CodeFile] objects containing coverage data for each file.
  @override
  List<CodeFile> parsedLines([String? rootPath]) {
    // Parse the LCOV data into groups, each representing a file's coverage information
    final lcovGroups = parseLCOV(lcovFile.readAsStringSync());
    
    // Map the parsed LCOV groups into CodeFile objects
    return lcovGroups.map((lcov) => CodeFile(path: lcov.fileName, codeLines: lcov.lines)).toList();
  }

  /// Parses the raw LCOV data into a list of [LcovGroup] objects.
  ///
  /// Each [LcovGroup] represents a source file and contains its corresponding coverage details.
  ///
  /// - [lcovData]: The raw LCOV file content as a string.
  /// Returns a list of [LcovGroup] objects, each containing the coverage data of a file.
  List<LcovGroup> parseLCOV(String lcovData) {
    final coverageSections = <LcovGroup>[];
    String? currentFile;      // Holds the file currently being processed
    int functionsFound = 0;   // Number of functions found in the file
    int linesFound = 0;       // Number of lines found in the file
    int linesHit = 0;         // Number of lines hit in the file (i.e., executed)
    var lcovLines = <CoverageLine>[];  // List of lines with their coverage data

    // Split the LCOV data into lines for processing
    final lines = lcovData.split('\n');
    for (final line in lines) {
      // The LCOV data uses prefixes to indicate the type of each line, extract the prefix.
      final prefix = line.length > 2 ? line.substring(0, 3) : line;

      switch (prefix) {
        case 'SF:':  // Start of a new source file (SF)
          // If there's a previous file being processed, finalize it and add to coverage sections.
          if (currentFile != null) {
            coverageSections.add(LcovGroup(
              fileName: currentFile,
              functionsFound: functionsFound,
              linesFound: linesFound,
              linesHit: linesHit,
              lines: lcovLines,
            ));
          }

          // Start processing a new file
          currentFile = line.substring(3);  // Extract the file path after 'SF:'
          functionsFound = 0;
          linesFound = 0;
          linesHit = 0;
          lcovLines = [];  // Reset the lines for the new file
          break;
        case 'FNF':  // Number of functions found (FNF)
          functionsFound = int.parse(line.substring(4));  // Extract the number of functions found
          break;
        case 'LF:':  // Number of lines found (LF)
          linesFound = int.parse(line.substring(3));  // Extract the number of lines found
          break;
        case 'LH:':  // Number of lines hit (LH)
          linesHit = int.parse(line.substring(3));  // Extract the number of lines hit
          break;
        case 'DA:':  // Data about a specific line's coverage (DA)
          // 'DA:<line number>,<hit count>' represents a line and its hit count
          final parts = line.substring(3).split(',');
          lcovLines.add(CoverageLine(
            lineNumber: int.parse(parts[0]),  // Line number
            hitCount: int.parse(parts[1]),    // Hit count (how many times this line was executed)
          ));
          break;
        default:
          // Ignore other lines as they are not relevant for this parser
          break;
      }
    }

    // After the loop, add the last file being processed to the coverage sections.
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
}
