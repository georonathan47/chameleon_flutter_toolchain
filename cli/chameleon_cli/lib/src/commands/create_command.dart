import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason/mason.dart' as mason;
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;

import '../bundles/chameleon_app_bundle.dart';
import '../doctor.dart';
import '../icons/flavor_icon_installer.dart';
import '../process_runner.dart';
import 'pipeline_steps.dart';

const _allowedPermissions = [
  'camera',
  'microphone',
  'photos',
  'location',
  'notification',
  'contacts',
];

/// `chameleon create <name>` — scaffolds a new Chameleon Flutter app by
/// running `very_good create` (or plain `flutter create`), overlaying the
/// bundled `chameleon_app` brick, resolving dependencies, generating code,
/// and verifying the result, adapted to the brick's actual variable surface
/// (no flavorizr/shorebird/liveness/messaging vars exist in this brick
/// version).
class CreateCommand extends Command<int> with PipelineSteps {
  CreateCommand({
    required this.logger,
    ProcessRunner? runner,
    FlavorIconInstaller? flavorIconInstaller,
  }) : processRunner = runner ?? const SystemProcessRunner(),
       flavorIconInstaller =
           flavorIconInstaller ?? const FlavorIconInstaller() {
    argParser
      ..addOption(
        'org',
        defaultsTo: 'com.example',
        help: 'Reverse-domain organization identifier.',
      )
      ..addOption('desc', defaultsTo: 'A Chameleon Flutter application.')
      ..addOption(
        'output-dir',
        abbr: 'o',
        defaultsTo: '.',
        help: 'Directory the project is created in.',
      )
      ..addOption('state', allowed: ['bloc', 'cubit'], defaultsTo: 'bloc')
      ..addOption(
        'router',
        allowed: ['go_router', 'auto_route'],
        defaultsTo: 'go_router',
        help: 'Router package.',
      )
      ..addMultiOption('permissions', allowed: _allowedPermissions)
      ..addFlag(
        'biometrics',
        help:
            'Wire BiometricAuthenticator to local_auth (Face ID, Touch ID, '
            'fingerprint). Requires manually adding '
            'NSFaceIDUsageDescription and the Android biometric '
            'permission — tool/checks.sh verifies both.',
      )
      ..addFlag(
        'home-widget',
        help:
            'Wire HomeWidgetUpdater to the home_widget plugin. Generates a '
            'working Android AppWidgetProvider automatically; the iOS '
            'Widget Extension target has to be added manually in Xcode — '
            'Swift starter source and setup steps ship under '
            'ios/HomeWidgetExtension/.',
      )
      ..addFlag(
        'push-notifications',
        help:
            'Wire PushNotificationService to firebase_messaging. Declares '
            'the Android 13+ POST_NOTIFICATIONS permission automatically; '
            'everything else — a real Firebase project '
            '(`flutterfire configure`) and the iOS Push Notifications + '
            'Background Modes capabilities in Xcode — is a one-time manual '
            'step. See docs/architecture.md.',
      )
      ..addFlag('install', defaultsTo: true, help: 'Run flutter pub get.')
      ..addFlag('codegen', defaultsTo: true, help: 'Run build_runner.')
      ..addFlag(
        'verify',
        defaultsTo: true,
        help: 'Run flutter analyze + flutter test before reporting success.',
      )
      ..addFlag(
        'git',
        defaultsTo: true,
        help: 'Initialise a git repo and make the first commit.',
      )
      ..addFlag(
        'fvm',
        help: 'Force fvm on/off. Defaults to auto-detecting a .fvmrc.',
      );
  }

  @override
  final Logger logger;
  @override
  final ProcessRunner processRunner;
  final FlavorIconInstaller flavorIconInstaller;

  @override
  String get name => 'create';

  @override
  String get description => 'Create a new Chameleon Flutter application.';

  @override
  Future<int> run() async {
    final results = argResults!;
    if (results.rest.isEmpty) {
      logger.err('Usage: chameleon create <project_name>');
      return ExitCode.usage.code;
    }
    final projectName = results.rest.first;

    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(projectName)) {
      logger.err(
        '"$projectName" is not a valid Dart package name '
        '(snake_case, must start with a lowercase letter).',
      );
      return ExitCode.usage.code;
    }

    final outputRoot = results['output-dir'] as String;
    final outputDir = Directory(p.join(outputRoot, projectName));
    if (outputDir.existsSync() && outputDir.listSync().isNotEmpty) {
      logger.err('${outputDir.path} already exists and is not empty.');
      return ExitCode.usage.code;
    }

    final doctor = Doctor(runner: processRunner);
    final report = await doctor.check();
    if (!report.isUsable) {
      logger.err(
        'Toolchain is not usable — run `chameleon doctor` for details.',
      );
      return ExitCode.unavailable.code;
    }

    final useFvm = (results['fvm'] as bool?) ?? report.useFvm;
    final flutterExecutable = useFvm ? 'fvm' : 'flutter';
    final flutterPrefix = useFvm ? const ['flutter'] : const <String>[];
    final dartExecutable = useFvm ? 'fvm' : 'dart';
    final dartPrefix = useFvm ? const ['dart'] : const <String>[];
    final permissions = results['permissions'] as List<String>;

    final created = await step('Creating Flutter project', () async {
      if (report.hasVeryGoodCli) {
        return exec('very_good', [
          'create',
          'flutter_app',
          projectName,
          '--org',
          results['org'] as String,
          '--desc',
          results['desc'] as String,
          '-o',
          outputRoot,
        ]);
      }
      logger.warn(
        'very_good_cli not found — falling back to `flutter create`. '
        'Install it with `dart pub global activate very_good_cli` for the '
        'full VGV bootstrap (flavors, CI, l10n).',
      );
      return exec(flutterExecutable, [
        ...flutterPrefix,
        'create',
        '--org',
        results['org'] as String,
        '--project-name',
        projectName,
        outputDir.path,
      ]);
    });
    if (!created) return ExitCode.software.code;

