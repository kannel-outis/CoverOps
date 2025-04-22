import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:git_parser_cli/parser/git_diff_parser.dart';
import 'package:git_parser_cli/process.dart' as process;
import 'package:test/test.dart';

void main() {
  group('GitDiffParser', () {
    late GitDiffParser parser;

    setUp(() {
      const diffOutput = '''
diff --git a/lib/main.dart b/lib/main.dart
--- a/lib/main.dart
+++ b/lib/main.dart
@@ -1,3 +1,4 @@
+import 'dart:math';
 void main() {
   print('Hello, world!');
 }
''';
      final stdoutStream = Stream<List<int>>.fromIterable([
        utf8.encode(diffOutput),
      ]);
      final stderrStream = Stream<List<int>>.fromIterable([]);
      process.Process.instance = MockProcess(stdoutStream: stdoutStream, stderrStream: stderrStream);
      parser = GitDiffParser(
        projectDir: '.',
        sourceBranch: 'feature',
        targetBranch: 'main',
      );
    });

    test('parses diff output into GitFile objects', () async {
      final result = await parser.parse();

      expect(result, isNotEmpty);
      expect(result.first.path, 'lib/main.dart');

      final contentLines = result.first.content;
      expect(contentLines.any((line) => line.lineContent.contains('import \'dart:math\'')), isTrue);
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
  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    bool runInShell = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Process> start(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    bool runInShell = false,
  }) async {
    return _FakeProcess(stdoutStream, stderrStream, exitCodeResult);
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
