class Line {
  Line({
    required this.lineNumber,
    this.lineContent = '',
    this.hitCount = 0,
    this.isLineHit = false,  //is line covered
    this.canHitLine = true,  // can line be covered, e.g imports cant be covered so they shiuld be noted
  });

  final int lineNumber;
  final String lineContent;
  final int hitCount;
  final bool isLineHit;
  final bool canHitLine;

  @override
  String toString() {
    return 'LcovLine{lineNumber: $lineNumber, lineContent: $lineContent, isLineCovered: $isLineHit}';
  }
}

class LcovLine extends Line {
  LcovLine({
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
