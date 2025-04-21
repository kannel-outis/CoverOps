import 'package:test/test.dart';
import 'package:lcov_cli/models/lcov_file_group.dart';
import 'package:lcov_cli/models/line.dart';

void main() {
  group('LcovGroup', () {
    test('empty LcovGroup has zero coverage percentage', () {
      final group = LcovGroup(
        fileName: 'test.dart',
        functionsFound: 0,
        linesFound: 0,
        linesHit: 0,
        lines: [],
      );
      
      expect(group.lineCoveragePercentage, equals(0.0));
    });

    test('LcovGroup calculates coverage percentage correctly', () {
      final group = LcovGroup(
        fileName: 'test.dart',
        functionsFound: 2,
        linesFound: 10,
        linesHit: 5,
        lines: [
          CoverageLine(lineNumber: 1, hitCount: 1),
          CoverageLine(lineNumber: 2, hitCount: 0),
        ],
      );
      
      expect(group.lineCoveragePercentage, equals(50.0));
    });

    test('LcovGroup toString contains all required information', () {
      final group = LcovGroup(
        fileName: 'test.dart',
        functionsFound: 3,
        linesFound: 20,
        linesHit: 15,
        lines: [],
      );
      
      final string = group.toString();
      expect(string, contains('File: test.dart'));
      expect(string, contains('Lines Found: 20'));
      expect(string, contains('Lines Hit: 15'));
      expect(string, contains('Coverage: 75.00%'));
      expect(string, contains('Functions Found: 3'));
    });
  });

  group('FileGroup', () {
    test('FileGroup stores content and path correctly', () {
      final fileGroup = FileGroup(
        content: ['line1', 'line2'],
        filePath: 'path/to/file.dart',
      );
      
      expect(fileGroup.content, equals(['line1', 'line2']));
      expect(fileGroup.filePath, equals('path/to/file.dart'));
    });

    test('FileGroup handles empty content', () {
      final fileGroup = FileGroup(
        content: [],
        filePath: 'empty.dart',
      );
      
      expect(fileGroup.content, isEmpty);
      expect(fileGroup.filePath, equals('empty.dart'));
    });
  });
}
