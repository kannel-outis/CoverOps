import 'dart:io';
import 'package:lcov_cli/generators/console_report_generator.dart';
import 'package:lcov_cli/generators/html_files_gen.dart';
import 'package:lcov_cli/generators/json_file_report_generator.dart';
import 'package:test/test.dart';
import 'package:lcov_cli/generators/generator.dart';
import 'package:lcov_cli/lcov_cli.dart';
import 'package:lcov_cli/models/code_file.dart';
import 'package:lcov_cli/models/line.dart';

void main() {
  group('ReportGenerator', () {
    late Directory tempDir;
    late List<CodeFile> testCodeFiles;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('generator_test_');
      testCodeFiles = [
        CodeFile(
          path: 'test/sample.dart',
          codeLines: [
            Line(lineNumber: 1, canHitLine: true, isLineHit: true, isModified: false),
            Line(lineNumber: 2, canHitLine: true, isLineHit: false, isModified: true),
          ],
        ),
      ];
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('factory creates correct generator type for HTML', () {
      final generator = ReportGenerator.ofType(
        type: ReportType.html,
        codeFiles: testCodeFiles,
        outputDir: tempDir.path,
      );
      expect(generator, isA<HtmlFilesReportGenerator>());
    });

    test('factory creates correct generator type for JSON', () {
      final generator = ReportGenerator.ofType(
        type: ReportType.json,
        codeFiles: testCodeFiles,
        outputDir: tempDir.path,
      );
      expect(generator, isA<JsonFileReportGenerator>());
    });

    test('factory creates correct generator type for console', () {
      final generator = ReportGenerator.ofType(
        type: ReportType.console,
        codeFiles: testCodeFiles,
        outputDir: tempDir.path,
      );
      expect(generator, isA<ConsoleReportGenerator>());
    });

    test('createOutPutDir creates directory if it does not exist', () async {
      final newDir = Directory('${tempDir.path}/newdir');
      final generator = ReportGenerator.ofType(
        type: ReportType.json,
        codeFiles: testCodeFiles,
        outputDir: newDir.path,
      );

      await generator.createOutPutDir(newDir);
      expect(await newDir.exists(), isTrue);
    });

    test('createOutPutDir handles existing directory', () async {
      final existingDir = await Directory('${tempDir.path}/existing').create();
      final generator = ReportGenerator.ofType(
        type: ReportType.json,
        codeFiles: testCodeFiles,
        outputDir: existingDir.path,
      );

      await generator.createOutPutDir(existingDir);
      expect(await existingDir.exists(), isTrue);
    });

    test('generator instantiates with null outputDir', () {
      final generator = ReportGenerator.ofType(
        type: ReportType.console,
        codeFiles: testCodeFiles,
        outputDir: null,
      );
      expect(generator.outputDir, isNull);
      expect(generator.codeFiles, equals(testCodeFiles));
    });
  });
}
