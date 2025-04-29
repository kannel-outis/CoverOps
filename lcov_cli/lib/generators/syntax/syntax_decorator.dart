import 'package:lcov_cli/generators/syntax/syntax_rule.dart';
import 'package:lcov_cli/generators/tags.dart';
import 'package:lcov_cli/models/line.dart';
import 'package:lcov_cli/utils/chain/chain_link.dart';
import 'package:lcov_cli/utils/chain/style_chain.dart';
import 'package:lcov_cli/utils/utils.dart';

/// A utility class for applying syntax highlighting rules to text content.
/// This class processes text content and applies specified syntax rules to create
/// styled HTML spans for syntax highlighting.
class SyntaxDecorator {
  /// Creates a new [SyntaxDecorator] instance.
  ///
  /// [content] is the text to be processed.
  /// [rules] is an optional list of syntax rules to apply (defaults to [SyntaxRule.rules]).
  SyntaxDecorator({required this.content, this.rules = SyntaxRule.rules});

  /// The list of syntax rules to apply to the content.
  final List<SyntaxRule> rules;

  /// The text content to be processed.
  final String content;

  /// Applies the syntax rules to the content and returns the styled HTML output.
  ///
  /// This method processes the content by:
  /// 1. Finding matches for each syntax rule
  /// 2. Avoiding overlapping matches
  /// 3. Creating styled spans for matched content
  /// 4. Preserving unmatched content with default styling
  String applyRules() {
    final buffer = StringBuffer();
    final styledSpans = <_StyledSpan>[];

    final matchedPositions = List<bool>.filled(content.length, false);

    for (final rule in rules) {
      for (final match in rule.pattern.allMatches(content)) {
        // Skip already matched regions to avoid nesting styles
        bool isOverlap = false;
        for (int i = match.start; i < match.end; i++) {
          if (matchedPositions[i]) {
            isOverlap = true;
            break;
          }
        }
        if (isOverlap) continue;

        // Mark as matched
        for (int i = match.start; i < match.end; i++) {
          matchedPositions[i] = true;
        }

        styledSpans.add(
          _StyledSpan(
            match.start,
            match.end,
            SpanTag(attributes: {'class': rule.name}, content: cleanContent(match.group(0)!)).build(),
          ),
        );
      }
    }

    styledSpans.sort((a, b) => a.start.compareTo(b.start));

    int currentIndex = 0;
    for (final span in styledSpans) {
      if (currentIndex < span.start) {
        final unmatched = content.substring(currentIndex, span.start);
        buffer.write(
          SpanTag(attributes: {'class': 'default-style'}, content: cleanContent(unmatched)).build(),
        );
      }
      buffer.write(span.content);
      currentIndex = span.end;
    }

    // Preserve any remaining unmatched content (including final newline)
    if (currentIndex < content.length) {
      final unmatched = content.substring(currentIndex);
      buffer.write(
        SpanTag(attributes: {'class': 'default-style'}, content: cleanContent(unmatched)).build(),
      );
    }

    return buffer.toString();
  }
}

/// Internal helper class to store information about styled content spans.
class _StyledSpan {
  /// The starting position of the span in the original content.
  final int start;

  /// The ending position of the span in the original content.
  final int end;

  /// The styled HTML content for this span.
  final String content;

  /// Creates a new [_StyledSpan] instance.
  _StyledSpan(this.start, this.end, this.content);
}

/// A decorator class for applying syntax highlighting to test code lines.
/// This class processes multiple lines of code and applies both syntax highlighting
/// and coverage/modification styling.
class StyleDecorator {
  /// The lines of code to process.
  final List<Line> codeLines;

  /// The syntax rules to apply for highlighting.
  final List<SyntaxRule> rules;

  /// Creates a new [StyleDecorator] instance.
  ///
  /// [codeLines] is the list of code lines to process.
  /// [rules] is an optional list of syntax rules to apply (defaults to [SyntaxRule.rules]).
  StyleDecorator({required this.codeLines, this.rules = SyntaxRule.rules});

  /// Applies syntax highlighting and styling rules to all code lines.
  ///
  /// Returns the complete styled HTML output for all processed lines.
  String applyRules() {
    StringBuffer fileContentBuffer = StringBuffer();
    for (final line in codeLines) {
      final syntaxDecorator = SyntaxDecorator(content: line.lineContent, rules: rules);
      Chain<ChainLinkLine>.builder()
        ..then(
          RootChainLink(
              data: ChainLinkLine(
            line: line.copyWith(lineContent: syntaxDecorator.applyRules()),
            buffer: fileContentBuffer,
          )),
        )
        ..then(CoveredStyle())
        ..then(ModifiedStyle())
        ..build();
    }

    return fileContentBuffer.toString();
  }
}
