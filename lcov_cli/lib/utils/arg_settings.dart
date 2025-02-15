import 'dart:io';

import 'package:args/args.dart';
import 'package:lcov_cli/utils/enums.dart';

class ArgumentSettings {
  final String? lcovFile;
  final String? jsonFile;
  final String? outputDir;
  final String? projectPath;
  final bool isFlutterProject;

  ArgumentSettings({
    this.lcovFile,
    this.jsonFile,
    this.outputDir,
    this.projectPath,
    this.isFlutterProject = false,
  });

  static final _parser = ArgParser();

  factory ArgumentSettings.fromArgs(List<String> args) {
    const lcovFileKey = 'lcov';
    const jsonCoverageKey = 'json';
    const outputKey = 'output';
    final flutterProjectKey = 'flutter';
    final rootProjectPathKey = 'projectPath';

    _parser
      ..addOption(lcovFileKey, abbr: lcovFileKey.split('').first, help: 'Path to the LCOV file')
      ..addOption(jsonCoverageKey, abbr: jsonCoverageKey.split('').first, help: 'Path to the Json coverage file')
      ..addOption(outputKey, abbr: outputKey.split('').first, help: 'Path to the output directory')
      ..addOption(rootProjectPathKey, abbr: rootProjectPathKey.split('').first, help: 'Path to the project')
      ..addOption(flutterProjectKey, abbr: flutterProjectKey.split('').first, defaultsTo: 'false', help: 'Whether or not this is a Flutter project');

    final results = _parser.parse(args);

    return ArgumentSettings(
      lcovFile: results[lcovFileKey] as String?,
      jsonFile: results[jsonCoverageKey] as String?,
      outputDir: results[outputKey] as String?,
      projectPath: results[rootProjectPathKey] as String?,
      isFlutterProject: results[flutterProjectKey] == 'true',
    );
  }

  bool get hasCoverageFile {
    return lcovFile != null || jsonFile != null;
  }

  File get coverageFile {
    if (lcovFile != null) return File(lcovFile!);
    if (jsonFile != null) return File(jsonFile!);
    throw ArgumentError('No coverage file provided');
  }

  ParserType get parserType {
    if (lcovFile != null) return ParserType.lcov;
    if (jsonFile != null) return ParserType.json;
    throw ArgumentError('No coverage file provided');
  }

}