import 'package:args/args.dart';
import 'package:file/local.dart';
import 'package:git_parser_cli/parser/git_diff_parser.dart';
import 'package:git_parser_cli/utils/git_parser_utils.dart';

class GitParserCli {
  Future<void> run(List<String> arguments) async {
    final projectPath = LocalFileSystem().currentDirectory.path;
    final parser = ArgParser();

    final targetBranchKey = GitParserUtils.targetBranchKey;
    final targetBranchFallbackKey = GitParserUtils.targetBranchFallbackKey;
    final sourceBranchKey = GitParserUtils.sourceBranchKey;
    final projectDir = GitParserUtils.projectPathKey;
    final outputDir = GitParserUtils.outputDir;

    parser
      ..addOption(targetBranchFallbackKey, abbr: targetBranchFallbackKey.split('').first, defaultsTo: 'main')
      ..addOption(targetBranchKey, abbr: targetBranchKey.split('').first, defaultsTo: 'master')
      ..addOption(sourceBranchKey, abbr: sourceBranchKey.split('').first, defaultsTo: 'HEAD')
      ..addOption(outputDir, abbr: outputDir.split('').first, defaultsTo: projectPath)
      ..addOption(projectDir, abbr: projectDir.split('').first, defaultsTo: projectPath);

    final args = parser.parse(arguments);
    final settings = GitParserUtils.getGitSettings(args);
    final gitParser = GitDiffParser(
      targetBranch: settings.targetBranch,
      sourceBranch: settings.sourceBranch,
      fallbackBranch: settings.targetBranchFallback,
      projectDir: settings.projectPath ?? projectPath,
    );

    final gitfiles = await gitParser.parse();
    final hitMap = GitParserUtils.generateDiffMap(gitfiles);
    await GitParserUtils.writeDiffMapToJson(hitMap, '${settings.outputDir}/.gitparser.json');
  }
}
