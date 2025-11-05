import 'package:analysis_parser_cli/parser/analysis_line_parser.dart';

class AnalyzerConfig {
  final String command;
  final AnalysisLineParser parser;
  final List<String> arguments;
  final String workingDirectory;
  AnalyzerConfig({
    required this.command,
    required this.parser,
    this.arguments = const [],
    this.workingDirectory = '.',
  });

  factory AnalyzerConfig.dart({String workingDirectory = '.'}) {
    return AnalyzerConfig(
      command: 'dart analyze "$workingDirectory"',
      parser: DartAnalysisLineParser(),
      workingDirectory: workingDirectory,
    );
  }
}