    final iconsInstalled = await step('Generating flavor app icons', () async {
      flavorIconInstaller.installAll(outputDir.path);
    });
    if (!iconsInstalled) return ExitCode.software.code;

    final vars = <String, dynamic>{
      'project_name': projectName,
      'org_name': results['org'] as String,
      'description': results['desc'] as String,
      'state_management': results['state'] as String,
      'router': results['router'] as String,
      'use_biometrics': results['biometrics'] as bool,
      'permissions': permissions,
      'use_home_widget': results['home-widget'] as bool,
      'use_push_notifications': results['push-notifications'] as bool,
      // Kept in sync by hand with brick.yaml's own declared defaults — the
      // bundled generator does raw mustache substitution with no fallback
      // to a brick.yaml default for a var it isn't given, so these must be
      // supplied explicitly rather than left for the brick to default.
      'chameleon_ui_ref': 'chameleon_ui-v0.1.0',
      // v0.3.0, not v0.2.0: PushNotificationService only exists from
      // chameleon_core-v0.3.0 on.
      'chameleon_core_ref': 'chameleon_core-v0.3.0',
      'chameleon_lints_ref': 'chameleon_lints-v0.1.0',
    };

    final overlaid = await step('Applying Chameleon template', () async {
      final generator = await mason.MasonGenerator.fromBundle(
        chameleonAppBundle,
      );
      Map<String, dynamic>? updatedVars;
      await generator.hooks.preGen(
        vars: vars,
        workingDirectory: outputDir.path,
        onVarsChanged: (v) => updatedVars = v,
      );
      await generator.generate(
        mason.DirectoryGeneratorTarget(outputDir),
        vars: updatedVars ?? vars,
        fileConflictResolution: mason.FileConflictResolution.overwrite,
      );
      await generator.hooks.postGen(
        vars: updatedVars ?? vars,
        workingDirectory: outputDir.path,
      );
    });
    if (!overlaid) return ExitCode.software.code;

    if (results['install'] as bool) {
      final ok = await step(
        'Resolving dependencies',
        () => exec(flutterExecutable, [
          ...flutterPrefix,
          'pub',
          'get',
        ], cwd: outputDir.path),
      );
      if (!ok) return ExitCode.software.code;
    }

    if (results['codegen'] as bool) {
      final ok = await step(
        'Running build_runner',
        () => exec(dartExecutable, [
          ...dartPrefix,
          'run',
          'build_runner',
          'build',
          '--delete-conflicting-outputs',
        ], cwd: outputDir.path),
      );
      if (!ok) return ExitCode.software.code;
    }

    if (permissions.isNotEmpty && Platform.isMacOS) {
      final iosDir = p.join(outputDir.path, 'ios');
      if (Directory(iosDir).existsSync()) {
        if (await processRunner.exists('pod')) {
          await step(
            'Installing pods',
            // CocoaPods' Ruby crashes computing the installation root
            // (`String#unicode_normalize` on an ASCII-8BIT path) unless the
            // locale is UTF-8 — confirmed by hitting this for real on a
            // machine whose shell LANG isn't set. CocoaPods' own error
            // message says to set this; setting it here means a generated
            // project doesn't depend on the operator's shell profile.
            () => exec(
              'pod',
              ['install'],
              cwd: iosDir,
              environment: const {
                'LANG': 'en_US.UTF-8',
                'LC_ALL': 'en_US.UTF-8',
              },
            ),
          );
        } else {
          logger.warn(
            'CocoaPods not found — skipping pod install. The Podfile '
            'permission macros this project needs will not take effect '
            'until you run it yourself.',
          );
        }
      }
    }

    // Scoped to lib/test, not '.' — dart_style walks every file under the
    // target to resolve its analysis_options page-width, including
    // build/ios/SourcePackages/**, which ships broken relative includes in
    // vendored CocoaPods example projects and throws a
    // PathNotFoundException. `flutter analyze` tolerates this via
    // analysis_options' `exclude:` list; `dart format` does not consult it.
    // The brick's own post_gen hook scopes the same way for the same
    // reason.
    await exec(dartExecutable, [
      ...dartPrefix,
      'format',
      'lib',
      'test',
    ], cwd: outputDir.path);
    await exec(dartExecutable, [
      ...dartPrefix,
      'fix',
      '--apply',
    ], cwd: outputDir.path);

    if (results['verify'] as bool) {
      final verified = await verify(
        outputDir.path,
        flutterExecutable,
        flutterPrefix,
      );
      if (!verified) return ExitCode.software.code;
    }

    if (results['git'] as bool) {
      await step('Initialising git', () async {
        await exec('git', ['init'], cwd: outputDir.path);
        await exec('git', ['add', '.'], cwd: outputDir.path);
        return exec(
          'git',
          [
            'commit',
            '-m',
            'Initial commit — generated by chameleon create',
          ],
          cwd: outputDir.path,
        );
      });
    }

    logger
      ..info('')
      ..success('$projectName is ready.')
      ..info('')
      ..info('Next:')
      ..info('  cd $projectName')
      ..info(
        '  Fill in .env       (API base URLs per flavor — envied reads this)',
      )
      ..info('  flutter run --flavor development -t lib/main_development.dart')
      ..info('')
      ..info('Guardrails: ./tool/checks.sh   Lessons: tasks/lessons.md');
    return ExitCode.success.code;
  }
}
