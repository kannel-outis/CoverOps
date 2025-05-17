import 'dart:io';

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
