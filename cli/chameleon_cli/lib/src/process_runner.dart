import 'dart:io';

/// Runs external processes. An interface rather than calling [Process.run]
/// directly so commands can be unit-tested against a fake instead of
/// shelling out to a real `flutter`/`git`/`pod` binary.
abstract class ProcessRunner {
  /// Runs [executable] with [args], waiting for it to complete. [environment]
  /// entries are added on top of (not replacing) the current environment.
  Future<ProcessResult> run(
    String executable,
    List<String> args, {
    String? workingDirectory,
    Map<String, String>? environment,
  });

  /// Whether [executable] resolves to something runnable on this machine.
  Future<bool> exists(String executable);
}

class SystemProcessRunner implements ProcessRunner {
  const SystemProcessRunner();

  @override
  Future<ProcessResult> run(
    String executable,
    List<String> args, {
    String? workingDirectory,
    Map<String, String>? environment,
  }) {
    return Process.run(
      executable,
      args,
      workingDirectory: workingDirectory,
      environment: environment,
      runInShell: true,
    );
  }

  @override
  Future<bool> exists(String executable) async {
    final checker = Platform.isWindows ? 'where' : 'which';
    final result = await run(checker, [executable]);
    return result.exitCode == 0;
  }
}
