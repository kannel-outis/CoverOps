import 'package:html_gen/src/tag.dart';

/// Self-Closing Tags
/// Represents a line break HTML element (<br>)
class BrTag extends SelfClosingTag {
  @override
  String get tagName => 'br';
}

/// Represents an image HTML element (<img>)
class ImgTag extends SelfClosingTag {
  /// Creates an ImgTag with optional attributes
  ImgTag({super.attributes});

  @override
  String get tagName => 'img';
}

/// Represents a meta HTML element (<meta>)
class MetaTag extends SelfClosingTag {
  /// Creates a MetaTag with optional attributes
  MetaTag({super.attributes});

  @override
  String get tagName => 'meta';
}

/// Non-Self-Closing Tags

/// Represents a div HTML element (<div>)
class DivTag extends NonSelfClosingTag {
  /// Creates a DivTag with optional attributes, children, and content
  DivTag({super.attributes, super.children, super.content});

  @override
  String get tagName => 'div';
}

/// Represents a paragraph HTML element (<p>)
class PTag extends NonSelfClosingTag {
  /// Creates a PTag with optional attributes and content
  PTag({super.attributes, super.content});

  @override
  String get tagName => 'p';
}

/// Represents an unordered list HTML element (<ul>)
class UlTag extends NonSelfClosingTag {
  /// Creates a UlTag with optional attributes and children
  UlTag({super.attributes, super.children});

  @override
  String get tagName => 'ul';
}

/// Represents a list item HTML element (<li>)
class LiTag extends NonSelfClosingTag {
  /// Creates an LiTag with optional attributes, content, and children
  LiTag({super.attributes, super.content, super.children});

  @override
  String get tagName => 'li';
}

/// Represents an anchor HTML element (<a>)
class ATag extends NonSelfClosingTag {
  /// Creates an ATag with optional attributes and content
  ATag({super.attributes, super.content});

  @override
  String get tagName => 'a';
}

/// Represents the root HTML element (<html>)
class HtmlTag extends NonSelfClosingTag {
  /// Creates an HtmlTag with optional attributes and children
  HtmlTag({super.attributes, super.children});

  @override
  String get tagName => 'html';
}

/// Represents the head HTML element (<head>)
class HeadTag extends NonSelfClosingTag {
  /// Creates a HeadTag with optional attributes and children
  HeadTag({super.attributes, super.children});

  @override
  String get tagName => 'head';
}

/// Represents the body HTML element (<body>)
class BodyTag extends NonSelfClosingTag {
  /// Creates a BodyTag with optional attributes and children
  BodyTag({super.attributes, super.children});

  @override
  String get tagName => 'body';
}