import 'dart:convert';
import 'dart:io';
import 'package:lcov_cli/models/line.dart';
import 'package:test/test.dart';
import 'package:lcov_cli/generators/json_file_report_generator.dart';
import 'package:lcov_cli/models/code_file.dart';

void main() {
  group('JsonFileReportGenerator', () {
    late JsonFileReportGenerator generator;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('json_report_test_');

      final codeFiles = [
        CodeFile(
          path: 'lib/file1.dart',
          codeLines: [
            for (var i = 1; i <= 100; i++)
              Line(
                lineNumber: i,
                canHitLine: i < 80,
                isLineHit: i < 60,
                isModified: i < 20,
              ),
          ],
        ),
        CodeFile(
          path: 'lib/file2.dart',
          codeLines: [
            for (var i = 1; i <= 50; i++)
              Line(
                lineNumber: i,
                canHitLine: i < 20,
                isLineHit: i < 15,
                isModified: i < 40,
              ),
          ],
        ),
      ];

      generator = JsonFileReportGenerator(
        codeFiles: codeFiles,
        outputDir: tempDir.path,
      );
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('generates valid JSON report file', () async {
      final files = await generator.generate();

      expect(files, hasLength(1));
      expect(files!.first.path, endsWith('report.json'));

      final content = await files.first.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      expect(json['total_lines'], equals(150));
      expect(json['total_files'], equals(2));
      expect(json['total_hittable_lines'], equals(98));
      expect(json['total_covered_lines'], equals(73));
      expect(json['total_lines_missed'], equals(25));
      expect(json['total_modified_lines'], equals(58));
      expect(json['total_hit_on_modified_lines'], equals(33));
      expect(json['total_hittable_modified_lines'], equals(38));
      expect(json['files']['lib/file2.dart'], isNotNull);
    });

    test('handles empty code files list', () async {
      generator = JsonFileReportGenerator(
        codeFiles: [],
        outputDir: tempDir.path,
      );

      final files = await generator.generate();

      expect(files, hasLength(1));

      final content = await files!.first.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      expect(json['total_lines'], equals(0));
      expect(json['total_files'], equals(0));
      expect(json['files'], isEmpty);
    });

    test('overwrites existing report file', () async {
      await File('${tempDir.path}/report.json').writeAsString('{"dummy": "data"}');

      final files = await generator.generate();

      expect(files, hasLength(1));
      final content = await files!.first.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      expect(json['dummy'], isNull);
      expect(json['total_files'], equals(2));
    });
  });
}
