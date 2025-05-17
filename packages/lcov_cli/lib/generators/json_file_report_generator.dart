import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:lcov_cli/generators/generator.dart';
import 'package:lcov_cli/utils/utils.dart';

class JsonFileReportGenerator extends ReportGenerator {
  JsonFileReportGenerator({required super.codeFiles, required super.outputDir});

  Directory get outputDirectory => Directory('$outputDir');

  @override
  FutureOr<List<File>?> generate([String? rootPath]) async {
    int totalCodeLines = 0;
    int totalHittableLines = 0;
    int totalFiles = 0;
    int totalHittableModifiedLines = 0;
    Map<String, String> filesHitMap = {};
    int totalCoveredLines = 0;
    int totalLinesMissed = 0;
    int totalModifiedLines = 0;
    int totalHitOnModifiedLines = 0;

    for (var file in codeFiles) {
      totalCodeLines += file.totalCodeLines;
      totalFiles++;
      totalCoveredLines += file.totalCoveredLines;
      totalModifiedLines += file.totalModifiedLines;
      totalHitOnModifiedLines += file.totalHitOnModifiedLines;
      filesHitMap[file.path] = file.totalCoveragePercentage;
      totalHittableModifiedLines += file.totalHittableModifiedLines;
      totalHittableLines += file.totalHittableLines;
    
    }
    totalLinesMissed = totalHittableLines - totalCoveredLines;


    final json = {
      'total_lines': totalCodeLines,
      'total_files': totalFiles,
      'total_hittable_lines': totalHittableLines,
      'total_covered_lines': totalCoveredLines,
      'total_lines_missed': totalLinesMissed,
      'total_hittable_modified_lines': totalHittableModifiedLines,
      'total_hit_on_modified_lines': totalHitOnModifiedLines,
      'total_modified_lines': totalModifiedLines,
      'files': filesHitMap,
      'total_coverage_percentage': totalCoveragePercentage(totalCoveredLines, totalHittableLines),
      'total_coverage_percentage_on_modified': totalCoveragePercentage(totalHitOnModifiedLines, totalHittableModifiedLines),
    };
    await createOutPutDir(outputDirectory);
    final jsonFile = File('${outputDirectory.path}/report.json');
    if (await jsonFile.exists()) {
      await jsonFile.delete();
    }
    await jsonFile.writeAsString(jsonEncode(json));
    return [jsonFile];
  }
}
