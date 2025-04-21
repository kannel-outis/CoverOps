import 'dart:io';
import 'package:test/test.dart';
import 'package:lcov_cli/parsers/json_parser.dart';
import 'package:lcov_cli/models/line.dart';

void main() {
  late JsonFileLineParser parser;
  late Directory tempDir;
  late File jsonFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp();
    jsonFile = File('${tempDir.path}/test.json');
    parser = JsonFileLineParser(jsonFile);
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('should parse valid JSON file with multiple files and line changes', () async {
    await jsonFile.writeAsString('''
    {
      "lib/file1.dart": {"1": 1, "2": 0, "3": 1},
      "lib/file2.dart": {"1": 0, "2": 1, "3": 0}
    }
    ''');

    final result = await parser.parsedLines();

    expect(result.length, equals(2));
    expect(result[0].path, equals('lib/file1.dart'));
    expect(result[0].codeLines.length, equals(3));
    expect((result[0].codeLines[0] as GitLine).hasLineChanged, isTrue);
    expect((result[0].codeLines[1] as GitLine).hasLineChanged, isFalse);
    expect((result[0].codeLines[2] as GitLine).hasLineChanged, isTrue);
  });

  test('should handle empty JSON file', () async {
    await jsonFile.writeAsString('{}');
    
    final result = await parser.parsedLines();
    
    expect(result, isEmpty);
  });

  test('should handle JSON with invalid line numbers', () async {
    await jsonFile.writeAsString('''
    {
      "lib/file1.dart": {"invalid": 1, "2": 0}
    }
    ''');

    final result = await parser.parsedLines();
    
    expect(result.length, equals(1));
    expect(result[0].codeLines.length, equals(1));
    expect(result[0].codeLines[0].lineNumber, equals(2));
  });

  test('should handle JSON with non-integer change values', () async {
    await jsonFile.writeAsString('''
    {
      "lib/file1.dart": {"1": "changed", "2": null, "3": 1}
    }
    ''');

    final result = await parser.parsedLines();
    
    expect(result.length, equals(1));
    expect(result[0].codeLines.length, equals(1));
    expect(result[0].codeLines[0].lineNumber, equals(3));
  });

  test('should handle malformed JSON structure', () async {
    await jsonFile.writeAsString('''
    {
      "lib/file1.dart": "not a map",
      "lib/file2.dart": {"1": 1}
    }
    ''');

    final result = await parser.parsedLines();
    
    expect(result.length, equals(1));
    expect(result[0].path, equals('lib/file2.dart'));
    expect(result[0].codeLines.length, equals(1));
  });
}
