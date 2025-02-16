import 'package:lcov_cli/models/line.dart';

class LcovGroup {
  final String fileName;
  final int functionsFound;
  final int linesFound;
  final int linesHit;
  final List<CoverageLine> lines;

  LcovGroup({
    required this.fileName,
    required this.functionsFound,
    required this.linesFound,
    required this.linesHit,
    required this.lines,
  });

  double get lineCoveragePercentage {
    if (linesFound == 0) return 0.0;
    return (linesHit / linesFound) * 100;
  }

  @override
  String toString() {
    return 'File: $fileName\n'
        'Lines Found: $linesFound, Lines Hit: $linesHit, Coverage: ${lineCoveragePercentage.toStringAsFixed(2)}%\n'
        'Functions Found: $functionsFound, \n';
  }
}


class FileGroup {
  final List<String> content;
  final String filePath;

  FileGroup({required this.content, required this.filePath});
}
