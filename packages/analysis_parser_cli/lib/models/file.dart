import 'package:analysis_parser_cli/utils/enums.dart';

final class AnalysisFile {
  const AnalysisFile({
    required this.path,
    this.lines = const [],
  });

  final String path;
  final List<AnalysisLine> lines;

  AnalysisFile copyWith({String? path, List<AnalysisLine>? lines}) {
    return AnalysisFile(
      path: path ?? this.path,
      lines: lines ?? this.lines,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AnalysisFile && other.path == path;
  }

  Map<String, dynamic> toJson() {
    return {
      'file': path,
      'lines': lines.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() => 'File{path: $path, lines: $lines}';
  
  @override
  int get hashCode => path.hashCode;
  
}

final class AnalysisLine {
  const AnalysisLine({
    required this.message,
    required this.lineNumber,
    required this.columnNumber,
    required this.type,
    this.rule,
  });

  final String message;
  final int lineNumber;
  final int columnNumber;
  final AnalysisType type;
  final String? rule;

  AnalysisLine copyWith({String? message, int? lineNumber, int? columnNumber, AnalysisType? type, String? rule}) {
    return AnalysisLine(
      message: message ?? this.message,
      lineNumber: lineNumber ?? this.lineNumber,
      columnNumber: columnNumber ?? this.columnNumber,
      type: type ?? this.type,
      rule: rule ?? this.rule,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line': lineNumber,
      'column': columnNumber,
      'type': type.name,
      'message': message,
      if (rule != null) 'rule': rule,
    };
  }

  @override
  String toString() {
    return 'Line{message: "$message", type: $type, line: $lineNumber, column: $columnNumber, rule: $rule}';
  }
}
