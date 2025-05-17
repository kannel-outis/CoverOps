import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:html_gen/html_gen.dart';
import 'package:lcov_cli/generators/tags.dart';

class HtmlFileHelper {
  HtmlFileHelper._();

  static Future<String> generateCssFile(String outputDir) async {
    final cssFilePath = '${DartScript.self.pathToScriptDirectory.split('lcov_cli').first}lcov_cli/lib/generators/templates/__template__.css';
    final cssFile = File('$outputDir/style.css');
    await cssFile.create(recursive: true);
    await cssFile.writeAsString(await File(cssFilePath).readAsString());
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

  static String getCoveragePercentage({required int totalCoveredLines, required int totalLines}) {
    if (totalCoveredLines == 0 && totalLines > 0) return '0.0%';
    if(totalCoveredLines == 0 && totalLines == 0) return '100.0%';
    if (totalLines == 0) return '100.0%';
    return '${((totalCoveredLines / totalLines) * 100).toStringAsFixed(1)}%';
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

  String get coveragePercentageString {
    return HtmlFileHelper.getCoveragePercentage(
      totalCoveredLines: totalCoveredLines,
      totalLines: totalLines,
    );
  }

  String get coverageOnModifiedPercentageString {
    return HtmlFileHelper.getCoveragePercentage(
      totalCoveredLines: totalCoveredLinesOnModified,
      totalLines: totalModifiedLines,
    );
  }
}
