import 'dart:io';
import 'package:test/test.dart';
import 'package:lcov_cli/parsers/code_file_parser.dart';

void main() {
  late Directory tempDir;
  late File testFile1;
  late File testFile2;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync();
    testFile1 = File('${tempDir.path}/test1.txt')
      ..writeAsStringSync('Line 1\nLine 2\nLine 3');
    testFile2 = File('${tempDir.path}/test2.txt')
      ..writeAsStringSync('Test line 1\nTest line 2');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test('should parse multiple files correctly', () async {
    final parser = CodeFileParser(filePaths: [
      testFile1.path,
      testFile2.path,
    ]);

    final result = await parser.parsedLines();

    expect(result.length, equals(2));
    expect(result[0].path, equals(testFile1.path));
    expect(result[0].codeLines.length, equals(3));
    expect(result[1].path, equals(testFile2.path));
    expect(result[1].codeLines.length, equals(2));
  });

  test('should handle empty files', () async {
    final emptyFile = File('${tempDir.path}/empty.txt')..writeAsStringSync('');
    final parser = CodeFileParser(filePaths: [emptyFile.path]);

    final result = await parser.parsedLines();

    expect(result.length, equals(1));
    expect(result[0].codeLines.length, equals(1));
    expect(result[0].codeLines[0].lineContent, equals(''));
  });

  test('should handle non-existent files', () async {
    final nonExistentPath = '${tempDir.path}/non_existent.txt';
    final parser = CodeFileParser(filePaths: [nonExistentPath]);

    final result = await parser.parsedLines();

    expect(result.length, equals(1));
    expect(result[0].path, equals(nonExistentPath));
    expect(result[0].codeLines, isEmpty);
  });

  test('should correctly set line numbers', () async {
    final parser = CodeFileParser(filePaths: [testFile1.path]);

    final result = await parser.parsedLines();

    expect(result[0].codeLines[0].lineNumber, equals(1));
    expect(result[0].codeLines[1].lineNumber, equals(2));
    expect(result[0].codeLines[2].lineNumber, equals(3));
  });

  test('should handle mixed existing and non-existing files', () async {
    final nonExistentPath = '${tempDir.path}/non_existent.txt';
    final parser = CodeFileParser(filePaths: [testFile1.path, nonExistentPath]);

    final result = await parser.parsedLines();

    expect(result.length, equals(2));
    expect(result[0].codeLines.isNotEmpty, isTrue);
    expect(result[1].codeLines.isEmpty, isTrue);
  });
}
