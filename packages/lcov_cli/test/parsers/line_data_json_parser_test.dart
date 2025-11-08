import 'dart:io';
import 'package:lcov_cli/parsers/line_data_json_parser.dart';
import 'package:test/test.dart';
import 'package:lcov_cli/models/line.dart';

void main() {
  late LineDataJsonParser parser;
  late Directory tempDir;

  group('LineDataJsonParser.quality Test', () {
    late File qualityAnalysisFile;
    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp();
      qualityAnalysisFile = File('${tempDir.path}/test.json');
      parser = LineDataJsonParser.quality(qualityAnalysisFile);
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test(
      'Given a JSON file containing a single quality issue '
      'When the parser processes it '
      'Then it should return one QualityLine with the correct details',
      () async {
        await qualityAnalysisFile.writeAsString('''
   {
    "test/commands/comands_test.dart": {
        "127": {
            "line": 127,
            "column": 3,
            "type": "info",
            "message": "Constructor declarations should be before non-constructor declarations. Try moving the constructor declaration before all other members.",
            "rule": "sort_constructors_first"
        }
      }
   }
    ''');

        final result = await parser.parsedLines();

        expect(result.length, equals(1));
        expect(result['test/commands/comands_test.dart']?.entries.length, equals(1));
        expect(result['test/commands/comands_test.dart']?.entries.single.value, isA<QualityLine>());
        expect(result['test/commands/comands_test.dart']?.entries.single.value.lineNumber, equals(127));
        expect(result['test/commands/comands_test.dart']?.entries.single.value.qualityAnalysisIssues?.message, equals('Constructor declarations should be before non-constructor declarations. Try moving the constructor declaration before all other members.'));
        expect(result['test/commands/comands_test.dart']?.entries.single.value.qualityAnalysisIssues?.type, equals('info'));
        expect(result['test/commands/comands_test.dart']?.entries.single.value.qualityAnalysisIssues?.rule, equals('sort_constructors_first'));
      },
    );

    test(
      'Given a JSON file containing multiple messages for a single line '
      'When the parser processes it '
      'Then it should concatenate all messages, types, and rules into a single QualityLine',
      () async {
        await qualityAnalysisFile.writeAsString('''
   {
    "test/commands/comands_test.dart": {
        "167": {
            "line": 167,
            "message": [
                "Missing type annotation on a public API. Try adding a type annotation.",
                "The method 'noSuchMethod' should have a return type but doesn't. Try adding a return type to the method."
            ],
            "type": [
                "info",
                "info"
            ],
            "column": [
                3,
                3
            ],
            "rule": [
                "type_annotate_public_apis",
                "always_declare_return_types"
            ]
        }
      }
   }
    ''');

        final result = await parser.parsedLines();

        expect(result.length, equals(1));
        expect(result['test/commands/comands_test.dart']?.entries.length, equals(1));
        expect(result['test/commands/comands_test.dart']?.entries.single.value, isA<QualityLine>());
        expect(result['test/commands/comands_test.dart']?.entries.single.value.lineNumber, equals(167));
        expect(
            result['test/commands/comands_test.dart']?.entries.single.value.qualityAnalysisIssues?.message, equals('Missing type annotation on a public API. Try adding a type annotation.\nThe method \'noSuchMethod\' should have a return type but doesn\'t. Try adding a return type to the method.'));
        expect(result['test/commands/comands_test.dart']?.entries.single.value.qualityAnalysisIssues?.type, equals('info\ninfo'));
        expect(result['test/commands/comands_test.dart']?.entries.single.value.qualityAnalysisIssues?.rule, equals('type_annotate_public_apis\nalways_declare_return_types'));
      },
    );

    test(
      'Given a JSON file containing multiple lines with single and multiple messages '
      'When the parser processes it '
      'Then it should return all QualityLines with the correct merged content for each line',
      () async {
        await qualityAnalysisFile.writeAsString('''
   {
    "test/commands/comands_test.dart": {
        "127": {
            "line": 127,
            "column": 3,
            "type": "info",
            "message": "Constructor declarations should be before non-constructor declarations",
            "rule": "sort_constructors_first"
        },
        "155": {
            "line": 155,
            "column": 3,
            "type": "info",
            "message": "Constructor declarations should be before non-constructor declarations",
            "rule": "sort_constructors_first"
        },
        "167": {
            "line": 167,
            "message": [
                "Missing type annotation on a public API. Try adding a type annotation.",
                "The method 'noSuchMethod' should have a return type but doesn't. Try adding a return type to the method."
            ],
            "type": [
                "info",
                "info"
            ],
            "column": [
                3,
                3
            ],
            "rule": [
                "type_annotate_public_apis",
                "always_declare_return_types"
            ]
        }
    }
   }
    ''');

        final result = await parser.parsedLines();

        expect(result.length, equals(1));
        expect(result['test/commands/comands_test.dart']?.entries.length, equals(3));
        expect(result['test/commands/comands_test.dart']?[127]?.qualityAnalysisIssues?.message, equals('Constructor declarations should be before non-constructor declarations'));
        expect(result['test/commands/comands_test.dart']?[155]?.qualityAnalysisIssues?.message, equals('Constructor declarations should be before non-constructor declarations'));
        expect(result['test/commands/comands_test.dart']?[167]?.qualityAnalysisIssues?.message, equals('Missing type annotation on a public API. Try adding a type annotation.\nThe method \'noSuchMethod\' should have a return type but doesn\'t. Try adding a return type to the method.'));
        expect(result['test/commands/comands_test.dart']?[167]?.qualityAnalysisIssues?.type, equals('info\ninfo'));
        expect(result['test/commands/comands_test.dart']?[167]?.qualityAnalysisIssues?.rule, equals('type_annotate_public_apis\nalways_declare_return_types'));
      },
    );
  });

  group('LineDataJsonParser.modified Test', () {
    late File modifiedFile;
    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp();
      modifiedFile = File('${tempDir.path}/test.json');
      parser = LineDataJsonParser.modified(modifiedFile);
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test(
      'Given a valid JSON file with multiple files and line change indicators '
      'When the parser processes it '
      'Then it should correctly identify modified and unmodified lines for each file',
      () async {
      await modifiedFile.writeAsString('''
    {
      "lib/file1.dart": {"1": 1, "2": 0, "3": 1},
      "lib/file2.dart": {"1": 0, "2": 1, "3": 0}
    }
    ''');

      final result = await parser.parsedLines();

      expect(result.length, equals(2));
      expect(result['lib/file1.dart']?.entries.length, equals(3));
      expect((result['lib/file1.dart']?[1] as GitLine).hasLineChanged, isTrue);
      expect((result['lib/file1.dart']?[2] as GitLine).hasLineChanged, isFalse);
      expect((result['lib/file1.dart']?[3] as GitLine).hasLineChanged, isTrue);
    });

    test(
      'Given an empty JSON file '
      'When the parser processes it '
      'Then it should return an empty result',
      () async {
      await modifiedFile.writeAsString('{}');

      final result = await parser.parsedLines();

      expect(result, isEmpty);
    });

    test(
      'Given a JSON file containing invalid line numbers '
      'When the parser processes it '
      'Then it should skip invalid entries and parse only valid lines',
      () async {
      await modifiedFile.writeAsString('''
    {
      "lib/file1.dart": {"invalid": 1, "2": 0}
    }
    ''');

      final result = await parser.parsedLines();

      expect(result.length, equals(1));
      expect(result['lib/file1.dart']?.entries.length, equals(1));
      expect(result['lib/file1.dart']?[2]?.lineNumber, equals(2));
    });

    test(
      'Given a JSON file with non-integer change values '
      'When the parser processes it '
      'Then it should ignore invalid entries and include only valid numeric changes',
      () async {
      await modifiedFile.writeAsString('''
    {
      "lib/file1.dart": {"1": "changed", "2": null, "3": 1}
    }
    ''');

      final result = await parser.parsedLines();

      expect(result.length, equals(1));
      expect(result['lib/file1.dart']?.entries.length, equals(1));
      expect(result['lib/file1.dart']?[1], isNull);
      expect(result['lib/file1.dart']?[2], isNull);
      expect(result['lib/file1.dart']?[3], isA<GitLine>());
      expect(result['lib/file1.dart']?[3]?.isModified, true);
      expect(result['lib/file1.dart']?[3]?.lineNumber, 3);
    });

    test(
      'Given a JSON file with a malformed structure '
      'When the parser processes it '
      'Then it should skip invalid entries and parse only properly formatted sections',
      () async {
      await modifiedFile.writeAsString('''
    {
      "lib/file1.dart": "not a map",
      "lib/file2.dart": {"1": 1}
    }
    ''');

      final result = await parser.parsedLines();

      expect(result.length, equals(1));
      expect(result['lib/file2.dart']?.entries.length, equals(1));
    });
  });
}
