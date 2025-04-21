import 'package:lcov_cli/models/code_file.dart';
import 'package:lcov_cli/models/line.dart';
import 'package:lcov_cli/parsers/total_code_coverage_file_parser.dart';
import 'package:test/test.dart';

void main() {
  group('TotalCodeCoverageFileParser', () {
    late TotalCodeCoverageFileParser parser;

    test('handles empty original code files list', () {
      parser = TotalCodeCoverageFileParser(
        coverageCodeFiles: [
          CodeFile(path: 'test.dart', codeLines: [
            CoverageLine(lineNumber: 1, hitCount: 1),
          ]),
        ],
        originalCodeFiles: [],
      );

      final result = parser.parsedLines();
      expect(result, isEmpty);
    });

    test('handles file with no matching coverage data', () async {
      parser = TotalCodeCoverageFileParser(
        coverageCodeFiles: [],
        originalCodeFiles: [
          CodeFile(path: 'test.dart', codeLines: [
            Line(lineNumber: 1, lineContent: 'void main() {}'),
          ]),
        ],
      );

      final result = await parser.parsedLines();
      expect(result.length, equals(1));
      expect(result[0].codeLines[0].canHitLine, isFalse);
      expect(result[0].codeLines[0].hitCount, equals(0));
      expect(result[0].codeLines[0].isLineHit, isFalse);
    });

    test('correctly merges multiple files with coverage and json data', () async {
      parser = TotalCodeCoverageFileParser(
        coverageCodeFiles: [
          CodeFile(path: 'file1.dart', codeLines: [
            CoverageLine(lineNumber: 1, hitCount: 2),
            CoverageLine(lineNumber: 2, hitCount: 0),
          ]),
          CodeFile(path: 'file2.dart', codeLines: [
            CoverageLine(lineNumber: 1, hitCount: 3),
          ]),
        ],
        originalCodeFiles: [
          CodeFile(path: 'file1.dart', codeLines: [
            Line(lineNumber: 1, lineContent: 'line 1'),
            Line(lineNumber: 2, lineContent: 'line 2'),
          ]),
          CodeFile(path: 'file2.dart', codeLines: [
            Line(lineNumber: 1, lineContent: 'line 1'),
          ]),
        ],
        jsonCodeFiles: [
          CodeFile(path: 'file1.dart', codeLines: [
            GitLine(lineNumber: 1, hasLineChanged: true),
            GitLine(lineNumber: 2, hasLineChanged: false),
          ]),
          CodeFile(path: 'file2.dart', codeLines: [
            GitLine(lineNumber: 1, hasLineChanged: true),
          ]),
        ],
      );

      final result = await parser.parsedLines();
      expect(result.length, equals(2));
      
      expect(result[0].path, equals('file1.dart'));
      expect(result[0].codeLines[0].hitCount, equals(2));
      expect(result[0].codeLines[0].isModified, isTrue);
      expect(result[0].codeLines[1].hitCount, equals(0));
      expect(result[0].codeLines[1].isModified, isFalse);

      expect(result[1].path, equals('file2.dart'));
      expect(result[1].codeLines[0].hitCount, equals(3));
      expect(result[1].codeLines[0].isModified, isTrue);
    });

    test('handles mismatched line numbers between coverage and original files', () async {
      parser = TotalCodeCoverageFileParser(
        coverageCodeFiles: [
          CodeFile(path: 'test.dart', codeLines: [
            CoverageLine(lineNumber: 1, hitCount: 1),
            CoverageLine(lineNumber: 3, hitCount: 2),
          ]),
        ],
        originalCodeFiles: [
          CodeFile(path: 'test.dart', codeLines: [
            Line(lineNumber: 1, lineContent: 'line 1'),
            Line(lineNumber: 2, lineContent: 'line 2'),
            Line(lineNumber: 3, lineContent: 'line 3'),
            Line(lineNumber: 4, lineContent: 'line 4'),
          ]),
        ],
      );

      final result = await parser.parsedLines();
      expect(result[0].codeLines[0].canHitLine, isTrue);
      expect(result[0].codeLines[1].canHitLine, isFalse);
      expect(result[0].codeLines[2].canHitLine, isTrue);
      expect(result[0].codeLines[3].canHitLine, isFalse);
    });
  });
}
