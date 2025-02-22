import 'dart:io';

import 'package:html_gen/html_gen.dart';
import 'package:lcov_cli/generators/tags.dart';

class HtmlFileHelper {
  HtmlFileHelper._();

  static Future<String> generateCssFile(String outputDir) async {
    final cssFile = File('$outputDir/style.css');
    await cssFile.create(recursive: true);
    await cssFile.writeAsString('''
    /* Global Styles */
    body {
      font-family: Arial, sans-serif;
      background-color: #f5f7fa;
      color: #333;
      margin: 0;
      padding: 20px;
    }
    h1, h2, h3 {
      font-weight: 500;
      margin: 10px 0;
    }

    /* Container for the report */
    .container {
      max-width: 1200px;
      margin: 0 auto;
      background-color: white;
      border-radius: 8px;
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
      padding: 20px;
    }

    /* Stats block */
    .stats {
      display: flex;
      justify-content: space-between;
      padding: 10px 0;
      border-bottom: 2px solid #eee;
    }

    .stats .stat-item {
      background-color: #f8f9fa;
      padding: 10px;
      border-radius: 5px;
      text-align: center;
    }

    .stats .stat-item strong {
      display: block;
      font-size: 1.5rem;
      color: #28a745;
    }

    /* Beautiful Folder and File Cards */
    .folder-list {
      margin-top: 20px;
    }

    .folder-list .grid {
      /* display: grid;
      grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); */
      gap: 15px;
    }

    .folder-list .card {
      background-color: #f1f3f5;
      border: 1px solid #dee2e6;
      border-radius: 8px;
      padding: 15px;
      text-align: center;
      transition: background-color 0.3s, transform 0.2s;
      cursor: pointer;
      display: flex;
      flex-direction: row;
      align-items: center;
    }

    .folder-list .card:hover {
      background-color: #e2e6ea;
      transform: translateY(-5px);
    }

    .folder-list .card a {
      text-decoration: none;
      color: #007bff;
      font-weight: bold;
      margin-top: 10px;
      display: block;
    }

    .folder-list .card a:hover {
      text-decoration: underline;
    }

    /* Folder and File Icons */
    .folder-icon, .file-icon {
      font-size: 2rem;
      color: #007bff;
    }

    .folder-icon {
      color: #ffc107;
    }

    /* Code block */
    pre {
      background-color: #282c34;
      /*color: #abb2bf;*/
      color: #eee;
      padding: 15px;
      border-radius: 5px;
      overflow: auto;
    }

    .code-line {
      /*display: block;*/
      white-space: pre;
    }

    .line-covered {
      background-color: rgba(40, 167, 69, 0.2);
    }

    .line-missed {
      background-color: rgba(220, 53, 69, 0.2);
    }

    /* Footer */
    .footer {
      margin-top: 40px;
      text-align: center;
      font-size: 0.9rem;
      color: #777;
    }

    .footer a {
      color: #007bff;
      text-decoration: none;
    }

    .footer a:hover {
      text-decoration: underline;
    }

  .keyword {
    color: #d73a49;
    font-weight: bold;
  }

  .modified {
    background-color: rgba(133, 193, 233, 0.3);
  }
''');
    return cssFile.path;
  }

  static Tag getFileHeader({required List<Tag> body, String? cssFilePath}) {
    return HtmlTag(
      children: [
        HeadTag(
          children: [
            MetaTag(attributes: {'charset': 'UTF-8'}),
            MetaTag(attributes: {'name': 'viewport', 'content': 'width=device-width, initial-scale=1'}),
            StyleLinkTag(css: cssFilePath ?? ''),
          ],
        ),
        BodyTag(
          attributes: {'class': 'container'},
          children: body,
        ),
      ],
    );
  }

  static Tag getFolderIndexHeaer({required List<Tag> body, required FileStats stats, String? cssFilePath}) {
    return getFileHeader(
      cssFilePath: cssFilePath,
      body: [
        HeaderTag(
          children: [
            H1Tag(content: 'Code Coverage Report'),
            H2SubContentTag(
              titleContent: 'Folder',
              subContent: SpanTag(content: stats.dirName.split('/').join('>')),
            ),
          ],
        ),
        getFileStatsBody(
          totalCoveredLines: stats.totalCoveredLines,
          totalLines: stats.totalLines,
          coveragePercentage: stats.coveragePercentageString,
          coverageOnModified: stats.coverageOnModifiedPercentageString,
        ),
        ...body,
      ],
    );
  }

  static Tag getFileStatsBody({
    int totalCoveredLines = 0,
    int totalLines = 0,
    String coveragePercentage = '0.0%',
    String coverageOnModified = '0.0%',
    bool showCoverageOnModified = true,
  }) {
    return DivTag(
      attributes: {'class': 'stats'},
      children: [
        DivTag(
          attributes: {'class': 'stat-item'},
          children: [
            StrongTag(attributes: {"id": 'total-covered-lines'}, content: '$totalCoveredLines'),
            SpanTag(content: 'Covered Lines'),
          ],
        ),
        DivTag(
          attributes: {'class': 'stat-item'},
          children: [
            StrongTag(attributes: {'id': 'total-lines'}, content: '$totalLines'),
            SpanTag(content: 'Total Lines'),
          ],
        ),
        if (showCoverageOnModified)
          DivTag(
            attributes: {'class': 'stat-item'},
            children: [
              StrongTag(attributes: {'id': 'coverage-percentage'}, content: coverageOnModified),
              SpanTag(content: 'Coverage On Modified'),
            ],
          ),
        DivTag(
          attributes: {'class': 'stat-item'},
          children: [
            StrongTag(attributes: {'id': 'coverage-percentage'}, content: coveragePercentage),
            SpanTag(content: 'Coverage'),
          ],
        ),
      ],
    );
  }
}

class FileStats {
  final int totalCoveredLines;
  final int totalLines;
  final int totalCoveredLinesOnModified;
  final int totalModifiedLines;
  final String dirName;

  FileStats({
    required this.totalCoveredLines,
    required this.totalLines,
    required this.totalCoveredLinesOnModified,
    required this.totalModifiedLines,
    required this.dirName,
  });

  double get coveragePercentage => (totalCoveredLines / totalLines) * 100;
  double get coverageOnModifiedPercentage => (totalCoveredLinesOnModified / totalModifiedLines) * 100;
  String get coveragePercentageString {
    if(totalCoveredLines == 0 ) return '_';
    return '${coveragePercentage.toStringAsFixed(1)}%';
  }

  String get coverageOnModifiedPercentageString {
    if(totalModifiedLines == 0 ) return '_';
    return '${coverageOnModifiedPercentage.toStringAsFixed(1)}%';
  }
}
