import 'dart:io';

import 'package:html_gen/html_gen.dart';
import 'package:lcov_cli/generators/html_file_helper.dart';
import 'package:lcov_cli/generators/tags.dart';
import 'package:lcov_cli/models/code_file.dart';

class HtmlFilesGen {
  Future<List<File>> generateHtmlFiles(List<CodeFile> codeFiles, String outputDir, [String? rootPath]) async {
    final htmlFiles = <File>[];

    final outputDirectory = Directory('${outputDir}lcov_html');
    final cssFilePath = await HtmlFileHelper.generateCssFile(outputDirectory.absolute.path);

    // Store file stats for later use in generating directory index pages
    final Map<String, FileStats> fileStatsMap = {};

    for (final file in codeFiles) {
      // Determine the output directory relative to the rootPath
      final relativeFilePath = rootPath != null ? file.path.replaceFirst(rootPath, '') : file.path;
      final relativeDir = relativeFilePath.split('/').sublist(0, relativeFilePath.split('/').length - 1).join('/');

      // Create the directory structure
      final dir = Directory('$outputDir$relativeDir');
      await dir.create(recursive: true);

      // Generate HTML content for the file
      final htmlContent = generateHtmlContent(file, cssFilePath);

      // Determine output file path and create the HTML file
      final outputFilePath = '${dir.path}/${file.path.split('/').last}.html';
      final outputFile = File(outputFilePath);
      await outputFile.writeAsString(htmlContent);

      // Store file stats for later directory index generation
      fileStatsMap[outputFile.path] = FileStats(
        totalCoveredLines: file.totalCoveredLines,
        totalLines: file.totalHittableLines,
        dirName: relativeDir,
      );

      htmlFiles.add(outputFile);
      print('Generated: ${outputFile.path}');
    }

    // Recursively generate index pages for each directory
    await _generateIndexPages(outputDirectory, fileStatsMap, cssFilePath);

    return htmlFiles;
  }

  // Generate index.html for all directories recursively
  Future<void> _generateIndexPages(Directory directory, Map<String, FileStats> fileStatsMap, String cssFilePath) async {
    final subDirs = directory.listSync().whereType<Directory>();
    final files = directory.listSync().whereType<File>().where((f) => f.path.endsWith('.html'));

    // Sum the file stats for the current directory's index page
    int totalCoveredLines = 0;
    int totalLines = 0;

    // TODO: Optimize this function and make proper calculation
    for (final dir in subDirs) {
      final filesInDir = fileStatsMap.keys.where((path) => path.contains(dir.path)).toList();
      for (final filePath in filesInDir) {
        final stats = fileStatsMap[filePath];
        if (stats != null) {
          totalCoveredLines += stats.totalCoveredLines;
          totalLines += stats.totalLines;
        }
      }
    }

    // for (final subDir in subDirs) {

    // }

    final indexContent = generateDirectoryIndexContent(
      subDirs,
      files,
      FileStats(
        totalCoveredLines: totalCoveredLines,
        totalLines: totalLines,
        dirName: directory.path.split('/').last,
      ),
      cssFilePath,
    );
    final indexFile = File('${directory.path}/index.html');
    await indexFile.writeAsString(indexContent);
    print('Generated index: ${indexFile.path}');

    for (final subDir in subDirs) {
      await _generateIndexPages(subDir, fileStatsMap, cssFilePath); // Recursive call for subdirectories
    }
  }

  // Generate HTML content for the index.html of a directory
  String generateDirectoryIndexContent(
    Iterable<Directory> subDirs,
    Iterable<File> files,
    FileStats stats,
    String cssFilePath,
  ) {
    final linkTags = <String>[];

    // Add links to subdirectories
    for (final dir in subDirs) {
      final dirName = dir.path.split('/').last;
      linkTags.add(buildListItemLink('$dirName/index.html', title: dirName));
    }

    // Add links to files in this directory
    for (final file in files) {
      final fileName = file.path.split('/').last;
      if (!fileName.endsWith('index.html')) {
        linkTags.add(buildListItemLink(fileName, title: fileName.replaceAll('.html', '')));
      }
    }

    // Generate directory index page content with stats
    return HtmlFileHelper.getFolderIndexHeaer(
      cssFilePath: cssFilePath,
      stats: stats,
      body: [
        UlTag(
          children: linkTags.map((link) => LiTag(content: link)).toList(),
        ),
      ],
    ).build();
  }

  // Generates HTML content for an individual code file
  String generateHtmlContent(CodeFile file, String cssFilePath) {
    return HtmlFileHelper.getFileHeader(cssFilePath: cssFilePath, body: [
      PreTag(
        children: [
          for (final line in file.codeLines) SpanTag(content: line.lineContent, attributes: {'style': 'text-align:left;'}),
        ],
      ),
    ]).build();
  }

  String buildListItemLink(String path, {String? title}) {
    return ATag(
      href: path,
      content: title,
    ).build();
  }
}
