import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:lcov_cli/models/code_file.dart';
import 'package:lcov_cli/models/line.dart';
import 'package:lcov_cli/parsers/line_parser.dart';

/// A parser that reads a JSON file and converts it into a list of [CodeFile] objects.
/// The JSON data represents files with line changes, mapping line numbers to change statuses.
class JsonFileLineParser extends LineParser {
  /// The JSON file being parsed.
  final File jsonFile;

  /// Creates an instance of [JsonFileLineParser].
  ///
  /// - [jsonFile]: The JSON file containing code file change data.
  JsonFileLineParser(this.jsonFile);

  /// Parses the JSON file and returns a list of [CodeFile] objects, each representing
  /// a source file with its corresponding line change data.
  ///
  /// - [rootPath] is an optional parameter, but it is not used in this implementation.
  /// Returns a list of [CodeFile] objects containing line change information for each file.
  @override
  FutureOr<List<CodeFile>> parsedLines([String? rootPath]) async {
    final List<CodeFile> codeFiles = [];

    // Parse the JSON data into a map structure
    final jsonData = await _parseJsonToMap();

    // Iterate through the parsed data, where each entry corresponds to a file
    for (final data in jsonData.entries) {
      final lines = <GitLine>[];

      // For each file, convert its lines and check if they have changed
      for (var line in data.value.entries) {
        lines.add(GitLine(lineNumber: line.key, hasLineChanged: line.value > 0));
      }

      // Create a CodeFile object and add it to the result list
      codeFiles.add(CodeFile(path: data.key, codeLines: lines));
    }

    return codeFiles;
  }

  /// Parses the JSON file content into a nested map structure.
  ///
  /// The JSON format should represent files and their corresponding line changes.
  /// - Each key is a file path, and its value is a map of line numbers to an integer status
  ///   (greater than 0 means the line has changed).
  ///
  /// Returns a [Map] where the keys are file paths and the values are maps that
  /// associate line numbers with change statuses.
  Future<Map<String, Map<int, int>>> _parseJsonToMap() async {
    // Read the content of the JSON file as a string
    final jsonString = await jsonFile.readAsString();

    // Decode the JSON string into a dynamic object
    final dynamic jsonData = jsonDecode(jsonString);

    // The result will be a map of file paths to maps of line numbers and their change statuses
    final Map<String, Map<int, int>> result = {};

    // Ensure the decoded JSON data is a map of strings to dynamic objects
    if (jsonData is Map<String, dynamic>) {
      jsonData.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final Map<int, int> innerMap = {};

          // For each file, iterate over its line numbers and change statuses
          value.forEach((innerKey, innerValue) {
            if (innerValue is int) {
              // Try to parse the line number key as an integer
              final intKey = int.tryParse(innerKey);
              if (intKey != null) {
                innerMap[intKey] = innerValue;
              }
            }
          });

          // Add the file path and its corresponding line change map to the result
          result[key] = innerMap;
        }
      });
    }

    return result;
  }
}
