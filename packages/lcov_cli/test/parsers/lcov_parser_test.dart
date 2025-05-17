import 'dart:io';
import 'package:test/test.dart';
import 'package:lcov_cli/parsers/lcov_parser.dart';

void main() {
  late Directory tempDir;
  late File lcovFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync();
    lcovFile = File('${tempDir.path}/coverage.lcov');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test('parsedLines handles empty LCOV file', () {
    lcovFile.writeAsStringSync('');
    final parser = LcovFileLineParser(lcovFile);
    final result = parser.parsedLines();
    expect(result, isEmpty);
  });

  test('parsedLines correctly parses single file coverage data', () {
    final lcovContent = '''
SF:lib/example.dart
FNF:5
LF:10
LH:8
DA:1,1
DA:2,2
DA:3,0
DA:4,1
end_of_record
''';
    lcovFile.writeAsStringSync(lcovContent);
    
    final parser = LcovFileLineParser(lcovFile);
    final result = parser.parsedLines();
    
    expect(result.length, equals(1));
    expect(result[0].path, equals('lib/example.dart'));
    expect(result[0].codeLines.length, equals(4));
    expect(result[0].codeLines[0].lineNumber, equals(1));
    expect(result[0].codeLines[0].hitCount, equals(1));
    expect(result[0].codeLines[2].hitCount, equals(0));
  });

  test('parsedLines handles multiple files in LCOV data', () {
    final lcovContent = '''
SF:lib/first.dart
FNF:2
LF:5
LH:4
DA:1,1
DA:2,1
end_of_record
SF:lib/second.dart
FNF:3
LF:6
LH:5
DA:1,2
DA:2,0
end_of_record
''';
    lcovFile.writeAsStringSync(lcovContent);
    
    final parser = LcovFileLineParser(lcovFile);
    final result = parser.parsedLines();
    
    expect(result.length, equals(2));
    expect(result[0].path, equals('lib/first.dart'));
    expect(result[1].path, equals('lib/second.dart'));
    expect(result[0].codeLines.length, equals(2));
    expect(result[1].codeLines.length, equals(2));
  });

  test('parsedLines handles malformed LCOV data gracefully', () {
    final lcovContent = '''
SF:lib/example.dart
Invalid Line
DA:1,invalid
DA:2,1
end_of_record
''';
    lcovFile.writeAsStringSync(lcovContent);
    
    final parser = LcovFileLineParser(lcovFile);
    expect(() => parser.parsedLines(), throwsFormatException);
  });

  test('parsedLines preserves line order', () {
    final lcovContent = '''
SF:lib/example.dart
FNF:1
LF:3
LH:3
DA:3,1
DA:1,1
DA:2,1
end_of_record
''';
    lcovFile.writeAsStringSync(lcovContent);
    
    final parser = LcovFileLineParser(lcovFile);
    final result = parser.parsedLines();
    
    expect(result[0].codeLines[0].lineNumber, equals(3));
    expect(result[0].codeLines[1].lineNumber, equals(1));
    expect(result[0].codeLines[2].lineNumber, equals(2));
  });
}
