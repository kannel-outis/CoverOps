import 'dart:async';
import 'dart:io';

import 'package:lcov_cli/models/code_file.dart';
import 'package:lcov_cli/parsers/json_parser.dart';
import 'package:lcov_cli/parsers/lcov_parser.dart';
import 'package:lcov_cli/utils/enums.dart';

/// A base class for parsing code coverage files.
/// 
/// This abstract class provides a common interface for parsing different types of
/// code coverage files (e.g., LCOV, JSON) into a list of [CodeFile] objects.
abstract class LineParser {
  /// Creates a new [LineParser] instance.
  const LineParser();

  /// Creates a [LineParser] instance based on the specified parser type.
  /// 
  /// Parameters:
  /// - [type]: The type of parser to create (LCOV or JSON)
  /// - [file]: The file to parse
  /// 
  /// Returns a concrete implementation of [LineParser] based on the [type].
  /// TODO: maybe move this to the utils file and make it static ??
  factory LineParser.fromType(ParserType type, File file) {
    return switch (type) {
      ParserType.lcov => LcovFileLineParser(file),
      ParserType.json => JsonFileLineParser(file),
    };
  }

  /// Parses the file and returns a list of [CodeFile] objects.
  /// 
  /// Parameters:
  /// - [rootPath]: Optional root path to use for resolving relative file paths
  /// 
  /// Returns a list of [CodeFile] objects containing the parsed coverage data.
  FutureOr<List<CodeFile>> parsedLines([String? rootPath]);
}