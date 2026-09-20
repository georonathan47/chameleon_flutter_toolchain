import 'dart:io';

import 'package:chameleon_cli/src/process_runner.dart';

/// A [ProcessRunner] test double. [missing] simulates an executable that
/// isn't on PATH (throws [ProcessException], matching what [Process.run]
/// does for real); [exitCodes] simulates a present tool that fails.
class FakeProcessRunner implements ProcessRunner {
  FakeProcessRunner({
    this.exitCodes = const {},
    this.missing = const {},
    this.onRun,
  });

  final Map<String, int> exitCodes;
  final Set<String> missing;

  /// Optional hook so a test can assert on which commands were run, or
  /// script a specific stdout/stderr for one.
  final ProcessResult? Function(String executable, List<String> args)? onRun;

  final calls = <(String executable, List<String> args, String? cwd)>[];

  @override
  Future<ProcessResult> run(
    String executable,
    List<String> args, {
    String? workingDirectory,
    Map<String, String>? environment,
  }) async {
    calls.add((executable, args, workingDirectory));
    if (missing.contains(executable)) {
      throw ProcessException(executable, args);
    }
    final scripted = onRun?.call(executable, args);
    if (scripted != null) return scripted;
    return ProcessResult(0, exitCodes[executable] ?? 0, '$executable ok', '');
  }

  @override
  Future<bool> exists(String executable) async => !missing.contains(executable);
}
