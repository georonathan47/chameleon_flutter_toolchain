import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../doctor.dart';
import '../process_runner.dart';
import 'pipeline_steps.dart';

/// `chameleon firebase verify <project-id> [<project-id> ...]` — confirms
/// each given Firebase project ID is real and accessible under whoever is
/// logged in (`firebase login`), with no side effects.
///
/// This toolchain has no `--firebase-project-*` flow of its own (Firebase is
/// not a dependency anywhere in `chameleon_core`/the app brick by default) —
/// this command is a standalone sanity check for a project ID before wiring
/// Firebase into an app by hand. It uses `firebase apps:list --project=<id>`:
/// a real, targeted Firebase API call scoped to that exact project, but one
/// that only reads — it lists whatever apps already exist, or fails if the
/// project doesn't exist or isn't accessible, and either way registers
/// nothing.
class FirebaseVerifyCommand extends Command<int> with PipelineSteps {
  FirebaseVerifyCommand({required this.logger, ProcessRunner? runner})
    : processRunner = runner ?? const SystemProcessRunner();

  @override
  final Logger logger;
  @override
  final ProcessRunner processRunner;

  @override
  String get name => 'verify';

  @override
  String get description =>
      'Verify one or more Firebase project IDs are real and accessible.';

  @override
  Future<int> run() async {
    final projectIds = argResults!.rest;
    if (projectIds.isEmpty) {
      logger.err(
        'Usage: chameleon firebase verify <project-id> [<project-id> ...]',
      );
      return ExitCode.usage.code;
    }

    final doctor = Doctor(runner: processRunner);
    final report = await doctor.check();
    if (!report.hasFirebaseTools) {
      logger.err(
        'firebase (firebase-tools) is required to verify a Firebase '
        'project. Install it: npm install -g firebase-tools, then run '
        '`firebase login`.',
      );
      return ExitCode.unavailable.code;
    }

    var allVerified = true;
    for (final projectId in projectIds) {
      final verified = await step(
        'Verifying $projectId',
        () => exec('firebase', ['apps:list', '--project=$projectId']),
      );
      if (!verified) allVerified = false;
    }

    if (!allVerified) {
      logger
        ..info('')
        ..err('One or more project IDs could not be verified.');
      return ExitCode.software.code;
    }

    logger
      ..info('')
      ..success(
        projectIds.length == 1
            ? 'Verified.'
            : 'Verified all ${projectIds.length} project IDs.',
      );
    return ExitCode.success.code;
  }
}
