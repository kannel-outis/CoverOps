import 'package:analysis_parser_cli/models/file.dart';
import 'package:analysis_parser_cli/parser/analysis_line_parser.dart';
import 'package:analysis_parser_cli/utils/enums.dart';
import 'package:test/test.dart';

void main() {
  test('analysis line parser ...', () async {
    final parser = PythonAnalysisLineParser();
    final line =
        "  error - packages/analysis_parser_cli/test/analysis_parser_cli_test.dart:6:12 - The function 'calculate' isn't defined. Try importing the library that defines 'calculate', correcting the name to the name of an existing function, or defining a function named 'calculate'. - undefined_function";
    final result = parser.parseLine(line);
    print(result?.lineNumber);
    print(result?.columnNumber);
    print(result?.message);
    print(result?.rule);
    print(result?.type);
    print(parser.parseFileName(line));
  });
  group('PythonAnalysisLineParser', () {
    final parser = PythonAnalysisLineParser();

    test('parses a simple pylint single-line issue', () {
      const line = "project/module.py:12:4: E1101: Module 'os' has no 'pathjoin' member (no-member)";
      final result = parser.parseLine(line);

      expect(result, isNotNull);
      expect(result!.lineNumber, 12);
      expect(result.columnNumber, 4);
      expect(result.message, "Module 'os' has no 'pathjoin' member");
      expect(result.rule, "no-member");
      expect(result.type, AnalysisType.error);
      expect(parser.parseFileName(line), "project/module.py");
    });

    test('parses another file after module header', () {
      const block = '''
************* Module my_package.core.utils
my_package/core/utils.py:35:4: W0612: Unused variable 'x' (unused-variable)
    def build_path(parts):
    ^^^^^^^^^^^^^^^^^^^^^
''';

      final lines = block.split('\n');

      final results = lines.map(parser.parseLine).whereType<AnalysisLine>().toList();

      expect(results.length, 1);
      final r = results.first;
      expect(r.lineNumber, 35);
      expect(r.columnNumber, 4);
      expect(r.message, "Unused variable 'x'");
      expect(r.rule, "unused-variable");
      expect(r.type, AnalysisType.warning);
      expect(parser.parseFileName(lines[1]), "my_package/core/utils.py");
    });

    test('ignores non-matching lines and pointer lines', () {
      const line = "    ^^^^^^^^^^^^^^^";
      final result = parser.parseLine(line);
      expect(result, isNull);
    });

    test('supports multiline output', () {
      expect(parser.supportsMultiline, isTrue);
    });
  });

  group('JsAnalysisLineParser', () {
    late JsAnalysisLineParser parser;

    setUp(() {
      parser = JsAnalysisLineParser();
    });

    test('parses ESLint multiline issues correctly', () {
      const input = '''
src/app.js
  10:5  error  Unexpected console statement  no-console
         This is an extra context line
         And another one

src/utils/helpers.ts
  2:3  warning  "x" is defined but never used  no-unused-vars
  5:1  error  Missing return type on function  @typescript-eslint/explicit-function-return-type
''';

      final lines = input.split('\n');
      final files = <AnalysisFile>[];

      String? currentFile;
      final currentLines = <AnalysisLine>[];

      for (final line in lines) {
        final newFile = parser.parseFileName(line);

        if (newFile != null) {
          final flushed = parser.flush();
          if (flushed != null) currentLines.add(flushed);

          if (currentFile != null) {
            files.add(AnalysisFile(path: currentFile, lines: List.of(currentLines)));
            currentLines.clear();
          }
          currentFile = newFile;
          continue;
        }

        final parsed = parser.parseLine(line);
        if (parsed != null) {
          currentLines.add(parsed);
        }
      }

      // Final flush
      final lastFlushed = parser.flush();
      if (lastFlushed != null) currentLines.add(lastFlushed);
      if (currentFile != null) {
        files.add(AnalysisFile(path: currentFile, lines: List.of(currentLines)));
      }

      // ✅ Assertions
      expect(files.length, 2);

      final file1 = files[0];
      expect(file1.path, 'src/app.js');
      expect(file1.lines.length, 1);
      expect(
        file1.lines.first.message,
        '10:5  error  Unexpected console statement  no-console\n'
        'This is an extra context line\n'
        'And another one',
      );

      final file2 = files[1];
      expect(file2.lines.length, 2);
      expect(file2.lines.first.rule, 'no-unused-vars');
      expect(file2.lines.last.rule, '@typescript-eslint/explicit-function-return-type');
    });
  });
}
