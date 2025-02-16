/// A base class for HTML tags that provides common functionality for building HTML elements.
abstract class Tag {
  /// Optional attributes for the HTML tag, stored as key-value pairs.
  final Map<String, dynamic>? attributes;

  /// Optional child tags that will be nested within this tag.
  final List<Tag>? children;

  /// Optional text content that will be placed between the opening and closing tags.
  final String? content;

  /// Creates a new Tag instance with optional attributes, children, and content.
  ///
  /// Throws an [ArgumentError] if a self-closing tag is created with children or content.
  Tag({this.attributes, this.children, this.content}) {
    assert(!isSelfClosing || (children == null && content == null), 'Self-closing tags cannot have children or content.');
  }
  /// Must be implemented by subclasses.
  String get tagName;

  /// Indicates whether the tag is self-closing (e.g., <img />, <br />).
  bool get isSelfClosing;

  /// Builds the HTML string representation of the tag with proper indentation.
  ///
  /// Parameters:
  ///   - indentLevel: The number of indentation levels to apply (default: 0)
  ///
  /// Returns a properly formatted HTML string with:
  ///   - Correct indentation based on the indent level
  ///   - Attributes formatted as key="value" pairs
  ///   - Self-closing tags handled appropriately
  ///   - Content displayed inline when present
  ///   - Nested children properly indented
  String build({int indentLevel = 0}) {
    final indent = ' ' * (indentLevel * 4); // 4 spaces per indent level
    final attributesString = attributes?.entries.map((entry) => '${entry.key}="${entry.value}"').join(' ');
    final formattedAttributes = (attributesString != null && attributesString.isNotEmpty) ? ' $attributesString' : '';

    // Handle self-closing tags
    if (isSelfClosing) {
      return '$indent<$tagName$formattedAttributes />';
    }

    // If content exists, display it on the same line as the tag
    if (content != null && content!.isNotEmpty) {
      return '$indent<$tagName$formattedAttributes>$content</$tagName>';
    }

    // Handle children if no content
    final childrenString = children?.map((child) => child.build(indentLevel: indentLevel + 1)).join('\n') ?? '';

    // Generate tag with children
    if (childrenString.isNotEmpty) {
      return '$indent<$tagName$formattedAttributes>\n$childrenString\n$indent</$tagName>';
    }

    // If no children or content
    return '$indent<$tagName$formattedAttributes></$tagName>';
  }
}

/// A base class for HTML tags that are not self-closing (e.g., <div>, <p>, <span>).
///
/// These tags can have children elements and content text.
abstract class NonSelfClosingTag extends Tag {
  /// Creates a new non-self-closing HTML tag.
  ///
  /// Parameters:
  ///   - attributes: Optional map of HTML attributes
  ///   - children: Optional list of child tags
  ///   - content: Optional text content
  NonSelfClosingTag({
    super.attributes,
    super.children,
    super.content,
  });

  /// Always returns false since this is not a self-closing tag.
  @override
  bool get isSelfClosing => false;

  @override
  String get tagName;
}

/// A base class for HTML tags that are self-closing (e.g., <img/>, <br/>, <input/>).
///
/// Self-closing tags cannot have children or content, only attributes.
abstract class SelfClosingTag extends Tag {
  /// Creates a new self-closing HTML tag.
  ///
  /// Parameters:
  ///   - attributes: Optional map of HTML attributes
  SelfClosingTag({super.attributes});

  /// Always returns true since this is a self-closing tag.
  @override
  bool get isSelfClosing => true;

  @override
  String get tagName;
}
