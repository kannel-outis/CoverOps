import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:lcov_cli/models/code_file.dart';
import 'package:lcov_cli/models/line.dart';
import 'package:lcov_cli/parsers/line_parser.dart';

class JsonFileLineParser extends LineParser {
  JsonFileLineParser(this.jsonFile);
  final File jsonFile;

  @override
  FutureOr<List<CodeFile>> parsedLines([String? rootPath]) async {
    final List<CodeFile> codeFiles = [];

    final jsonData = await _parseJsonToMap();
    for (final data in jsonData.entries) {
      final lines = <GitLine>[];

      for (var line in data.value.entries) {
        lines.add(GitLine(lineNumber: line.key, hasLineChanged: line.value > 0));
      }

      codeFiles.add(CodeFile(path: data.key, codeLines: lines));
    }

    return codeFiles;
  }

  Future<Map<String, Map<int, int>>> _parseJsonToMap() async {
    // Step 1: Read the JSON file content
    final jsonString = await jsonFile.readAsString();

    // Step 2: Parse the JSON string into a Dart object (Map<String, dynamic>)
    final dynamic jsonData = jsonDecode(jsonString);

    // Step 3: Initialize the final result map
    final Map<String, Map<int, int>> result = {};

    // Step 4: Iterate over the JSON structure to build the required map
    if (jsonData is Map<String, dynamic>) {
      jsonData.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final Map<int, int> innerMap = {};
          value.forEach((innerKey, innerValue) {
            // Ensure keys and values are int and add them to the inner map
            if (innerValue is int) {
              final intKey = int.tryParse(innerKey);
              if (intKey != null) {
                innerMap[intKey] = innerValue;
              }
            }
          });
          result[key] = innerMap;
        }
      });
    }

    return result;
  }
}
