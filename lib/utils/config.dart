import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:cover_ops/utils/logger.dart';
import 'package:cover_ops/utils/utils.dart';

/// Key constants for configuration options.
const _lcovFileKey = 'lcov';
const _jsonCoverageKey = 'json';
const _gitParserFileKey = 'gitParserFile';
const _targetBranchKey = 'target-branch';
const _targetBranchFallbackKey = 'fallback';
const _sourceBranchKey = 'source-branch';
const _output = 'output';
const _outputDir = 'output-dir';
const _projectPathKey = 'projectPath';
const _configFile = 'config';
const _reportFormat = 'report-format';
const _reportType = 'reportType';

/// Stores configuration options for the CoverOps CLI tool.
///
/// This class encapsulates settings such as paths to coverage files, Git branch
/// details, and output directories. It can be populated from command-line
/// arguments or a JSON configuration file using [Config.fromArgs].
class Config {
  /// Path to the LCOV coverage file (e.g., `coverage/lcov.info`).
  final String? lcovFile;

  /// Path to the JSON coverage file.
  final String? jsonCoverage;

  /// Path to the Git analysis results file (e.g., `coverage/.gitparser.json`).
  final String? gitParserFile;

  /// Target branch for Git comparison (e.g., `main`).
  final String? targetBranch;

  /// Fallback branch if the target branch is unavailable (e.g., `master`).
  final String? targetBranchFallback;

  /// Source branch containing changes to analyze (e.g., `HEAD`).
  final String? sourceBranch;

  /// Output directory for reports (e.g., `coverage`).
  final String? output;

  /// Project root directory path.
  final String? projectPath;

  /// Report format (e.g., `html`, `json`, `console`).
  final String? reportFormat;

  /// Creates a [Config] instance with the specified options.
  ///
  /// All parameters are optional and can be null if not specified.
  ///
  /// Parameters:
  ///  - `lcovFile` Path to the LCOV coverage file.
  ///  - `jsonCoverage` Path to the JSON coverage file.
  ///  - `gitParserFile` Path to the Git analysis results file.
  ///  - `targetBranch` Target branch for Git comparison.
  ///  - `targetBranchFallback` Fallback branch if target is unavailable.
  ///  - `sourceBranch` Source branch with changes.
  ///  - `output` Output directory for reports.
  ///  - `projectPath` Project root directory.
  ///  - `reportFormat` Report format (e.g., `html`, `json`, `console`).
  Config({
    this.lcovFile,
    this.jsonCoverage,
    this.gitParserFile,
    this.targetBranch,
    this.targetBranchFallback,
    this.sourceBranch,
    this.output,
    this.projectPath,
    this.reportFormat,
  });

  /// Creates a [Config] instance from command-line arguments.
  ///
  /// This factory constructor merges settings from [args] with those from a JSON
  /// configuration file specified by the `--config` flag. For any keys present in
  /// the JSON file, file-based settings take precedence over the command-line arguments.
  ///
  /// Parameters:
  ///   - `args` The parsed command-line arguments from [ArgResults].
  /// returns A [Config] instance with merged settings.
  factory Config.fromArgs(ArgResults? args) {
    final configPath = args?[_configFile] as String?;
    final fileConfig = _FileConfig(configFilePath: configPath).getConfig();
    return Config(
      lcovFile: fileConfig?.lcovFile ?? args?[_lcovFileKey],
      jsonCoverage: fileConfig?.jsonCoverage ?? args?[_jsonCoverageKey],
      gitParserFile: fileConfig?.gitParserFile ?? args?[_gitParserFileKey],
      targetBranch: fileConfig?.targetBranch ?? args?[_targetBranchKey],
      targetBranchFallback: fileConfig?.targetBranchFallback ?? args?[_targetBranchFallbackKey],
      sourceBranch: fileConfig?.sourceBranch ?? args?[_sourceBranchKey],
      output: fileConfig?.output ?? args?[_output] ?? args?[_outputDir],
      projectPath: fileConfig?.projectPath ?? args?[_projectPathKey],
      reportFormat: fileConfig?.reportFormat ?? args?[_reportFormat],
    );
  }

