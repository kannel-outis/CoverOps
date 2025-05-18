import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cover_ops/commands/comands.dart';
import 'package:process/process.dart' as process;
import 'package:test/test.dart';

void main() {
  group('CLI Command Tests', () {
    late StreamController<List<int>> stdoutController;
    late StreamController<List<int>> stderrController;

    setUp(() {
      stdoutController = StreamController<List<int>>();
      stderrController = StreamController<List<int>>();
      process.Process.instance = MockProcess(
        stdoutStream: stdoutController.stream.asBroadcastStream(),
        stderrStream: stderrController.stream.asBroadcastStream(),
      );
    });

    tearDown(() async {
      await stdoutController.close();
      await stderrController.close();
    });

    test('GitCliCommand executes with correct arguments', () async {
      final runner = CommandRunner<int>('cover_ops', 'Test CLI');
      runner.addCommand(GitCliCommand());

      // Simulate CLI output
      stdoutController.add(utf8.encode('Git CLI executed\n'));

      final result = await runner.run([
        'git',
        '--target-branch',
        'main',
        '--fallback',
        'develop',
        '--source-branch',
        'feature',
        '--output-dir',
        'build/output',
        '--project-dir',
        'project/root',
      ]);

      expect(result, 0);
    });

    test('LcovCliCommand executes with correct arguments', () async {
      final runner = CommandRunner<int>('cover_ops', 'Test CLI');
      runner.addCommand(LcovCliCommand());

      // Simulate CLI output
      stdoutController.add(utf8.encode('LCOV CLI executed\n'));

      final result = await runner.run([
        'lcov',
        '--lcov',
        'coverage/lcov.info',
        '--json',
        'coverage/json_cov.json',
        '--output',
        'build/output',
        '--projectPath',
        'project/root',
        '--gitParserFile',
        'build/output/git.json',
        '--reportType',
        'console',
      ]);

      expect(result, 0);
    });

    test('MainRunnerCommand executes both Git and Lcov commands', () async {
      final runner = CommandRunner<int>('cover_ops', 'Test CLI');
      final mainCommand = MainRunnerCommand(runner);
      runner.addCommand(GitCliCommand());
      runner.addCommand(LcovCliCommand());
      runner.addCommand(mainCommand);

      // Simulate output from both commands
      stdoutController.add(utf8.encode('Git and LCOV executed\n'));

      final result = await runner.run([
        'report',
        '--target-branch',
        'main',
        '--fallback',
        'develop',
        '--source-branch',
        'feature',
        '--output',
        'build/output',
        '--projectPath',
        'project/root',
        '--lcov',
        'coverage/lcov.info',
        '--json',
        'coverage/json_cov.json',
        '--gitParserFile',
        'build/output/git.json',
        '--report-format',
        'html,json',
      ]);

      expect(result, 0);
    });
  });
}


class MockProcess implements process.Process {
  final Stream<List<int>> stdoutStream;
  final Stream<List<int>> stderrStream;
  final int exitCodeResult;

  MockProcess({
    required this.stdoutStream,
    required this.stderrStream,
    this.exitCodeResult = 0,
  });

  @override
  Future<Process> start(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    bool runInShell = false,
  }) async {
    return _FakeProcess(stdoutStream, stderrStream, exitCodeResult);
  }

  @override
  Future<ProcessResult> run(String executable, List<String> arguments,
      {bool runInShell = false}) {
    throw UnimplementedError();
  }
}

class _FakeProcess implements Process {
  final Stream<List<int>> _stdout;
  final Stream<List<int>> _stderr;
  final int _exitCode;

  _FakeProcess(this._stdout, this._stderr, this._exitCode);

  @override
  Stream<List<int>> get stdout => _stdout;

  @override
  Stream<List<int>> get stderr => _stderr;

  @override
  Future<int> get exitCode async => _exitCode;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
