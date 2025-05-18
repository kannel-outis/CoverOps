import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:args/args.dart';
import 'package:cover_ops/utils/config.dart';

void main() {
  group('Config', () {
    late ArgParser parser;
    late ArgResults args;

    setUp(() {
      parser = ArgParser()
        ..addOption('lcov')
        ..addOption('json')
        ..addOption('gitParserFile')
        ..addOption('target-branch')
        ..addOption('fallback')
        ..addOption('source-branch')
        ..addOption('output')
        ..addOption('output-dir')
        ..addOption('projectPath')
        ..addOption('config')
        ..addOption('report-format');
    });

    test('creates Config with null values when no args provided', () {
      final config = Config.fromArgs(null);
      expect(config.lcovFile, isNull);
      expect(config.jsonCoverage, isNull);
      expect(config.gitParserFile, isNull);
      expect(config.targetBranch, isNull);
      expect(config.targetBranchFallback, isNull);
      expect(config.sourceBranch, isNull);
      expect(config.output, isNull);
      expect(config.projectPath, isNull);
      expect(config.reportFormat, isNull);
    });

    test('creates Config with values from command line args', () {
      args = parser.parse([
        '--lcov=coverage/lcov.info',
        '--json=coverage.json',
        '--gitParserFile=git.json',
        '--target-branch=main',
        '--fallback=master',
        '--source-branch=feature',
        '--output=output',
        '--projectPath=/path',
        '--report-format=html'
      ]);

      final config = Config.fromArgs(args);
      expect(config.lcovFile, equals('coverage/lcov.info'));
      expect(config.jsonCoverage, equals('coverage.json'));
      expect(config.gitParserFile, equals('git.json'));
      expect(config.targetBranch, equals('main'));
      expect(config.targetBranchFallback, equals('master'));
      expect(config.sourceBranch, equals('feature'));
      expect(config.output, equals('output'));
      expect(config.projectPath, equals('/path'));
      expect(config.reportFormat, equals('html'));
    });

    test('gitParserfromArgs creates Config with only git-related values', () {
      args = parser.parse([
        '--target-branch=main',
        '--fallback=master',
        '--source-branch=feature',
        '--output-dir=output',
        '--projectPath=/path',
      ]);

      final config = Config.gitParserfromArgs(args);
      expect(config.targetBranch, equals('main'));
      expect(config.targetBranchFallback, equals('master'));
      expect(config.sourceBranch, equals('feature'));
      expect(config.output, equals('output'));
      expect(config.projectPath, equals('/path'));
      expect(config.lcovFile, isNull);
      expect(config.jsonCoverage, isNull);
      expect(config.gitParserFile, isNull);
    });

    test('lcovParserfromArgs creates Config with only LCOV-related values', () {
      args = parser.parse([
        '--lcov=coverage/lcov.info',
        '--json=coverage.json',
        '--gitParserFile=git.json',
        '--output=output',
        '--projectPath=/path',
        '--report-format=html,json',
      ]);

      final config = Config.lcovParserfromArgs(args);
      expect(config.lcovFile, equals('coverage/lcov.info'));
      expect(config.jsonCoverage, equals('coverage.json'));
      expect(config.gitParserFile, equals('git.json'));
      expect(config.output, equals('output'));
      expect(config.projectPath, equals('/path'));
      expect(config.reportFormat, equals('html,json'));
      expect(config.targetBranch, isNull);
      expect(config.sourceBranch, isNull);
    });

    test('fromArgs creates Config from JSON config file with valid values', () {
      final json = {
        "lcov": "coverage/lcov.info",
        "targetBranch": "main",
        "sourceBranch": "HEAD",
        "output": "coverage",
        "reportFormat": ["html", "console"],
      };
      final tempDir = Directory.systemTemp.createTempSync();
      final tempFile = File('${tempDir.path}/invalid.json')..writeAsStringSync(jsonEncode(json));
      tempFile.createSync();
      args = parser.parse([
        '--config=${tempFile.path}',
      ]);

      final config = Config.fromArgs(args);
      
      expect(config.lcovFile, equals('coverage/lcov.info'));
      expect(config.targetBranch, equals('main'));
      expect(config.sourceBranch, equals('HEAD'));
      expect(config.output, equals('coverage'));
      expect(config.reportFormat, equals('html,console'));

      tempDir.deleteSync(recursive: true);
    });  });
}
