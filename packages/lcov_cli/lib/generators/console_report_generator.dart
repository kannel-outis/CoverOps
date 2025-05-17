import 'dart:async';
import 'dart:io';
import 'package:cli_table/cli_table.dart';
import 'package:lcov_cli/generators/generator.dart';
import 'package:lcov_cli/lcov_cli.dart';

/// A [ReportGenerator] implementation that generates and displays
/// a test coverage report directly in the console in a tabular format.
///
/// This generator is useful for quick inspection of code coverage
/// metrics without the need for external files. It summarizes total and per-file
/// coverage statistics, including coverage of modified lines.
class ConsoleReportGenerator extends ReportGenerator {
  /// Creates a [ConsoleReportGenerator] instance.
  ///
  /// [codeFiles] is the list of code files to include in the report.
  /// [outputDir] is accepted but unused, since this generator outputs to the console.
  ConsoleReportGenerator({required super.codeFiles, required super.outputDir});

  /// Generates a test coverage report and prints it to the console.
  ///
  /// This method aggregates data such as:
  /// - Total and covered lines
  /// - Modified lines and their coverage
  /// - Per-file metrics including coverage percentages
  ///
  /// [rootPath] is optionally used to compute relative file paths for display.
  ///
  /// Returns `null` since no file is produced.
  @override
  FutureOr<List<File>?> generate([String? rootPath]) {
    int totalFiles = 0;
    int totalHittableLines = 0;
    int totalCoveredLines = 0;
    int totalModifiedLines = 0;
    int totalHitOnModifiedLines = 0;
    int totalHittableModifiedLines = 0;

    final Map<String, String> filesHitMap = {};
    final List<List<dynamic>> reportData = [];

    // Aggregate coverage metrics for each file.
    for (var file in codeFiles) {
      totalFiles++;
      totalCoveredLines += file.totalCoveredLines;
      totalModifiedLines += file.totalModifiedLines;
      totalHitOnModifiedLines += file.totalHitOnModifiedLines;
      totalHittableModifiedLines += file.totalHittableModifiedLines;
      totalHittableLines += file.totalHittableLines;

      filesHitMap[file.path] = file.totalCoveragePercentage;

      final path = rootPath != null ? file.path.split(rootPath).last : file.path;

      reportData.add([
        path.blue,
        file.totalHittableLines.toString().grey,
        file.totalCoveredLines.toString().grey,
        file.totalHittableModifiedLines.toString().grey,
        file.totalHitOnModifiedLines.toString().grey,
        file.totalCoveragePercentage.prettifyPercentage(),
        {
          'content': file.isModified
              ? totalCoveragePercentage(
                  file.totalHitOnModifiedLines,
                  file.totalHittableModifiedLines,
                ).prettifyPercentage()
              : '-'.grey,
          'hAlign': HorizontalAlign.right,
        },
      ]);
    }

    // Build summary content for header display.
    final reportHeaderContent = {
      'Total Files               : ${totalFiles.toString().padRight(6).grey}',
      'Total Hittable Code Lines : ${totalHittableLines.toString().padRight(6).grey}',
      'Total Covered Lines       : ${totalCoveredLines.toString().padRight(6).grey}',
      'Total Modified Lines      : ${totalModifiedLines.toString().padRight(6).grey}',
      'Total Coverage            : ${totalCoveragePercentage(totalCoveredLines, totalHittableLines).prettifyPercentage().padRight(5)}',
      'Coverage on Modified Lines: ${totalCoveragePercentage(totalHitOnModifiedLines, totalHittableModifiedLines).prettifyPercentage().padRight(5)}',
    };

    // Construct and print the report table.
    final table = Table(
      header: [
        {
          'content': 'Test Coverage Report',
          'colSpan': 7,
          'hAlign': HorizontalAlign.center,
        },
      ],
      style: TableStyle(header: ['blue']),
    )
      ..add([
        {
          'content': reportHeaderContent.join('\n'),
          'colSpan': 7,
          'hAlign': HorizontalAlign.right,
        },
      ])
      ..add([
        'File',
        'Total Hittable Lines',
        'Total Covered Lines',
        'Total Modified Lines',
        'Covered Lines (Modified)',
        'Total Coverage',
        'Coverage on Modified',
      ])
      ..addAll(reportData);

    print(table.toString());
    return null;
  }
}
