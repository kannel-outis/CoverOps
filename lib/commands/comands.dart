import 'dart:async';
import 'dart:convert';
import 'dart:io' hide Process;
import 'package:cover_ops/utils/config.dart';
import 'package:cover_ops/utils/logger.dart';
import 'package:process/process.dart';

import 'package:args/command_runner.dart';
import 'package:cover_ops/utils/utils.dart';

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

class GitCliCommand extends Command<int> {
  GitCliCommand() {
    addArgParser();
  }

  void addArgParser() {
    try {
      argParser
        ..addOption(_targetBranchFallbackKey,
            abbr: _targetBranchFallbackKey.split('').first,
            defaultsTo: 'main',
            help: 'Fallback branch if target branch is not found. This branch will be used if the specified target branch does not exist.')
        ..addOption(_targetBranchKey,
            abbr: _targetBranchKey.split('').first, defaultsTo: 'master', help: 'Target branch for comparison. This is the branch against which the source branch will be compared for changes.')
        ..addOption(_sourceBranchKey,
            abbr: _sourceBranchKey.split('').first, defaultsTo: 'HEAD', help: 'Source branch for comparison. This branch contains the changes that will be analyzed against the target branch.')
        ..addOption(_outputDir, abbr: _output.split('').first, help: 'Path to the output directory where the analysis results will be saved.')
        ..addOption(_projectPathKey, abbr: _projectPathKey.split('').first, help: 'Path to the project root directory that contains the source code to be analyzed.');
    } catch (e) {
      Logger.error(e);
      exit(-1);
    }
  }

  @override
  String get description => 'Git Parser CLI Command Line Tool - Analyzes git changes between branches and generates detailed comparison reports';

  @override
  String get name => 'git';

  @override
  FutureOr<int>? run() async {
    try {
      final config = Config.fromArgs(argResults);
      final targetBranch = config.targetBranch;
      final targetBranchFallback = config.targetBranchFallback;
      final sourceBranch = config.sourceBranch;
      final outputDir = config.output;
      final projectPath = config.projectPath;

      final result = await Process.instance.start(
        'dart',
        [
          '${Utils.root}/git_parser_cli/bin/git_parser_cli.dart',
          if (targetBranch != null) ...[
            '--target-branch',
            targetBranch,
          ],
          if (targetBranchFallback != null) ...[
            '--fallback',
            targetBranchFallback,
          ],
          if (sourceBranch != null) ...[
            '--source-branch',
            sourceBranch,
          ],
          if (outputDir != null) ...[
            '--output-dir',
            outputDir,
          ],
          if (projectPath != null) ...[
            '--project-dir',
            projectPath,
          ]
        ],
        runInShell: true,
      );
      result.stdout.transform(utf8.decoder).listen(stdout.write);
      result.stderr.transform(utf8.decoder).listen(stderr.write);

      return await result.exitCode;
    } catch (e) {
      Logger.error(e);
      return 1;
    }
  }
}

class LcovCliCommand extends Command<int> {
  LcovCliCommand() {
    addArgParser();
  }

  void addArgParser() {
    try {
      argParser
        ..addOption(_lcovFileKey, abbr: _lcovFileKey.split('').first, help: 'Path to the LCOV file containing code coverage data in LCOV format')
        ..addOption(_jsonCoverageKey, abbr: _jsonCoverageKey.split('').first, help: 'Path to the JSON coverage file containing code coverage data in JSON format')
        ..addOption(_output, abbr: _output.split('').first, help: 'Path to the output directory where the processed coverage reports will be saved')
        ..addOption(_projectPathKey, abbr: _projectPathKey.split('').first, help: 'Path to the project root directory containing the source code for coverage analysis')
        ..addOption(_gitParserFileKey, abbr: _gitParserFileKey.split('').first, help: 'Path to the git parser file containing git change analysis results');
    } catch (e) {
      Logger.error(e);
      exit(-1);
    }
  }

  @override
  String get description => 'LCOV CLI Command Line Tool - Processes and analyzes code coverage data from LCOV and JSON formats';

  @override
  String get name => 'lcov';

