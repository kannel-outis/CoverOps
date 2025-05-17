import 'dart:io';
import 'package:lcov_cli/parsers/json_parser.dart';
import 'package:lcov_cli/parsers/lcov_parser.dart';
import 'package:test/test.dart';
import 'package:lcov_cli/parsers/line_parser.dart';
import 'package:lcov_cli/utils/enums.dart';

void main() {

  test('LineParser.fromType creates correct parser type for LCOV', () {
    final parser = LineParser.fromType(ParserType.lcov, File('path'));
    expect(parser, isA<LcovFileLineParser>());
  });

  test('LineParser.fromType creates correct parser type for JSON', () {
    final parser = LineParser.fromType(ParserType.json, File('path'));
    expect(parser, isA<JsonFileLineParser>());
  });
}
