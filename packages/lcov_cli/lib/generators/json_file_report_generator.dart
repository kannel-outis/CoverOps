import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:lcov_cli/generators/generator.dart';
import 'package:lcov_cli/utils/utils.dart';

/// A concrete implementation of [ReportGenerator] that produces a JSON report
/// summarizing code coverage metrics for the provided list of code files.
///
/// This generator aggregates coverage data such as total lines of code, covered lines,
/// modified lines, and coverage percentages, and writes it to a JSON file
/// in the specified output directory.
class JsonFileReportGenerator extends ReportGenerator {
  /// Creates a [JsonFileReportGenerator] instance.
  ///
  /// [codeFiles] is the list of code files to analyze.
  /// [outputDir] specifies the directory where the generated JSON report will be saved.
  JsonFileReportGenerator({required super.codeFiles, required super.outputDir});

  /// Returns the output directory as a [Directory] object.
  Directory get outputDirectory => Directory('$outputDir');

  /// Generates a JSON report containing aggregated code coverage metrics.
  ///
  /// Iterates over the provided [codeFiles] to collect and summarize coverage data,
  /// including metrics such as:
  /// - Total code lines
  /// - Total hittable lines
  /// - Total covered and missed lines
  /// - Modified lines and their coverage
  /// - Per-file coverage percentages
  ///
  /// The final report is written to `report.json` inside the [outputDir].
  ///
  /// [rootPath] is an optional root directory used for resolving relative paths
  ///
  /// Returns a [Future] that resolves to a list containing the generated JSON [File].
  @override
  FutureOr<List<File>?> generate([String? rootPath]) async {
    int totalCodeLines = 0;
    int totalHittableLines = 0;
    int totalFiles = 0;
    int totalHittableModifiedLines = 0;
    int totalCoveredLines = 0;
    int totalLinesMissed = 0;
    int totalModifiedLines = 0;
    int totalHitOnModifiedLines = 0;
    Map<String, String> filesHitMap = {};

    for (var file in codeFiles) {
      totalCodeLines += file.totalCodeLines;
      totalFiles++;
      totalCoveredLines += file.totalCoveredLines;
      totalModifiedLines += file.totalModifiedLines;
      totalHitOnModifiedLines += file.totalHitOnModifiedLines;
      totalHittableModifiedLines += file.totalHittableModifiedLines;
      totalHittableLines += file.totalHittableLines;
      filesHitMap[file.path] = file.totalCoveragePercentage;
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
      'total_coverage_percentage':
          totalCoveragePercentage(totalCoveredLines, totalHittableLines),
      'total_coverage_percentage_on_modified':
          totalCoveragePercentage(totalHitOnModifiedLines, totalHittableModifiedLines),
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
