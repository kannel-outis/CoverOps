import 'package:test/test.dart';
import 'package:git_parser_cli/models/git_file.dart';

void main() {
  group('GitFile', () {
    test('creates GitFile with path and content', () {
      final gitFile = GitFile(
        path: 'lib/test.dart',
        content: [
          GitLine(lineContent: 'test content', lineNumber: '1'),
        ],
      );

      expect(gitFile.path, equals('lib/test.dart'));
      expect(gitFile.content, hasLength(1));
      expect(gitFile.content.first.lineContent, equals('test content'));
    });

    test('creates GitFile with empty content list', () {
      final gitFile = GitFile(path: 'lib/empty.dart', content: []);

      expect(gitFile.path, isNotEmpty);
      expect(gitFile.content, isEmpty);
    });
  });

  group('GitLine', () {
    test('detects added line correctly', () {
      final gitLine = GitLine(lineContent: '+new line', lineNumber: '1');

      expect(gitLine.isLineAdded, isTrue);
      expect(gitLine.isLineRemoved, isFalse);
      expect(gitLine.isLineChanged, isTrue);
    });

    test('detects removed line correctly', () {
      final gitLine = GitLine(lineContent: '-old line', lineNumber: '1');

      expect(gitLine.isLineAdded, isFalse);
      expect(gitLine.isLineRemoved, isTrue);
      expect(gitLine.isLineChanged, isTrue);
    });

    test('handles unchanged line correctly', () {
      final gitLine = GitLine(lineContent: ' normal line', lineNumber: '1');

      expect(gitLine.isLineAdded, isFalse);
      expect(gitLine.isLineRemoved, isFalse);
      expect(gitLine.isLineChanged, isFalse);
    });

    test('creates GitLine with default empty line number', () {
      final gitLine = GitLine(lineContent: 'test content');

      expect(gitLine.lineNumber, isEmpty);
      expect(gitLine.lineContent, equals('test content'));
    });

    test('handles empty line content correctly', () {
      final gitLine = GitLine(lineContent: '', lineNumber: '1');

      expect(gitLine.isLineAdded, isFalse);
      expect(gitLine.isLineRemoved, isFalse);
      expect(gitLine.isLineChanged, isFalse);
    });
  });
}
