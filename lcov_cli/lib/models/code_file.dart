import 'package:lcov_cli/models/line.dart';

class CodeFile {
  final String path;
  final List<Line> codeLines;

  const CodeFile({required this.path, required this.codeLines});

  int get totalCodeLines => codeLines.lastOrNull?.lineNumber ?? 0;
}