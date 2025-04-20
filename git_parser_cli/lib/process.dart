import 'dart:io' as io;

/// An abstract interface for managing system process execution.
///
/// The [Process] interface provides a singleton-like access pattern for
/// executing and managing external system processes. It allows injection of
/// custom implementations, making it suitable for testing and extensibility.
///
/// You can either start a process asynchronously using [start], or run a
/// process and wait for the result using [run].
abstract interface class Process {
  static Process? _instance;

  /// Gets the current process implementation instance.
  ///
  /// If no custom implementation has been set, returns the default
  /// internal implementation [_ProcessImpl].
  static Process get instance => _instance ?? _ProcessImpl();

  /// Sets a custom implementation for the [Process] interface.
  ///
  /// This allows injection of mock or alternate implementations for testing
  /// or platform-specific behavior.
  static set instance(Process instance) => _instance = instance;

  /// Starts a new system process.
  ///
  /// Executes an external process asynchronously without waiting for its
  /// completion. This is useful for long-running background processes.
  ///
  /// - [executable]: The name or path of the executable to run.
  /// - [arguments]: A list of arguments to pass to the executable.
  /// - [workingDirectory]: (Optional) The directory in which to start the process.
  /// - [runInShell]: Whether to execute the command in a system shell.
  ///
  /// Returns a [Future] that completes with a [io.Process] representing the started process.
  Future<io.Process> start(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    bool runInShell = false,
  });

  /// Runs a system process and waits for it to complete.
  ///
  /// Executes an external command and waits for its result. This is useful
  /// for processes where you need the output or exit code.
  ///
  /// - [executable]: The name or path of the executable to run.
  /// - [arguments]: A list of arguments to pass to the executable.
  /// - [runInShell]: Whether to execute the command in a system shell.
  ///
  /// Returns a [Future] that completes with a [io.ProcessResult] containing
  /// the output, error output, and exit code.
  Future<io.ProcessResult> run(
    String executable,
    List<String> arguments, {
    bool runInShell = false,
  });
}

/// The default implementation of the [Process] interface.
///
/// Delegates process execution to Dart's [io.Process] class.
class _ProcessImpl extends Process {
  @override
  Future<io.ProcessResult> run(
    String executable,
    List<String> arguments, {
    bool runInShell = false,
  }) async {
    return io.Process.run(
      executable,
      arguments,
      runInShell: runInShell,
    );
  }

  @override
  Future<io.Process> start(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    bool runInShell = false,
  }) async {
    return io.Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      runInShell: runInShell,
    );
  }
}
