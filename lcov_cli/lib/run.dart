import 'dart:io';

import 'package:lcov_cli/lcov_cli.dart';
// import 'package:path/path.dart';

class LcovCli {
  Future<void> run(List<String> args) async {
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

    await process(coverageFile, Directory(outputDir.orEmpty), settings.parserType, parsedProjectDir.path);
  }

  Future<void> process(File file, Directory outputDir, ParserType type, String? rootPath) async {
    final parser = LineParser.fromType(type, file);
    final lines = await parser.parsedLines(rootPath);
    print(lines.first.path);

    for (var line in lines.first.codeLines) {
      print('${line.canHitLine}       -->        ${line.lineNumber}');
    }
  }
}
