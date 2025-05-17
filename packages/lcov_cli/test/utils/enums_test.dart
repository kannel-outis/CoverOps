import 'package:test/test.dart';
import 'package:lcov_cli/utils/enums.dart';

void main() {
  group('ReportType.fromString', () {
    test('should return console type when input is null', () {
      final result = ReportType.fromString(null);
      expect(result, equals([ReportType.html]));
    });

    test('should parse single report type', () {
      final result = ReportType.fromString('html');
      expect(result, equals([ReportType.html]));
    });

    test('should parse multiple report types', () {
      final result = ReportType.fromString('html,json,console');
      expect(result, equals([ReportType.html, ReportType.json, ReportType.console]));
    });

    test('should throw when invalid type provided', () {
      expect(
        () => ReportType.fromString('invalid'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw when any type in comma-separated list is invalid', () {
      expect(
        () => ReportType.fromString('html,invalid,console'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should handle empty string', () {
      expect(
        () => ReportType.fromString(''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
