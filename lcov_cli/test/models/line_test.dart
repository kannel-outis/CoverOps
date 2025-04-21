import 'package:test/test.dart';
import 'package:lcov_cli/models/line.dart';

void main() {
  group('Line', () {
    test('creates basic line with defaults', () {
      final line = Line(lineNumber: 1);
      expect(line.lineNumber, equals(1));
      expect(line.lineContent, equals(''));
      expect(line.hitCount, equals(0));
      expect(line.isModified, isFalse);
      expect(line.isLineHit, isFalse);
      expect(line.canHitLine, isTrue);
    });

    test('creates line with all properties', () {
      final line = Line(
        lineNumber: 1,
        lineContent: 'test content',
        hitCount: 2,
        isModified: true,
        isLineHit: true,
        canHitLine: false,
      );
      expect(line.lineContent, equals('test content'));
      expect(line.hitCount, equals(2));
      expect(line.isModified, isTrue);
      expect(line.isLineHit, isTrue);
      expect(line.canHitLine, isFalse);
    });
  });

  group('CoverageLine', () {
    test('isLineHit returns true when hitCount > 0', () {
      final line = CoverageLine(lineNumber: 1, hitCount: 1);
      expect(line.isLineHit, isTrue);
    });

    test('isLineHit returns false when hitCount = 0', () {
      final line = CoverageLine(lineNumber: 1, hitCount: 0);
      expect(line.isLineHit, isFalse);
    });
  });

  group('GitLine', () {
    test('isModified reflects hasLineChanged value', () {
      final changedLine = GitLine(lineNumber: 1, hasLineChanged: true);
      expect(changedLine.isModified, isTrue);

      final unchangedLine = GitLine(lineNumber: 1, hasLineChanged: false);
      expect(unchangedLine.isModified, isFalse);
    });
  });

  group('FileLine', () {
    test('creates file line with content', () {
      final line = FileLine(lineNumber: 1, lineContent: 'import "package:test/test.dart";');
      expect(line.lineNumber, equals(1));
      expect(line.lineContent, equals('import "package:test/test.dart";'));
    });
  });
}
