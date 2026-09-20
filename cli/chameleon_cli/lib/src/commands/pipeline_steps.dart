import 'dart:io';

import 'package:mason_logger/mason_logger.dart';

import '../process_runner.dart';

/// Shared step/exec/verify plumbing for commands that shell out to
/// flutter/dart and report progress the same way — pulled out once
/// `FlutterCreateCommand` and `FlutterFeatureCommand` both needed the
/// identical verification-gate logic, rather than duplicating it.
///
/// Named `processRunner`/`exec` rather than `runner`/`run`: `Command<int>`
/// (from `package:args`) already declares both of those names (the owning
/// `CommandRunner` and the command's own entry point) — reusing them here
/// would collide when this mixin is applied to a `Command`.
mixin PipelineSteps {
  Logger get logger;
  ProcessRunner get processRunner;

  Future<bool> step(String message, Future<void> Function() action) async {
    final progress = logger.progress(message);
    try {
      await action();
      progress.complete();
      return true;
    } on Object catch (error) {
      progress.fail();
      logger.err('$error');
      return false;
    }
  }

  Future<void> exec(
    String executable,
    List<String> args, {
    String? cwd,
    Map<String, String>? environment,
  }) async {
    final result = await processRunner.run(
      executable,
      args,
      workingDirectory: cwd,
      environment: environment,
    );
    if (result.exitCode != 0) {
      throw ProcessException(
        executable,
        args,
        '${result.stdout}\n${result.stderr}'.trim(),
        result.exitCode,
      );
    }
  }

  Future<bool> verify(
    String projectDir,
    String flutterExecutable,
    List<String> flutterPrefix,
  ) async {
    final analyzeProgress = logger.progress('Running flutter analyze');
    final analyze = await processRunner.run(
      flutterExecutable,
      [...flutterPrefix, 'analyze'],
      workingDirectory: projectDir,
    );
    if (analyze.exitCode != 0) {
      analyzeProgress.fail();
      logger
        ..err('Generated project does not analyze cleanly.')
        ..err('This is a bug in the Chameleon template, not in your project.')
        ..info('${analyze.stdout}\n${analyze.stderr}');
      return false;
    }
    analyzeProgress.complete();

    final testProgress = logger.progress('Running flutter test');
    final test = await processRunner.run(
      flutterExecutable,
      [...flutterPrefix, 'test'],
      workingDirectory: projectDir,
    );
    if (test.exitCode != 0) {
      testProgress.fail();
      logger
        ..err(
          "Generated project's tests do not pass. Reporting as a template bug.",
        )
        ..info('${test.stdout}\n${test.stderr}');
      return false;
    }
    testProgress.complete();
    return true;
  }
}
