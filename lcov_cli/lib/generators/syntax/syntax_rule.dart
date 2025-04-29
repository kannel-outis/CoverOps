import 'package:lcov_cli/utils/utils.dart';

/// Abstract base class for syntax highlighting rules.
abstract class SyntaxRule {
  /// Const constructor for [SyntaxRule].
  const SyntaxRule();

  /// The name of the CSS style to apply.
  String get name;

  /// The regex pattern to match text for this syntax rule.
  RegExp get pattern;

  /// List of all available syntax rules.
  static const rules = [
    LineCommentSyntaxRule(),
    KeywordSyntaxRule(),
    DoubleQuoteStringSyntaxRule(),
    SingleQuoteStringSyntaxRule(),
    NumberSyntaxRule(),
    MultiLineCommentSyntaxRule(),
    MultiLineCommentSyntaxRule2(),
    CapitalizedWordSyntaxRule(),
    DotNotationSyntaxRule(),
  ];
}

/// Base class for comment-related syntax rules.
abstract class CommentSyntaxRule extends SyntaxRule {
  const CommentSyntaxRule();
}

/// Matches single-line comments (e.g., `// comment`).
class LineCommentSyntaxRule extends CommentSyntaxRule {
  const LineCommentSyntaxRule();

  @override
  String get name => 'comment-style';

  @override
  RegExp get pattern => RegExp(r'//.*');
}

/// Matches documentation comments starting with `///`.
class MultiLineCommentSyntaxRule2 extends LineCommentSyntaxRule {
  const MultiLineCommentSyntaxRule2();

  @override
  RegExp get pattern => RegExp(r'///.*');
}

/// Matches multi-line block comments (e.g., `/* comment */`).
class MultiLineCommentSyntaxRule extends LineCommentSyntaxRule {
  const MultiLineCommentSyntaxRule();

  @override
  RegExp get pattern => RegExp(r'/\*[\s\S]*?\*/');
}

/// Base class for string-related syntax rules.
abstract class StringSyntaxRule extends SyntaxRule {
  const StringSyntaxRule();
}

/// Matches double-quoted string literals (e.g., `"Hello World"`).
class DoubleQuoteStringSyntaxRule extends StringSyntaxRule {
  const DoubleQuoteStringSyntaxRule();

  @override
  String get name => 'string-style';

  @override
  RegExp get pattern => RegExp(r'"(?:\\.|[^"\\])*"');
}

/// Matches single-quoted string literals (e.g., `'Hello World'`).
class SingleQuoteStringSyntaxRule extends DoubleQuoteStringSyntaxRule {
  const SingleQuoteStringSyntaxRule();

  @override
  RegExp get pattern => RegExp(r"'(?:\\.|[^'\\])*'");
}

/// Matches language keywords such as `if`, `else`, `class`, etc.
class KeywordSyntaxRule extends SyntaxRule {
  const KeywordSyntaxRule();

  @override
  String get name => 'keyword-style';

  @override
  RegExp get pattern => RegExp(r'\b(' + defaultLanguageKeywords.join('|') + r')\b', caseSensitive: false);
}

/// Matches numeric literals (integers or decimals).
class NumberSyntaxRule extends SyntaxRule {
  const NumberSyntaxRule();

  @override
  String get name => 'number-style';

  @override
  RegExp get pattern => RegExp(r'\b\d+(\.\d+)?\b');
}

/// Matches capitalized words typically representing class names (e.g., `MyClassName`).
class CapitalizedWordSyntaxRule extends SyntaxRule {
  const CapitalizedWordSyntaxRule();

  @override
  String get name => 'capitalized-word-style';

  @override
  RegExp get pattern => RegExp(r'\b[A-Z][a-zA-Z0-9_]*\b');
}

/// Matches identifiers starting with a lowercase letter that are immediately
/// followed by a `(` or `{`, typically representing function or method calls.
class DotNotationSyntaxRule extends SyntaxRule {
  const DotNotationSyntaxRule();

  @override
  String get name => 'dot-notation-style';

  @override
  RegExp get pattern => RegExp(r'\b([a-z][a-zA-Z0-9]*)\s*(?=[({])');
}
