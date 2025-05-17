import 'dart:io';
import 'package:dcli/dcli.dart' hide isEmpty;
import 'package:file/local.dart';
import 'package:test/test.dart';
import 'package:lcov_cli/generators/html_files_gen.dart';
import 'package:lcov_cli/models/code_file.dart';
import 'package:lcov_cli/models/line.dart';

void main() {
  group('HtmlFilesGen', () {
    late HtmlFilesReportGenerator generator;
    late Directory tempDir;
    late File testFile;

    setUp(() {
      generator = HtmlFilesReportGenerator(codeFiles: [], outputDir: '');
      tempDir = Directory.systemTemp.createTempSync('html_files_gen_test_');
      testFile = File('${tempDir.path}/test.dart');
      testFile.writeAsStringSync('line1\nline2\nline3\n');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('wrapKeywords correctly formats language keywords', () {
      final result = generator.wrapKeywords('final String value');
      expect(result, contains('<span class="keyword">final</span>'));
      expect(result, contains('<span class="keyword">final</span> String value'));
    });

    test('wrapLineNumber formats covered line correctly', () {
      final line = Line(
        lineNumber: 1,
        lineContent: 'test line',
        isLineHit: true,
        canHitLine: true,
      );
      final result = generator.wrapLineNumber(line);
      expect(result, contains('class="unmodified"'));
      expect(result, contains('class="code-line line-covered"'));
    });

    test('wrapLineNumber formats modified uncovered line correctly', () {
      final line = Line(
        lineNumber: 1,
        lineContent: 'test line',
        isLineHit: false,
        canHitLine: true,
        isModified: true,
      );
      final result = generator.wrapLineNumber(line);
      expect(result, contains('class="modified"'));
      expect(result, contains('class="code-line line-missed"'));
    });

    test('buildListItemLink creates correct link structure', () {
      final link = generator.buildListItemLink(
        'test/path.html',
        title: 'Test File',
        childContent: '80%',
      );
      expect(link.href, equals('test/path.html'));
      expect(link.build(), contains('class="modified-files-link"'));
      expect(link.build(), contains('Test File'));
      expect(link.build(), contains('80%'));
    });
    test('generateHtmlFiles creates output directory and files', () async {
      final tempOutputDir = await Directory('${LocalFileSystem().currentDirectory.path}/test/generators/temp').create(recursive: true);
      final file = await File('${DartScript.self.pathToScriptDirectory}/lcov_cli/lib/generators/templates/__template__.css').create(recursive: true);
      final codeFiles = [
        CodeFile(
          path: 'test.dart',
          codeLines: [Line(lineNumber: 1, lineContent: 'void main() {}', isLineHit: true, canHitLine: true)],
        )
      ];
      print(tempOutputDir.path);
      final generator = HtmlFilesReportGenerator(codeFiles: codeFiles, outputDir: "${tempOutputDir.path}/");

      final htmlFiles = await generator.generate();

      expect(htmlFiles, isNotEmpty);
      expect(Directory('${tempOutputDir.path}/lcov_html').existsSync(), isTrue);
      expect(File('${tempOutputDir.path}/lcov_html/style.css').existsSync(), isTrue);
      expect(File('${tempOutputDir.path}/lcov_html/index.html').existsSync(), isTrue);
      expect(File('${tempOutputDir.path}/lcov_html/test.dart.html').existsSync(), isTrue);

      tempOutputDir.deleteSync(recursive: true);
      file.deleteSync();
    });

    test('generateHtmlFiles handles empty code files list', () async {
      final tempOutputDir = Directory.systemTemp.createTempSync('html_files_gen_empty_');
      final generator = HtmlFilesReportGenerator(codeFiles: [], outputDir: tempOutputDir.path);
      final htmlFiles = await generator.generate();

      expect(htmlFiles, isEmpty);
      expect(Directory('${tempOutputDir.path}lcov_html').existsSync(), isTrue);

      tempOutputDir.deleteSync(recursive: true);
    });

    test('generateHtmlFiles with root path creates correct relative paths', () async {
      final tempOutputDir = Directory.systemTemp.createTempSync('html_files_gen_root_');
      final rootPath = '/test/root';
      final codeFiles = [
        CodeFile(
          path: '/test/root/lib/file.dart',
          codeLines: [Line(lineNumber: 1, lineContent: 'test', isLineHit: true, canHitLine: true)],
        )
      ];
      final generator = HtmlFilesReportGenerator(codeFiles: codeFiles, outputDir: tempOutputDir.path);

      final htmlFiles = await generator.generate(rootPath);

      expect(htmlFiles, isNotEmpty);
      expect(htmlFiles.first.path, contains('${tempOutputDir.path}lcov_html/lib/file.dart.html'));

      tempOutputDir.deleteSync(recursive: true);
    });

    test('generateHtmlFiles creates index files for nested directories', () async {
      final tempOutputDir = Directory.systemTemp.createTempSync('html_files_gen_nested_');
      final codeFiles = [
        CodeFile(
          path: 'lib/nested/file.dart',
          codeLines: [Line(lineNumber: 1, lineContent: 'test', isLineHit: true, canHitLine: true)],
        )
      ];

      final generator = HtmlFilesReportGenerator(codeFiles: codeFiles, outputDir: tempOutputDir.path);

      await generator.generate();

      expect(File('${tempOutputDir.path}lcov_html/lib/index.html').existsSync(), isTrue);
      expect(File('${tempOutputDir.path}lcov_html/lib/nested/index.html').existsSync(), isTrue);

      tempOutputDir.deleteSync(recursive: true);
    });
  });
}
