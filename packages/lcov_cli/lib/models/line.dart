class Line {
  Line({
    required this.lineNumber,
    this.lineContent = '',
    this.hitCount = 0,
    this.isModified = false,
    this.isLineHit = false,  //is line covered
    this.canHitLine = true,  // can line be covered, e.g imports cant be covered so they shiuld be noted
  });

  final int lineNumber;
  final String lineContent;
  final int hitCount;
  final bool isLineHit;
  final bool canHitLine;
  final bool isModified;

  Line copyWith({
    int? lineNumber,
    String? lineContent,
    int? hitCount,
    bool? isModified,
    bool? isLineHit,
    bool? canHitLine,
  }) {
    return Line(
      lineNumber: lineNumber ?? this.lineNumber,
      lineContent: lineContent ?? this.lineContent,
      hitCount: hitCount ?? this.hitCount,
      isModified: isModified ?? this.isModified,
      isLineHit: isLineHit ?? this.isLineHit,
      canHitLine: canHitLine ?? this.canHitLine,
    );
  }

  @override
  String toString() {
    return 'LcovLine{lineNumber: $lineNumber, lineContent: $lineContent, isLineCovered: $isLineHit}';
  }
}
class CoverageLine extends Line {
  CoverageLine({
    required super.lineNumber,
    required super.hitCount,
  });


  @override
  bool get isLineHit => hitCount > 0;

}


class GitLine extends Line {
  GitLine({required super.lineNumber, required this.hasLineChanged});

  final bool hasLineChanged;

  @override
  bool get isModified => hasLineChanged;

}

class FileLine extends Line {
  FileLine({required super.lineNumber, required super.lineContent});

}
