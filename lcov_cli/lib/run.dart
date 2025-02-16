import 'dart:io';

import 'package:lcov_cli/lcov_cli.dart';
import 'package:lcov_cli/parsers/code_file_parser.dart';
import 'package:lcov_cli/parsers/json_parser.dart';
import 'package:lcov_cli/parsers/total_code_coverage_file_parser.dart';

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

    await process(coverageFile, Directory(outputDir.orEmpty), settings.parserType, parsedProjectDir.path, settings.gitParserJsonFile?.path);
  }

  Future<void> process(File file, Directory outputDir, ParserType type, String? rootPath, String? gitparserFile) async {

    LineParser? gitJsonParser;
    if (gitparserFile != null) {
      gitJsonParser = JsonFileLineParser(File(gitparserFile));
    }

    final LineParser lcovLineParser = LineParser.fromType(type, file);
    final lcovLines = await lcovLineParser.parsedLines(rootPath);
    final LineParser codeFileParser = CodeFileParser(filePaths: lcovLines.map((line)=> line.path).toList());
    final totalCodeCoverageParser = TotalCodeCoverageFileParser(
      coverageCodeFiles: lcovLines,
      originalCodeFiles: await codeFileParser.parsedLines(rootPath),
      jsonCodeFiles: gitJsonParser != null ? await gitJsonParser.parsedLines(rootPath) : null,
    );
    final codeFiles = await totalCodeCoverageParser.parsedLines(rootPath);


    for (var file in codeFiles) {
      print('${file.path}:${file.totalModifiedLines}');
      // print(file.path);
      // for (var codeLine in file.codeLines) {
      //   print(' ${codeLine.lineNumber}: ${codeLine.lineContent}    | isNewLine:${codeLine.isModified} isLineCovered:${codeLine.canHitLine ? codeLine.isLineHit : true}');
      // }
    }

    print(codeFiles.map((codeFile)=> codeFile.totalModifiedLines > 0).toList().where((mod)=> mod).length);
    // print(codeFiles.length);
    
  }
}
