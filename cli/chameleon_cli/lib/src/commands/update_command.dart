import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_semver/pub_semver.dart';

import '../process_runner.dart';
import '../updater.dart';
import '../version.dart';
import 'pipeline_steps.dart';

/// `chameleon update` — checks the toolchain repo's git tags for a newer
/// `chameleon_cli` release and reactivates from it if one exists. There is no
/// pub.dev registry here (the toolchain distributes via git refs against a
/// private GitHub repo), so this checks tags directly rather than using
/// `pub_updater` (which only talks to pub.dev).
class UpdateCommand extends Command<int> with PipelineSteps {
  UpdateCommand({required this.logger, ProcessRunner? runner})
    : processRunner = runner ?? const SystemProcessRunner() {
    argParser
      ..addOption(
        'repo-url',
        defaultsTo: _defaultRepoUrl,
        help: 'Git URL of the chameleon_flutter_toolchain repo to check.',
      )
      ..addOption(
        'ref-prefix',
        defaultsTo: 'chameleon_cli-v',
        help: 'Tag prefix chameleon_cli releases are tagged with.',
      )
      ..addFlag(
        'dry-run',
        help: 'Report what would happen without reactivating.',
      );
  }

  static const _defaultRepoUrl =
      'https://github.com/georonathan47/chameleon_flutter_toolchain';

  @override
  final Logger logger;
  @override
  final ProcessRunner processRunner;

  @override
  String get name => 'update';

  @override
  String get description =>
      'Check for and install a newer chameleon_cli release.';

  @override
  Future<int> run() async {
    final results = argResults!;
    final repoUrl = results['repo-url'] as String;
    final refPrefix = results['ref-prefix'] as String;
    final dryRun = results['dry-run'] as bool;

    final updater = Updater(runner: processRunner);
    final current = Version.parse(packageVersion);

    Version? latest;
    final checked = await step(
      'Checking $repoUrl for a newer release',
      () async {
        latest = await updater.latestTag(repoUrl, refPrefix);
      },
    );
    if (!checked) return ExitCode.software.code;

    if (latest == null) {
      logger.warn('No tags matching "$refPrefix*" found at $repoUrl.');
      return ExitCode.success.code;
    }

    if (latest! <= current) {
      logger.success(
        'chameleon_cli $packageVersion is already up to date '
        '(latest: $latest).',
      );
      return ExitCode.success.code;
    }

    if (dryRun) {
      logger.info(
        'chameleon_cli $packageVersion -> $latest available '
        '(dry run, not installed).',
      );
      return ExitCode.success.code;
    }

    final ref = '$refPrefix$latest';
    final updated = await step(
      'Updating to $ref',
      () => exec('dart', [
        'pub',
        'global',
        'activate',
        '--source',
        'git',
        repoUrl,
        '--git-path',
        'cli/chameleon_cli',
        '--git-ref',
        ref,
      ]),
    );
    if (!updated) return ExitCode.software.code;

    logger.success('Updated chameleon_cli $packageVersion -> $latest.');
    return ExitCode.success.code;
  }
}