  @override
  FutureOr<int>? run() async {
    try {
      final config = Config.fromArgs(argResults);
      final lcovFile = config.lcovFile;
      final jsonFile = config.jsonCoverage;
      final outputDir = config.output;
      final projectPath = config.projectPath;
      final gitParserFile = config.gitParserFile;
      final result = await Process.instance.start(
        'dart',
        [
          '${Utils.root}/lcov_cli/bin/lcov_cli.dart',
          if (lcovFile != null) ...[
            '--lcov',
            lcovFile,
          ],
          if (jsonFile != null) ...[
            '--json',
            jsonFile,
          ],
          if (outputDir != null) ...[
            '--output',
            outputDir,
          ],
          if (projectPath != null) ...[
            '--projectPath',
            projectPath,
          ],
          if (gitParserFile != null) ...[
            '--gitParserFile',
            gitParserFile,
          ],
        ],
        runInShell: true,
      );
      result.stdout.transform(utf8.decoder).listen(stdout.write);
      result.stderr.transform(utf8.decoder).listen(stderr.write);
      return await result.exitCode;
    } catch (e) {
      Logger.error(e);
      exit(-1);
    }
  }
}

class MainRunnerCommand extends Command<int> {
  MainRunnerCommand(this.main) {
    addArgParser();
  }

  void addArgParser() {
    try {
      argParser
        ..addOption(_targetBranchFallbackKey,
            abbr: _targetBranchFallbackKey.split('').first, defaultsTo: 'main', help: 'Fallback branch if target branch is not found. Used as a backup when the primary target branch does not exist.')
        ..addOption(_targetBranchKey, abbr: _targetBranchKey.split('').first, defaultsTo: 'master', help: 'Target branch for comparison. The base branch against which changes will be analyzed.')
        ..addOption(_sourceBranchKey, abbr: _sourceBranchKey.split('').first, defaultsTo: 'HEAD', help: 'Source branch for comparison. Contains the changes to be analyzed against the target branch.')
        ..addOption(_lcovFileKey, abbr: _lcovFileKey.split('').first, help: 'Path to the LCOV file containing detailed code coverage information in LCOV format')
        ..addOption(_jsonCoverageKey, abbr: _jsonCoverageKey.split('').first, help: 'Path to the JSON coverage file containing code coverage data in JSON format')
        ..addOption(_output, abbr: _output.split('').first, help: 'Path to the output directory where all analysis results and reports will be saved')
        ..addOption(_projectPathKey, abbr: _projectPathKey.split('').first, help: 'Path to the project root directory containing the source code for analysis')
        ..addOption(_gitParserFileKey, abbr: _gitParserFileKey.split('').first, help: 'Path to the git parser file containing the results of git change analysis')
        ..addOption(_outputDir, help: 'Path to the output directory where the analysis results will be saved.')
        ..addOption(_configFile, abbr: _configFile.split('').first, help: 'Path to the config file containing configuration options for the analysis tool');
    } catch (e) {
      Logger.error(e);
      exit(-1);
    }
  }

  final CommandRunner<int> main;

  @override
  String get description => 'Combined Git and LCOV analysis tool - Executes both git change analysis and code coverage processing in sequence';

  @override
  String get name => 'report';

  @override
  FutureOr<int>? run() async {
    try {
      final config = Config.fromArgs(argResults);

      final gitOptions = [
        if (config.targetBranch != null) ...[
          '--target-branch',
          config.targetBranch!,
        ],
        if (config.targetBranchFallback != null) ...[
          '--fallback',
          config.targetBranchFallback!,
        ],
        if (config.sourceBranch != null) ...[
          '--source-branch',
          config.sourceBranch!,
        ],
        if (config.output != null) ...[
          '--output-dir',
          config.output!,
        ],
        if (config.projectPath != null) ...[
          '--project-dir',
          config.projectPath!,
        ]
      ];

      final lcovOptions = [
        if (config.lcovFile != null) ...[
          '--lcov',
          config.lcovFile!,
        ],
        if (config.jsonCoverage != null) ...[
          '--json',
          config.jsonCoverage!,
        ],
        if (config.output != null) ...[
          '--output',
          config.output!,
        ],
        if (config.projectPath != null) ...[
          '--projectPath',
          config.projectPath!,
        ],
        if (config.gitParserFile != null) ...[
          '--gitParserFile',
          config.gitParserFile!,
        ],
      ];

      await main.run(['git', ...gitOptions]);
      await main.run(['lcov', ...lcovOptions]);
      Logger.success('Analysis completed successfully.');
      return 0;
    } catch (e) {
      Logger.error(e);
      exit(-1);
    }
  }
}
