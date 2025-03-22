import 'dart:io';

import 'package:lcov_cli/generators/html_files_gen.dart';
import 'package:lcov_cli/lcov_cli.dart';
import 'package:lcov_cli/parsers/code_coverage_file_parser.dart';
import 'package:lcov_cli/parsers/json_parser.dart';

class LcovCli {
  Future<void> run(List<String> args) async {
    final stopwatch = Stopwatch()..start();
    final settings = ArgumentSettings.fromArgs(args);

    if (!settings.hasCoverageFile || settings.outputDir.isNull) {
      exitWithMessage('Please provide a valid coverage file path and output directory path.');
    }

    final coverageFile = settings.coverageFile;
    final outputDir = settings.outputDir;

    final projectPath = settings.projectPath ?? coverageFile.path.split('/coverage').firstOrNull;
    print(projectPath);
    final parsedProjectDir = Directory(projectPath?.toString() ?? '');

    if (!parsedProjectDir.existsSync()) exitWithMessage('Cannot find project, please provide a valid project path --> $projectPath');

    await process(coverageFile, Directory(outputDir.orEmpty), settings.parserType, parsedProjectDir.path, settings.gitParserJsonFile?.path,);
    stopwatch.stop();

    print('Execution time: ${stopwatch.elapsedMilliseconds} ms');
  }

  Future<void> process(File file, Directory outputDir, ParserType type, String? rootPath, String? gitparserFile) async {
    LineParser? gitJsonParser;
    if (gitparserFile != null) {
      gitJsonParser = JsonFileLineParser(File(gitparserFile));
    }

    final LineParser lcovLineParser = LineParser.fromType(type, file);
    final lcovLines = await lcovLineParser.parsedLines(rootPath);
    final totalCodeCoverageParser = CodeCoverageFileParser(
      coverageCodeFiles: lcovLines,
      modifiedCodeFiles: gitJsonParser != null ? await gitJsonParser.parsedLines(rootPath) : null,
    );
    final codeFiles = await totalCodeCoverageParser.parsedLines(rootPath);
    await HtmlFilesGen().generateHtmlFiles(codeFiles, outputDir.path);
  }
}
