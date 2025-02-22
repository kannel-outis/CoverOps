import 'dart:io';

import 'package:html_gen/html_gen.dart';
import 'package:lcov_cli/generators/html_file_helper.dart';
import 'package:lcov_cli/generators/tags.dart';
import 'package:lcov_cli/models/code_file.dart';
import 'package:lcov_cli/models/line.dart';
import 'package:lcov_cli/utils/utils.dart';

class HtmlFilesGen {
  final outputRootFolder = 'lcov_html/'; //TODO(kannel-outis): look into this

  Future<List<File>> generateHtmlFiles(List<CodeFile> codeFiles, String outputDir, [String? rootPath]) async {
    final htmlFiles = <File>[];
    final outputDirectory = Directory('${outputDir}lcov_html');
    final cssFilePath = await HtmlFileHelper.generateCssFile(outputDirectory.absolute.path);
    final stats = _processFiles(codeFiles, rootPath, outputDirectory, cssFilePath, htmlFiles);
    await _generateIndexPages(
      outputDirectory,
      stats.fileStats,
      stats.dirStats,
      stats.modifiedCodeFiles,
      cssFilePath,
    );
    return htmlFiles;
  }

  _FileProcessingStats _processFiles(
    List<CodeFile> codeFiles,
    String? rootPath,
    Directory outputDirectory,
    String cssFilePath,
    List<File> htmlFiles,
  ) {
    final Map<String, FileStats> fileStatsMap = {};
    final Map<String, FileStats> dirStatsMap = {};
    final List<_ModifiedCodeFile> modifiedCodeFiles = [];

    for (final file in codeFiles) {
      final paths = _getFilePaths(file, rootPath, outputDirectory);
      if (file.isModified) modifiedCodeFiles.add(_ModifiedCodeFile(paths: paths, file: file));
      _createDirectoryAndFile(paths, file, cssFilePath, htmlFiles, fileStatsMap, dirStatsMap);
    }

    return _FileProcessingStats(fileStatsMap, dirStatsMap, modifiedCodeFiles);
  }

  _FilePaths _getFilePaths(CodeFile file, String? rootPath, Directory outputDirectory) {
    final relativeFilePath = rootPath != null ? file.path.replaceFirst(rootPath, '') : file.path;
    final pathParts = relativeFilePath.split('/');
    final relativeDir = pathParts.sublist(0, pathParts.length - 1).join('/');
    final dir = Directory('${outputDirectory.path}/$relativeDir');
    final outputFilePath = '${dir.path}/${file.path.split('/').last}.html';

    return _FilePaths(relativeFilePath, relativeDir, dir, outputFilePath);
  }

  void _createDirectoryAndFile(
    _FilePaths paths,
    CodeFile file,
    String cssFilePath,
    List<File> htmlFiles,
    Map<String, FileStats> fileStatsMap,
    Map<String, FileStats> dirStatsMap,
  ) async {
    await paths.dir.create(recursive: true);

    final fileStats = FileStats(
      totalCoveredLines: file.totalCoveredLines,
      totalLines: file.totalHittableLines,
      totalModifiedLines: file.totalHittableModifiedLines,
      totalCoveredLinesOnModified: file.totalHitOnModifiedLines,
      dirName: paths.relativeDir,
    );

    final htmlContent = generateHtmlContent(file, cssFilePath, fileStats);
    final outputFile = File(paths.outputFilePath)..createSync(recursive: true);
    await outputFile.writeAsString(htmlContent);
    htmlFiles.add(outputFile);

    fileStatsMap[outputFile.path] = fileStats;
    _updateDirStats(paths.relativeDir, fileStats, dirStatsMap);
  }

  void _updateDirStats(String relativeDir, FileStats fileStats, Map<String, FileStats> dirStatsMap) {
    String currentDir = relativeDir;
    while (currentDir.isNotEmpty) {
      dirStatsMap.update(
        currentDir,
        (existing) => FileStats(
          totalCoveredLines: existing.totalCoveredLines + fileStats.totalCoveredLines,
          totalLines: existing.totalLines + fileStats.totalLines,
          totalModifiedLines: existing.totalModifiedLines + fileStats.totalModifiedLines,
          totalCoveredLinesOnModified: existing.totalCoveredLinesOnModified + fileStats.totalCoveredLinesOnModified,
          dirName: currentDir,
        ),
        ifAbsent: () => fileStats,
      );
      currentDir = _parentDir(currentDir);
    }
  }

  Future<void> _generateIndexPages(
    Directory directory,
    Map<String, FileStats> fileStatsMap,
    Map<String, FileStats> dirStatsMap,
    List<_ModifiedCodeFile> modifiedCodeFiles,
    String cssFilePath,
  ) async {
    final subDirs = directory.listSync().whereType<Directory>().toList();
    final files = directory.listSync().whereType<File>().where((f) => f.path.endsWith('.html')).toList();
    List<_ModifiedCodeFile> modifiedFiles = modifiedCodeFiles;
    final dirPath = directory.path.split(outputRootFolder).last;
    final dirStats = dirStatsMap[dirPath] ??
        FileStats(
          totalCoveredLines: 0,
          totalLines: 0,
          dirName: dirPath,
          totalCoveredLinesOnModified: 0,
          totalModifiedLines: 0,
        );
    if (directory.path.split(outputRootFolder).length > 1) {
      //means we are in a sub directory
      modifiedFiles = [];
    }

    final indexContent = generateDirectoryIndexContent(subDirs, files, dirStats, cssFilePath, modifiedFiles);
    final indexFile = File('${directory.path}/index.html');
    indexFile.createSync(recursive: true);
    await indexFile.writeAsString(indexContent);

    for (final subDir in subDirs) {
      await _generateIndexPages(subDir, fileStatsMap, dirStatsMap, [], cssFilePath);
    }
  }

