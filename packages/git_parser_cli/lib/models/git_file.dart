/// Represents a file in a Git repository with its path and content.
///
/// [path] is the file path in the repository.
/// [content] is the list of lines in the file.
class GitFile {
  final String path;
  final List<GitLine> content;

  GitFile({required this.path, required this.content});
}

/// Represents a single line in a Git diff output.
///
/// [lineContent] is the raw content of the line including any Git diff markers.
class GitLine {
  final String lineContent;
  final String lineNumber;

  GitLine({
    required this.lineContent,
    this.lineNumber = '',
  });

  bool get isLineAdded => lineContent.startsWith('+');
  bool get isLineRemoved => lineContent.startsWith('-');
  bool get isLineChanged => isLineAdded || isLineRemoved;
}
