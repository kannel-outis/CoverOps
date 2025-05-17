import 'dart:async';

import 'package:lcov_cli/generators/console_report_generator.dart';
import 'package:lcov_cli/models/code_file.dart';
import 'package:lcov_cli/models/line.dart';
import 'package:test/test.dart';

void main() {
  group('ConsoleReportGenerator', () {
    late ConsoleReportGenerator generator;
    late List<CodeFile> codeFiles;

    setUp(() {
      codeFiles = [
        CodeFile(
          path: 'lib/sample1.dart',
          codeLines: List.generate(50, (i) {
            final index = i + 1;
            return Line(
              lineNumber: index,
              canHitLine: index < 40,     // 39 hittable
              isLineHit: index < 30,      // 29 hit
              isModified: index < 10,     // 9 modified
            );
          }),
        ),
        CodeFile(
          path: 'lib/sample2.dart',
          codeLines: List.generate(30, (i) {
            final index = i + 1;
            return Line(
              lineNumber: index,
              canHitLine: index < 20,     // 19 hittable
              isLineHit: index < 15,      // 14 hit
              isModified: index < 25,     // 25 modified
            );
          }),
        ),
      ];

      generator = ConsoleReportGenerator(codeFiles: codeFiles, outputDir: '');
    });

    test('prints detailed coverage report to console', () async {
      final outputLog = <String>[];
      final zoneSpec = ZoneSpecification(
        print: (_, __, ___, String msg) => outputLog.add(msg),
      );

      await Zone.current.fork(specification: zoneSpec).run(() async {
        final result = await generator.generate();
        expect(result, isNull);
      });

      final output = outputLog.join('\n');

      // Summary assertions
      expect(output, contains('Test Coverage Report'));
      expect(output, contains('Total Files'));
      expect(output, contains('Total Hittable Code Lines'));
      expect(output, contains('Total Covered Lines'));
      expect(output, contains('Coverage on Modified Lines'));

      // File paths
      expect(output, contains('lib/sample1.dart'));
      expect(output, contains('lib/sample2.dart'));

      // Values
      // sample1.dart: 39 hittable, 29 covered, 9 modified
      // sample2.dart: 19 hittable, 14 covered, 25 modified
      // Total: 58 hittable, 43 covered
      expect(output, contains('58'));  // total hittable lines
      expect(output, contains('43'));  // total covered lines

      // Coverage % symbols
      final percentageMatches = RegExp(r'\d+(\.\d+)?\s?%').allMatches(output);
      expect(percentageMatches.length, greaterThanOrEqualTo(2), reason: 'Should include % values');

      // Table column titles
      expect(output, contains('File'));
      expect(output, contains('Total Hittable Lines'));
      expect(output, contains('Total Covered Lines'));
      expect(output, contains('Total Modified Lines'));
      expect(output, contains('Covered Lines (Modified)'));
      expect(output, contains('Total Coverage'));
      expect(output, contains('Coverage on Modified'));

      // Colored/styled elements (you can test using ANSI codes or skip if hard to assert)
    });

    test('prints empty table when no code files are provided', () async {
      generator = ConsoleReportGenerator(codeFiles: [], outputDir: '');

      final outputLog = <String>[];
      final zoneSpec = ZoneSpecification(
        print: (_, __, ___, String msg) => outputLog.add(msg),
      );

      await Zone.current.fork(specification: zoneSpec).run(() async {
        final result = await generator.generate();
        expect(result, isNull);
      });

      final output = outputLog.join('\n');
      expect(output, contains('Test Coverage Report'));
      expect(output, contains('Total Files               : [38;5;244;1m0     [0m')); // Total Files          : 0 (count in grey color)
      expect(output, contains('Total Hittable Code Lines : [38;5;244;1m0     [0m')); // Total Hittable Lines : 0 (count in grey color)
      expect(output, contains('Total Coverage            : [31;1m0.0 %[0m')); // Total Coverage       : 0.0% (red color)
      expect(output, contains('Coverage on Modified Lines: [31;1m0.0 %[0m')); // Coverage on Modified : 0.0% (red color)
      expect(output, isNot(contains('lib/')));
    });
  });
}
