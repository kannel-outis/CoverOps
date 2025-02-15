class GitSettings {
  final String targetBranch;
  final String targetBranchFallback;
  final String sourceBranch;
  final String? projectPath;
  final String? outputDir;

  GitSettings({
    required this.targetBranch,
    required this.targetBranchFallback,
    required this.sourceBranch,
    this.projectPath,
    this.outputDir
  });
}
