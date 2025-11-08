import 'dart:convert';
import 'dart:io';

import 'package:lcov_cli/models/line.dart';
import 'package:lcov_cli/parsers/line_parser.dart';

/// A specialized parser for processing JSON files containing line-level data.
///
/// This abstract parser extends [DynamicLineParser] to produce a structured map
/// of file paths to line information. Each file maps line numbers to [Line] objects,
/// which represent the state or quality of individual lines.
///
/// Use the factory constructors to create specific implementations:
/// - [LineDataJsonParser.modified] returns a parser for modified lines ([ModifiedLineDataParser]).
/// - [LineDataJsonParser.quality] returns a parser for code quality data ([QualityLineDataParser]).
abstract class LineDataJsonParser extends DynamicLineParser<Map<String, Map<int, Line>>> {
  /// The JSON file being parsed.
  final File jsonFile;

  /// Creates an instance of [LineDataJsonParser].
  ///
  /// Parameters:
  /// - [jsonFile]: The JSON file containing line-level data.
  LineDataJsonParser._(this.jsonFile);

  /// Creates a parser for modified lines.
  factory LineDataJsonParser.modified(File jsonFile) = _ModifiedLineDataParser;

  /// Creates a parser for code quality data.
  factory LineDataJsonParser.quality(File jsonFile) = _QualityLineDataParser;

  /// Parses the JSON file and returns a nested map representing line data.
  ///
  /// The outer map's keys are file paths, and the inner map's keys are line numbers.
  /// The inner map's values are [Line] objects representing the state or quality
  /// of each line.
  ///
  /// Parameters:
  /// - [rootPath]: Optional root path for resolving relative file paths. Not used
  ///   in this implementation.
  ///
  /// Returns a [Future] containing a [Map] of file paths to line maps.
  @override
  Future<Map<String, Map<int, Line>>> parsedLines([String? rootPath]) async {
    final jsonString = await jsonFile.readAsString();
    final dynamic jsonData = jsonDecode(jsonString);
    final Map<String, Map<int, Line>> result = {};

    if (jsonData is Map<String, dynamic>) {
      jsonData.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final Map<int, Line> innerMap = {};
          value.forEach((innerKey, innerValue) {
            if (innerValue is int || innerValue is Map<String, dynamic>) {
              final intKey = int.tryParse(innerKey);
              if (intKey != null) {
                innerMap[intKey] = resolve(intKey, innerValue);
              }
            }
          });
          result[key] = innerMap;
        }
      });
    }
    return result;
  }

  /// Resolves a line number and raw data into a [Line] object.
  ///
  /// This method must be implemented by subclasses to convert raw JSON data
  /// into the appropriate [Line] subclass.
  ///
  /// Parameters:
  /// - [lineNumber]: The line number being processed.
  /// - [data]: Raw JSON data for this line (integer for modified lines, or a
  ///   map for quality lines).
  ///
  /// Returns a [Line] object representing this line's state or quality.
  Line resolve(int lineNumber, dynamic data);
}

/// A parser for tracking modified lines in a JSON file.
class _ModifiedLineDataParser extends LineDataJsonParser {
  _ModifiedLineDataParser(super.jsonFile) : super._();

  @override
  Line resolve(int lineNumber, data) {
    return GitLine(lineNumber: lineNumber, hasLineChanged: data > 0);
  }
}

/// A parser for tracking code quality issues in a JSON file.
class _QualityLineDataParser extends LineDataJsonParser {
  _QualityLineDataParser(super.jsonFile) : super._();

  @override
  Line resolve(int lineNumber, data) {
    final type = data['type'];
    final message = data['message'];
    final rule = data['rule'];
    return QualityLine(
      lineNumber: lineNumber,
      message: _convertToString(message),
      type: _convertToString(type),
      rule: _convertToString(rule),
    );
  }

  String _convertToString(dynamic value) {
    if (value is List) return value.join('\n');
    return value?.toString() ?? '';
  }
}
