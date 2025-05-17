import 'package:test/test.dart';
import 'package:lcov_cli/utils/arg_settings.dart';
import 'package:lcov_cli/utils/enums.dart';

void main() {
  group('ArgumentSettings', () {
    test('fromArgs creates settings with LCOV file path', () {
      final settings = ArgumentSettings.fromArgs(['-l', 'coverage/lcov.info']);
      
      expect(settings.lcovFile, equals('coverage/lcov.info'));
      expect(settings.parserType, equals(ParserType.lcov));
      expect(settings.hasCoverageFile, isTrue);
    });

    test('fromArgs creates settings with JSON file path', () {
      final settings = ArgumentSettings.fromArgs(['-j', 'coverage.json']);
      
      expect(settings.jsonFile, equals('coverage.json'));
      expect(settings.parserType, equals(ParserType.json));
      expect(settings.hasCoverageFile, isTrue);
    });

    test('fromArgs handles multiple report types', () {
      final settings = ArgumentSettings.fromArgs([
        '-l', 'coverage/lcov.info',
        '-r', 'html,json,console'
      ]);
      
      expect(settings.reportTypes, containsAll([
        ReportType.html,
        ReportType.json,
        ReportType.console
      ]));
    });

    test('fromArgs sets flutter project flag', () {
      final settings = ArgumentSettings.fromArgs([
        '-l', 'coverage/lcov.info',
        '-f', 'true'
      ]);
      
      expect(settings.isFlutterProject, isTrue);
    });

    test('fromArgs handles all optional parameters', () {
      final settings = ArgumentSettings.fromArgs([
        '-l', 'coverage/lcov.info',
        '-o', 'output/dir',
        '-p', '/project/root',
        '-g', 'git_changes.json',
        '-f', 'true',
        '-r', 'html'
      ]);
      
      expect(settings.outputDir, equals('output/dir'));
      expect(settings.projectPath, equals('/project/root'));
      expect(settings.gitParserFile, equals('git_changes.json'));
      expect(settings.isFlutterProject, isTrue);
      expect(settings.reportTypes, equals([ReportType.html]));
    });

    test('hasCoverageFile returns false when no coverage file provided', () {
      final settings = ArgumentSettings.fromArgs([]);
      
      expect(settings.hasCoverageFile, isFalse);
    });

    test('coverageFile throws ArgumentError when no coverage file provided', () {
      final settings = ArgumentSettings.fromArgs([]);
      
      expect(() => settings.coverageFile, throwsArgumentError);
    });

    test('parserType throws ArgumentError when no coverage file provided', () {
      final settings = ArgumentSettings.fromArgs([]);
      
      expect(() => settings.parserType, throwsArgumentError);
    });

    test('gitParserJsonFile returns null when no git parser file provided', () {
      final settings = ArgumentSettings.fromArgs([]);
      
      expect(settings.gitParserJsonFile, isNull);
    });
  });
}
