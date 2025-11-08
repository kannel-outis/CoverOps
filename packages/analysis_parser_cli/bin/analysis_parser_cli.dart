import 'package:analysis_parser_cli/analysis_parser_cli.dart' as analysis_parser_cli;

Future<void> main(List<String> arguments) async {
  await analysis_parser_cli.AnalysisParserCli().run(arguments);
}