  String generateDirectoryIndexContent(
    Iterable<Directory> subDirs,
    Iterable<File> files,
    FileStats stats,
    String cssFilePath,
    // ignore: library_private_types_in_public_api
    List<_ModifiedCodeFile> changedFiles,
  ) {
    final linkTags = _generateLinkTags([...subDirs, ...files]);
    final changedFilesLinks = changedFiles
        .map(
          (file) => buildListItemLink(
            file.paths.outputFilePath.split(outputRootFolder).last,
            title: file.paths.outputFilePath.split('/').last,
          ),
        )
        .toList();
    final totalModifiedLines = changedFiles.fold<int>(0, (prev, file) => prev + file.file.totalHittableModifiedLines);
    final totalHitOnModifiedLines = changedFiles.fold<int>(0, (prev, file) => prev + file.file.totalHitOnModifiedLines);
    final totalCoverageOnModifiedLines = (totalHitOnModifiedLines / totalModifiedLines) * 100;

    final changedFilesHeader = HtmlFileHelper.getFileStatsBody(
      showCoverageOnModified: false,
      totalCoveredLines: totalHitOnModifiedLines,
      totalLines: totalModifiedLines,
      coveragePercentage: '${totalCoverageOnModifiedLines.toStringAsFixed(1)}%',
    );

    return HtmlFileHelper.getFolderIndexHeaer(
      cssFilePath: cssFilePath,
      stats: stats,
      body: [
        _buildFolderListSection(linkTags),
        if (changedFilesLinks.isNotEmpty) ...[
          H3Tag(content: 'Modified Files (${changedFilesLinks.length})'),
          _buildFolderListSection(changedFilesLinks, header: changedFilesHeader),
        ],
      ],
    ).build();
  }

  List<ATag> _generateLinkTags(Iterable<FileSystemEntity> items) {
    return items
        .map((item) {
          final name = item.path.split('/').last;
          if (item is Directory) {
            return buildListItemLink('$name/index.html', title: name);
          } else if (!name.endsWith('index.html')) {
            return buildListItemLink(name, title: name.replaceAll('.html', ''));
          }
          return null;
        })
        .whereType<ATag>()
        .toList();
  }

  SectionTag _buildFolderListSection(List<ATag> linkTags, {Tag? header}) {
    return SectionTag(
      attributes: {'class': 'folder-list'},
      children: [
        header ?? H3Tag(content: 'Files and Folders'),
        DivTag(
          attributes: {'class': 'grid'},
          children: linkTags.map(_buildCardDiv).toList(),
        ),
      ],
    );
  }

  DivTag _buildCardDiv(ATag link) {
    final isFolder = link.href.endsWith('index.html');
    return DivTag(
      attributes: {'class': 'card'},
      children: [
        SpanTag(
          content: isFolder ? '📁' : '📄',
          attributes: {'class': isFolder ? 'folder-icon' : 'file-icon'},
        ),
        link,
      ],
    );
  }

  String generateHtmlContent(CodeFile file, String cssFilePath, FileStats stats) {
    return HtmlFileHelper.getFolderIndexHeaer(
      stats: stats,
      cssFilePath: cssFilePath,
      body: [_buildCodeBlock(file)],
    ).build();
  }

  PreTag _buildCodeBlock(CodeFile file) {
    return PreTag(
      children: [
        CodeTag(
          children: file.codeLines.map((line) => SpanTag(content: wrapLineNumber(line))).toList(),
        ),
      ],
    );
  }

  ATag buildListItemLink(String path, {String? title}) {
    return ATag(href: path, content: title);
  }

  String wrapKeywords(String line) {
    return line.split(' ').map((word) {
      if (defaultLanguageKeywords.contains(word)) {
        return SpanTag(content: word, attributes: {'class': 'keyword'}).build();
      }
      return word;
    }).join(' ');
  }

  String wrapLineNumber(Line line) {
    final lineNumber = SpanTag(
      content: '${line.lineNumber.toString()}\t: ',
      attributes: {'class': line.isModified && line.canHitLine ? 'modified' : 'unmodified'},
    ).build();

    final lineContent = SpanTag(
      content: wrapKeywords(line.lineContent),
      attributes: {'class': _getLineClass(line)},
    ).build();

    return '$lineNumber$lineContent';
  }

  String _getLineClass(Line line) {
    if (!line.canHitLine) return 'code-line line-ignored';
    return line.isLineHit ? 'code-line line-covered' : 'code-line line-missed';
  }

  String _parentDir(String dirPath) {
    final parts = dirPath.split('/');
    return parts.length <= 1 ? '' : parts.sublist(0, parts.length - 1).join('/');
  }
}

class _FileProcessingStats {
  final Map<String, FileStats> fileStats;
  final Map<String, FileStats> dirStats;
  final List<_ModifiedCodeFile> modifiedCodeFiles;

  _FileProcessingStats(this.fileStats, this.dirStats, this.modifiedCodeFiles);
}

class _FilePaths {
  final String relativeFilePath;
  final String relativeDir;
  final Directory dir;
  final String outputFilePath;

  _FilePaths(this.relativeFilePath, this.relativeDir, this.dir, this.outputFilePath);
}

class _ModifiedCodeFile {
  final _FilePaths paths;
  final CodeFile file;

  _ModifiedCodeFile({required this.paths, required this.file});
}
