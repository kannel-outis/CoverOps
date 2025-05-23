import 'package:html_generator/html_generator.dart';

/// Self-Closing Tags
/// Represents a line break HTML element (<br>)
class BrTag extends SelfClosingTag {
  @override
  String get tagName => 'br';
}

/// Represents an image HTML element (<img>)
class ImgTag extends SelfClosingTag {
  ImgTag({super.attributes});

  @override
  String get tagName => 'img';
}

/// Represents a meta HTML element (<meta>)
class MetaTag extends SelfClosingTag {
  MetaTag({super.attributes});

  @override
  String get tagName => 'meta';
}

/// Non-Self-Closing Tags

/// Represents a div HTML element (<div>)
class DivTag extends NonSelfClosingTag {
  DivTag({super.attributes, super.children, super.content});

  @override
  String get tagName => 'div';
}

/// Represents a paragraph HTML element (<p>)
class PTag extends NonSelfClosingTag {
  PTag({super.attributes, super.content});

  @override
  String get tagName => 'p';
}

/// Represents an unordered list HTML element (<ul>)
class UlTag extends NonSelfClosingTag {
  UlTag({super.attributes, super.children});

  @override
  String get tagName => 'ul';
}

/// Represents a list item HTML element (<li>)
class LiTag extends NonSelfClosingTag {
  LiTag({super.attributes, super.content, super.children});

  @override
  String get tagName => 'li';
}

/// Represents an anchor HTML element (<a>)
class ATag extends NonSelfClosingTag {
  ATag({required this.href, this.additionalAttributes, super.content, super.children});

  final String href;
  final Map<String, dynamic>? additionalAttributes;

  @override
  Map<String, dynamic>? get attributes => {'href': href, ...?additionalAttributes};

  @override
  String get tagName => 'a';
}

/// Represents the root HTML element (<html>)
class HtmlTag extends NonSelfClosingTag {
  HtmlTag({super.attributes, super.children});

  @override
  String get tagName => 'html';
}

/// Represents the head HTML element (<head>)
class HeadTag extends NonSelfClosingTag {
  HeadTag({super.attributes, super.children});

  @override
  String get tagName => 'head';
}

/// Represents the body HTML element (<body>)
class BodyTag extends NonSelfClosingTag {
  BodyTag({super.attributes, super.children});

  @override
  String get tagName => 'body';
}

class StyleLinkTag extends SelfClosingTag {
  StyleLinkTag({required this.css});
  final String css;


  @override
  Map<String, dynamic>? get attributes => {'rel': 'stylesheet', 'href': css, 'type': 'text/css'};
  
  @override
  String get tagName => 'link';


}