  /// Creates a [Config] instance for Git parsing from command-line arguments.
  ///
  /// This factory constructor merges settings from [args] with those from a JSON
  /// configuration file specified by the `--config` flag. File-based settings
  /// take precedence for keys defined in the JSON file.
  ///
  /// Parameters:
  ///   - `args` The parsed command-line arguments from [ArgResults].
  /// returns A [Config] instance with merged settings for Git parsing.
  factory Config.gitParserfromArgs(ArgResults? args) {
    final configPath = args?[_configFile] as String?;
    final fileConfig = _FileConfig(configFilePath: configPath).getConfig();
    return Config(
      targetBranch: fileConfig?.targetBranch ?? args?[_targetBranchKey],
      targetBranchFallback: fileConfig?.targetBranchFallback ?? args?[_targetBranchFallbackKey],
      sourceBranch: fileConfig?.sourceBranch ?? args?[_sourceBranchKey],
      output: fileConfig?.output ?? args?[_outputDir],
      projectPath: fileConfig?.projectPath ?? args?[_projectPathKey],
    );
  }

  /// Creates a [Config] instance for LCOV parsing from command-line arguments.
  ///
  /// This factory constructor merges settings from [args] with those from a JSON
  /// configuration file specified by the `--config` flag. File-based settings
  /// take precedence for keys defined in the JSON file.
  ///
  /// Parameters:
  ///   - `args` The parsed command-line arguments from [ArgResults].
  /// returns A [Config] instance with merged settings for LCOV parsing.
  factory Config.lcovParserfromArgs(ArgResults? args) {
    final configPath = args?[_configFile] as String?;
    final fileConfig = _FileConfig(configFilePath: configPath).getConfig();
    return Config(
      lcovFile: fileConfig?.lcovFile ?? args?[_lcovFileKey],
      jsonCoverage: fileConfig?.jsonCoverage ?? args?[_jsonCoverageKey],
      gitParserFile: fileConfig?.gitParserFile ?? args?[_gitParserFileKey],
      output: fileConfig?.output ?? args?[_output],
      projectPath: fileConfig?.projectPath ?? args?[_projectPathKey],
      reportFormat: fileConfig?.reportFormat ?? args?[_reportType],
    );
  }

  /// Parses a JSON file into a map.
  ///
  /// Reads the content of [file] synchronously and decodes it as JSON. Returns an
  /// empty map if the file is not valid JSON or not a map.
  ///
  /// @param file The JSON configuration file to parse.
  /// @return A map containing the JSON data, or an empty map on failure.
  Map<String, dynamic> _parseFileToMap(File file) {
    final jsonString = file.readAsStringSync();
    final dynamic jsonData = jsonDecode(jsonString);
    if (jsonData is Map<String, dynamic>) {
      return jsonData;
    }
    return {};
  }
}

/// Helper class to parse JSON configuration files for CoverOps.
///
/// Extends [Config] to provide functionality for reading and parsing a JSON
/// configuration file specified by [configFilePath]. Converts JSON keys (camelCase)
/// to match CLI argument keys (kebab-case) where necessary.
class _FileConfig extends Config {
  /// Path to the JSON configuration file (e.g., `config.json`).
  final String? configFilePath;

  /// Creates a [_FileConfig] instance with the specified file path.
  ///
  /// @param configFilePath The path to the JSON configuration file.
  _FileConfig({required this.configFilePath});

  /// Parses the JSON configuration file and returns a [Config] instance.
  ///
  /// If [configFilePath] is null, returns null. Otherwise, reads the JSON file,
  /// parses it, and maps its keys to [Config] properties, handling camelCase to
  /// kebab-case conversions for certain keys.
  ///
  /// @return A [Config] instance with values from the JSON file, or null if
  ///         [configFilePath] is null.
  Config? getConfig() {
    if (configFilePath == null) {
      Logger.log('No config file provided. Using default values.');
      return null;
    }
    try {
      final configFile = File(configFilePath!);
      if (!configFile.existsSync()) {
        Logger.log('No config file provided. Using default values.');
        return null;
      }
      final args = _parseFileToMap(configFile);

      return Config(
        lcovFile: args[_lcovFileKey],
        jsonCoverage: args[_jsonCoverageKey],
        gitParserFile: args[_gitParserFileKey],
        targetBranch: args[_targetBranchKey.toCamelCase],
        targetBranchFallback: args[_targetBranchFallbackKey],
        sourceBranch: args[_sourceBranchKey.toCamelCase],
        output: args[_output],
        projectPath: args[_projectPathKey],
        reportFormat: (args[_reportFormat.toCamelCase] as List<dynamic>?)?.join(','),
      );
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }
}
