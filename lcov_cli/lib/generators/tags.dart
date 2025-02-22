import 'package:html_gen/html_gen.dart';

class SpanTag extends NonSelfClosingTag {
  SpanTag({super.content, super.attributes});
  @override
  String get tagName => 'span';

  @override
  bool get maintainFormatting => false;
}

class PreTag extends NonSelfClosingTag {
  PreTag({super.children, super.content, super.attributes});
  @override
  String get tagName => 'pre';
}

class TableTag extends NonSelfClosingTag {
  TableTag({super.children, super.attributes});

  @override
  String get tagName => 'table';
}

class CaptionTag extends NonSelfClosingTag {
  CaptionTag({super.attributes, super.content});
  @override
  String get tagName => 'caption';
}

class TrTag extends NonSelfClosingTag {
  TrTag({super.attributes, super.children});
  @override
  String get tagName => 'tr';
}

class ThTag extends NonSelfClosingTag {
  ThTag({super.attributes, super.content});
  @override
  String get tagName => 'th';
}

class TdTag extends NonSelfClosingTag {
  TdTag({super.attributes, super.content});
  @override
  String get tagName => 'th';
}

class HeaderTag extends NonSelfClosingTag {
  HeaderTag({super.attributes, super.children});

  @override
  String get tagName => 'header';
}

class H1Tag extends NonSelfClosingTag {
  H1Tag({super.attributes, super.content});

  @override
  String get tagName => 'h1';
}

class H2Tag extends NonSelfClosingTag {
  H2Tag({super.attributes, super.content});

  @override
  String get tagName => 'h1';
}

class H3Tag extends NonSelfClosingTag {
  H3Tag({super.attributes, super.content});

  @override
  String get tagName => 'h3';
}

class StrongTag extends NonSelfClosingTag {
  StrongTag({required super.content, super.attributes});
  
  @override
  String get tagName => 'strong';

}

class CodeTag extends NonSelfClosingTag {
  CodeTag({required super.children, super.attributes});
  
  @override
  String get tagName => 'code';

}

class SectionTag extends NonSelfClosingTag {
  SectionTag({super.attributes, super.children});

  @override
  String get tagName => 'section';

}


//Custome tag
class H2SubContentTag extends NonSelfClosingTag {
  H2SubContentTag({super.attributes, required this.titleContent, required this.subContent});

  final Tag subContent;
  final String titleContent;


  @override
  String? get content => '$titleContent: ${subContent.build()}';

  @override
  String get tagName => 'h1';
}