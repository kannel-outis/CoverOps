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

}

class FileLine extends Line {
  FileLine({required super.lineNumber, required super.lineContent});

}
