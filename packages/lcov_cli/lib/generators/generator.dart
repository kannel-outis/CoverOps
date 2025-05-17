import 'dart:async';
import 'dart:io';

import 'package:lcov_cli/generators/console_report_generator.dart';
import 'package:lcov_cli/generators/html_files_gen.dart';
import 'package:lcov_cli/generators/json_file_report_generator.dart';
import 'package:lcov_cli/lcov_cli.dart';
import 'package:lcov_cli/models/code_file.dart';

/// An abstract class for generating reports from a list of code files.
/// 
/// This class serves as a base for different report generators (e.g., HTML, JSON, Console)
/// and provides a common interface for report generation and output directory creation.
abstract class ReportGenerator {
  /// The list of code files to be processed for the report.
  final List<CodeFile> codeFiles;
  
  /// The optional output directory where the report will be saved.
  /// If null, the report may be output to a default location or stdout.
  final String? outputDir;

  /// Factory constructor to create a specific report generator based on the report type.
  ///
  /// [type] specifies the type of report to generate (e.g., HTML, JSON, Console).
  /// [codeFiles] is the list of code files to include in the report.
  /// [outputDir] is the optional directory path where the report will be saved.
  ///
  /// Returns an instance of a concrete [ReportGenerator] subclass based on [type].
  factory ReportGenerator.ofType({
    required ReportType type,
    required List<CodeFile> codeFiles,
    required String? outputDir,
  }) {
    return switch (type) {
      ReportType.html => HtmlFilesReportGenerator(codeFiles: codeFiles, outputDir: outputDir),
      ReportType.json => JsonFileReportGenerator(codeFiles: codeFiles, outputDir: outputDir),
      ReportType.console => ConsoleReportGenerator(codeFiles: codeFiles, outputDir: outputDir),
    };
  }

  /// Constructor for creating a [ReportGenerator] instance.
  ///
  /// [codeFiles] is the list of code files to process.
  /// [outputDir] is the optional output directory for the report.
  ReportGenerator({required this.codeFiles, required this.outputDir});

  /// Generates the report and returns a list of generated files, if any.
  ///
  /// [rootPath] is an optional root path for resolving relative file paths.
  /// Returns a [Future] or synchronous [List<File>] containing the generated report files,
  /// or null if no files are generated (e.g., for console output).
  FutureOr<List<File>?> generate([String? rootPath]);

  /// Creates the output directory if it does not already exist.
  ///
  /// [outputDirectory] is the directory to create.
  /// Creates the directory recursively if needed.
  Future<void> createOutPutDir(Directory outputDirectory) async {
    if (await outputDirectory.exists()) return;
    await outputDirectory.create(recursive: true);
  }
}
