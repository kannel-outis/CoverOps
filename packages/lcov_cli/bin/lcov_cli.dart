import 'package:lcov_cli/lcov_cli.dart' as lcov_cli;

Future<void> main(List<String> arguments) async {
   await lcov_cli.LcovCli().run(arguments);
}
