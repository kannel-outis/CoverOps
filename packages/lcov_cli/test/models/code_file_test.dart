import 'package:test/test.dart';
import 'package:lcov_cli/models/code_file.dart';
import 'package:lcov_cli/models/line.dart';

void main() {
  group('CodeFile', () {
    test('empty code file has correct default values', () {
      final codeFile = CodeFile(path: 'test.dart', codeLines: []);
      
      expect(codeFile.totalCodeLines, equals(0));
      expect(codeFile.totalHittableLines, equals(0));
      expect(codeFile.totalCoveredLines, equals(0));
      expect(codeFile.totalModifiedLines, equals(0));
      expect(codeFile.totalHittableModifiedLines, equals(0));
      expect(codeFile.totalHitOnModifiedLines, equals(0));
      expect(codeFile.isModified, isFalse);
      expect(codeFile.totalCoveragePercentage, equals('0 %'));
    });

    test('code file with mixed lines calculates metrics correctly', () {
      final codeFile = CodeFile(
        path: 'test.dart',
        codeLines: [
          Line(lineNumber: 1, lineContent: 'line1', canHitLine: true, hitCount: 1),
          Line(lineNumber: 2, lineContent: 'line2', canHitLine: true, hitCount: 0, isLineHit: true),
          Line(lineNumber: 3, lineContent: 'line3', canHitLine: false),
          Line(lineNumber: 4, lineContent: 'line4', canHitLine: true, hitCount: 1, isModified: true, isLineHit: true),
          Line(lineNumber: 5, lineContent: 'line5', canHitLine: true, hitCount: 1, isModified: true),
        ],
      );

      expect(codeFile.totalCodeLines, equals(5));
      expect(codeFile.totalHittableLines, equals(4));
      expect(codeFile.totalCoveredLines, equals(2));
      expect(codeFile.totalModifiedLines, equals(2));
      expect(codeFile.totalHittableModifiedLines, equals(2));
      expect(codeFile.totalHitOnModifiedLines, equals(1));
      expect(codeFile.isModified, isTrue);
      expect(codeFile.totalCoveragePercentage, equals('50 %'));
    });

    test('code file with single line calculates coverage correctly', () {
      final codeFile = CodeFile(
        path: 'test.dart',
        codeLines: [
          Line(lineNumber: 1, lineContent: 'line1', canHitLine: true, hitCount: 1, isLineHit: true),
        ],
      );

      expect(codeFile.totalCodeLines, equals(1));
      expect(codeFile.totalCoveragePercentage, equals('100 %'));
    });

    test('code file with non-hittable lines calculates coverage correctly', () {
      final codeFile = CodeFile(
        path: 'test.dart',
        codeLines: [
          Line(lineNumber: 1, lineContent: 'line1', canHitLine: false),
          Line(lineNumber: 2, lineContent: 'line2', canHitLine: false),
        ],
      );

      expect(codeFile.totalCodeLines, equals(2));
      expect(codeFile.totalHittableLines, equals(0));
      expect(codeFile.totalCoveredLines, equals(0));
      expect(codeFile.totalCoveragePercentage, equals('0 %'));
    });
  });
}
