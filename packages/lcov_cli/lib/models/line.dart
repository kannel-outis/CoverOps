class Line {
  Line({
    required this.lineNumber,
    this.lineContent = '',
    this.hitCount = 0,
    this.isModified = false,
    this.isLineHit = false,  //is line covered
    this.canHitLine = true,  // can line be covered, e.g imports cant be covered so they shiuld be noted
    this.qualityAnalysisIssues,
  });

  final int lineNumber;
  final String lineContent;
  final int hitCount;
  final bool isLineHit;
  final bool canHitLine;
  final bool isModified;
  final QualityAnalysisIssues? qualityAnalysisIssues;

  Line copyWith({
    int? lineNumber,
    String? lineContent,
    int? hitCount,
    bool? isModified,
    bool? isLineHit,
    bool? canHitLine,
    QualityAnalysisIssues? qualityAnalysisIssues,
  }) {
    return Line(
      lineNumber: lineNumber ?? this.lineNumber,
      lineContent: lineContent ?? this.lineContent,
      hitCount: hitCount ?? this.hitCount,
      isModified: isModified ?? this.isModified,
      isLineHit: isLineHit ?? this.isLineHit,
      canHitLine: canHitLine ?? this.canHitLine,
      qualityAnalysisIssues: qualityAnalysisIssues ?? this.qualityAnalysisIssues,
    );
  }

  bool get hasQualityIssues => qualityAnalysisIssues != null;

  @override
  String toString() {
    return 'LcovLine{lineNumber: $lineNumber, lineContent: $lineContent, isLineCovered: $isLineHit}';
  }
}

final class QualityAnalysisIssues {
  final String message;
  final String type;
  final String? rule;

  QualityAnalysisIssues({
    required this.message,
    required this.type,
    this.rule,
  });
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

class QualityLine extends Line {
  QualityLine({
    required super.lineNumber,
    required this.message,
    required this.type,
    this.rule,
  }) : super(
          qualityAnalysisIssues: QualityAnalysisIssues(
            message: message,
            type: type,
            rule: rule,
          ),
        );

  final String message;
  final String type;
  final String? rule;
}
