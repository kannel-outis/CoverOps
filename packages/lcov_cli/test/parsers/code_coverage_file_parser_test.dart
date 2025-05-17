import 'dart:io';
import 'package:test/test.dart';
import 'package:lcov_cli/parsers/code_coverage_file_parser.dart';
import 'package:lcov_cli/models/code_file.dart';
import 'package:lcov_cli/models/line.dart';

void main() {
  late Directory tempDir;
  late File testFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync();
    testFile = File('${tempDir.path}/test.dart');
    testFile.writeAsStringSync('line1\nline2\nline3\n');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test('parsedLines handles empty modified files list', () async {
    final parser = CodeCoverageFileParser(
      modifiedCodeFiles: null,
      coverageCodeFiles: [
        CodeFile(
          path: 'test.dart',
          codeLines: [
            Line(lineNumber: 1, lineContent: 'line1', canHitLine: true, hitCount: 1),
          ],
        ),
      ],
    );

    final result = await parser.parsedLines(tempDir.path);
    expect(result.length, equals(1));
    expect(result[0].codeLines[0].isModified, isFalse);
  });

  test('parsedLines correctly merges coverage and modified files data', () async {
    final parser = CodeCoverageFileParser(
      modifiedCodeFiles: [
        CodeFile(
          path: testFile.path,
          codeLines: [
            Line(lineNumber: 2, lineContent: 'line2', isModified: true),
          ],
        ),
      ],
      coverageCodeFiles: [
        CodeFile(
          path: 'test.dart',
          codeLines: [
            Line(lineNumber: 1, lineContent: 'line1', canHitLine: true, hitCount: 1),
            Line(lineNumber: 2, lineContent: 'line2', canHitLine: true, hitCount: 0),
          ],
        ),
      ],
    );

    final result = await parser.parsedLines(tempDir.path);
    expect(result[0].codeLines[1].isModified, isTrue);
    expect(result[0].codeLines[1].hitCount, equals(0));
  });

  test('parsedLines handles non-existent files gracefully', () async {
    final parser = CodeCoverageFileParser(
      modifiedCodeFiles: null,
      coverageCodeFiles: [
        CodeFile(
          path: 'non_existent.dart',
          codeLines: [
            Line(lineNumber: 1, lineContent: 'line1', canHitLine: true, hitCount: 1),
          ],
        ),
      ],
    );

    final result = await parser.parsedLines(tempDir.path);
    expect(result.length, equals(1));
    expect(result[0].codeLines.length, equals(0));
  });

  test('parsedLines preserves line numbers and content', () async {
    final parser = CodeCoverageFileParser(
      modifiedCodeFiles: null,
      coverageCodeFiles: [
        CodeFile(
          path: 'test.dart',
          codeLines: [],
        ),
      ],
    );

    final result = await parser.parsedLines(tempDir.path);
    expect(result[0].codeLines.length, equals(4));
    expect(result[0].codeLines[0].lineNumber, equals(1));
    expect(result[0].codeLines[0].lineContent, equals('line1'));
    expect(result[0].codeLines[1].lineNumber, equals(2));
    expect(result[0].codeLines[1].lineContent, equals('line2'));
  });
}
