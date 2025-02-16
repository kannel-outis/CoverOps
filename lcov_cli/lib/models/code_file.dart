import 'package:lcov_cli/models/line.dart';

class CodeFile {
  final String path;
  final List<Line> codeLines;

  const CodeFile({required this.path, required this.codeLines});

  int get totalCodeLines => codeLines.lastOrNull?.lineNumber ?? 0;
  int get totalCoveredLines => codeLines.where((line) => line.isLineHit).length;
  int get totalModifiedLines => codeLines.where((line) => line.isModified).length;

  String get totalCoveragePercentage {
    if (totalCodeLines == 0) return '0 %';
    return '${((totalCoveredLines / totalCodeLines) * 100)} %';
  }
}