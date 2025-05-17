import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:cover_ops/commands/comands.dart';
import 'package:cover_ops/utils/logger.dart';

class CoverOpsRunner extends CommandRunner<int> {
  CoverOpsRunner()
      : super(
          'cover',
          'Coverage Operations CLI tool for analyzing and processing code coverage data. Supports Git operations, LCOV file handling, and coverage report generation.',
        ) {
    addCommand(GitCliCommand());
    addCommand(LcovCliCommand());
    addCommand(MainRunnerCommand(this));
  }

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final ArgResults argResults = parse(args);
      final int exitCode = await runCommand(argResults) ?? -1;
      return exitCode;
    } catch (e) {
      Logger.error(e);
      return 1;
    }
  }
}
