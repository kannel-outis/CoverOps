import 'dart:async';
import 'dart:io';

import 'package:lcov_cli/models/code_file.dart';

abstract class ReportGenerator {
  final List<CodeFile> codeFiles;
  final String? outputDir;

  ReportGenerator({required this.codeFiles, required this.outputDir});
  FutureOr<List<File>?> generate([String? rootPath]);

  Future<void> createOutPutDir(Directory outputDirectory) async {
    if (await outputDirectory.exists()) return;
    await outputDirectory.create(recursive: true);
  }
}
