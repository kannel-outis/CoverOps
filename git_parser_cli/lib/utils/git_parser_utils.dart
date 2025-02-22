import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:git_parser_cli/models/git_file.dart';
import 'package:git_parser_cli/models/git_settings.dart';
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

  static Map<String, Map<String, int>> generateDiffMap(List<GitFile> gitfiles) {
    final Map<String, Map<String, int>> hitMap = {};
    for (var file in gitfiles) {
      hitMap[file.path] = {};
      for (var content in file.content) {
        if(hitMap[file.path]![content.lineNumber] != null) {
          hitMap[file.path]![content.lineNumber] = hitMap[file.path]![content.lineNumber]! + (content.isLineAdded ? 1 : 0);
        } else {
        hitMap[file.path]![content.lineNumber] = content.isLineAdded ? 1 : 0;
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
}
