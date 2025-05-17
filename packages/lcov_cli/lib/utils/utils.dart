import 'dart:io';

import 'package:dcli/dcli.dart' as dcli;
import 'package:lcov_cli/generators/generator.dart';
import 'package:lcov_cli/lcov_cli.dart';
import 'package:lcov_cli/models/code_file.dart';

void exitWithMessage(String message, {int exitCode = 1}) {
  stderr.writeln(message);
  exit(exitCode);
}

extension ArgumentNotNull on Object? {
  bool get isNull {
    return this == null;
  }
}

extension OrEmpty on String? {
  String get orEmpty {
    return this == null ? '' : this!;
  }
}

extension StringEx on String {
  String prettifyPercentage([double targetCoverage = 80.0]) {
    final percentage = double.tryParse(split(' ').first) ?? 0.0;
    final colored = '$percentage %';
    return percentage >= targetCoverage
        ? colored.green
        : percentage >= targetCoverage - 15
            ? colored.yellow
            : colored.red;
  }

  String get blue => dcli.blue(this);
  String get yellow => dcli.yellow(this);
  String get red => dcli.red(this);
  String get grey => dcli.grey(this);
  String get green => dcli.green(this);
}

List<String> get defaultLanguageKeywords {
  return [
    'abstract',
    'as',
    'assert',
    'async',
    'await',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'covariant',
    'default',
    'deferred',
    'do',
    'dynamic',
    'else',
    'enum',
    'export',
    'extends',
    'extension',
    'external',
    'factory',
    'false',
    'final',
    'finally',
    'for',
    'function',
    'get',
    'hide',
    'if',
    'implements',
    'import',
    'in',
    'interface',
    'is',
    'late',
    'library',
    'mixin',
    'new',
    'null',
    'on',
    'operator',
    'part',
    'required',
    'rethrow',
    'return',
    'set',
    'show',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef',
    'var',
    'void',
    'while',
    'with',
    'yield',
    'list'
  ];
}

Map<String, String> get defaultSpecialCharSubForHtmlRendrer {
  return {
    '>': '&gt;',
    '<': '&lt;',
  };
}

String cleanContent(String text) {
  for (final specialChar in defaultSpecialCharSubForHtmlRendrer.entries) {
    text = text.replaceAll(specialChar.key, specialChar.value);
  }
  return text;
}

String totalCoveragePercentage(int totalCoveredLines, int totalCodeLines) {
  if (totalCodeLines == 0) return '0 %';
  return '${((totalCoveredLines / totalCodeLines) * 100).round()} %';
}

extension ReportTypeEx on ReportType {
  ReportGenerator generator(List<CodeFile> codeFiles, String outputDir) {
    return ReportGenerator.ofType(
      type: this,
      codeFiles: codeFiles,
      outputDir: outputDir,
    );
  }
}
