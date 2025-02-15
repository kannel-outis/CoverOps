import 'package:git_parser_cli/git_parser_cli.dart' as git_parser_cli;

Future<void> main(List<String> arguments) async {
 await git_parser_cli.GitParserCli().run(arguments);
}
