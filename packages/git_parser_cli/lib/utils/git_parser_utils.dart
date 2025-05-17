import 'dart:async';
import 'dart:convert';
import 'dart:io' hide Process;

import 'package:args/args.dart';
import 'package:git_parser_cli/models/git_file.dart';
import 'package:git_parser_cli/models/git_settings.dart';
import 'package:git_parser_cli/process.dart';
import 'package:git_parser_cli/utils/utils.dart';

class GitParserUtils {
  static const targetBranchKey = 'target-branch';
  static const targetBranchFallbackKey = 'fallback';
  static const sourceBranchKey = 'source-branch';
  static const projectPathKey = 'project-dir';
  static const outputDir = 'output-dir';

  static GitSettings getGitSettings(ArgResults args) {
    return GitSettings(
      targetBranch: args[targetBranchKey] ?? 'master',
      targetBranchFallback: args[targetBranchFallbackKey] ?? 'main',
      sourceBranch: args[sourceBranchKey] ?? 'HEAD',
      projectPath: args[projectPathKey],
      outputDir: args[outputDir],
    );
  }

  static Map<String, Map<String, int>> generateDiffMap(List<GitFile> gitfiles, String gitPath) {
    final Map<String, Map<String, int>> hitMap = {};
    final cleanGitPath = gitPath.isEmpty ? '' : '$gitPath/';
    for (var file in gitfiles) {
      final path = '$cleanGitPath${file.path}';
      hitMap[path] = {};
      for (var content in file.content) {
        if(hitMap[path]![content.lineNumber] != null) {
          hitMap[path]![content.lineNumber] = hitMap[path]![content.lineNumber]! + (content.isLineAdded ? 1 : 0);
        } else {
        hitMap[path]![content.lineNumber] = content.isLineAdded ? 1 : 0;
        }
      }
    }
    return hitMap;
  }

  static Future<void> writeDiffMapToJson(Map<String, Map<String, int>> hitMap, String filePath) async {
    try {
      String jsonString = json.encode(hitMap);
      File file = File(filePath);
      if (await file.exists()) {
        await file.delete(); // Deletes the file if it exists
      }
      await file.writeAsString(jsonString);

      print("Output:$filePath");
    } catch (e) {
      exitWithMessage(e.toString());
    }
  }

  static Future<String> getCurrentGitDir() async {
    final process = await Process.instance.run(
      'git',
      ['rev-parse', '--show-toplevel'],
      runInShell: true,
    );
    if(process.exitCode != 0) {
      return '';
    }
    return process.stdout.toString().trim();
  }
}
