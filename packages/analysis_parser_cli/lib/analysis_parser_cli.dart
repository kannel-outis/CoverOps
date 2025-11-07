import 'package:analysis_parser_cli/parser/analysis_parser.dart';
import 'package:analysis_parser_cli/parser/config.dart';
import 'package:analysis_parser_cli/parser/parser.dart';
import 'package:analysis_parser_cli/utils/helper.dart';
import 'package:args/args.dart';
import 'package:file/local.dart';

class AnalysisParserCli {
  final projectPath = LocalFileSystem().currentDirectory.path;
  final argsParser = ArgParser();
  final projectDir = AnalysisCLIHelpers.projectPathKey;
  final outputDir = AnalysisCLIHelpers.outputDirKey;
  final language = AnalysisCLIHelpers.languageKey;
  final configFile = AnalysisCLIHelpers.configFileKey;

  Future<String?> run(List<String> arguments) async {
    argsParser
      ..addOption(outputDir, abbr: outputDir.split('').first, defaultsTo: projectPath)
      ..addOption(projectDir, abbr: projectDir.split('').first, defaultsTo: projectPath)
      ..addOption(language, abbr: language.split('').first.toUpperCase(), defaultsTo: 'dart')
      ..addOption(configFile, abbr: configFile.split('').first);

    final args = argsParser.parse(arguments);
    final workingDirectory = args[projectDir]!;
    final outputDirectory = args[outputDir]!;
    //TODO: get config from lang arg
    final AnalyzerConfig config = AnalyzerConfig.dart(workingDirectory: workingDirectory);
    final Parser parser = AnalysisParser(config: config);

    final files = await parser.parse();
    final results = AnalysisCLIHelpers.generateAnalysisMap(files);
    final result = await AnalysisCLIHelpers.writeAnalysisMapToJson(results, '$outputDirectory/.analysis.json');
    print(result);
    print(files.length);
    print(parser.totalAnalysisFound);
    return result;
  }
}
