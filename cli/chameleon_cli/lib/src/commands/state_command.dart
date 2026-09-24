import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason/mason.dart' as mason;
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../bundles/chameleon_state_bundle.dart';
import '../doctor.dart';
import '../pascal_case.dart';
import '../process_runner.dart';
import '../template_provenance.dart';
import 'pipeline_steps.dart';

/// `chameleon state <name>` — adds a second piece of feature-local state
/// (Bloc/Cubit, a Provider `ChangeNotifier`, or a riverpod `Notifier`) +
/// sealed states + tests inside an existing feature of a Chameleon app. Not
/// wired to a repository (that's `chameleon feature`'s job) — this is for a
/// piece of state a feature's main bloc/controller/provider doesn't cover.
class StateCommand extends Command<int> with PipelineSteps {
  StateCommand({required this.logger, ProcessRunner? runner})
    : processRunner = runner ?? const SystemProcessRunner() {
    argParser
      ..addOption(
        'feature',
        mandatory: true,
        help: 'The existing feature (under lib/features/) to nest this in.',
      )
      ..addOption(
        'state',
        allowed: ['bloc', 'provider', 'riverpod'],
        help:
            'State-management shape to generate. Defaults to the target '
            "app's own choice, read from .chameleon/template.yaml.",
      )
      ..addFlag(
        'cubit',
        help:
            'When --state is bloc (the default), generate a Cubit '
            'instead of a Bloc. Ignored for provider/riverpod.',
      )
      ..addFlag('codegen', defaultsTo: true, help: 'Run build_runner.')
      ..addFlag(
        'verify',
        defaultsTo: true,
        help: 'Run flutter analyze + flutter test before reporting success.',
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

  @override
  String get name => 'state';

  @override
  String get description =>
      'Add a second piece of feature-local state to an existing feature '
      'of a Chameleon app.';

  @override
  Future<int> run() async {
    final results = argResults!;
    if (results.rest.isEmpty) {
      logger.err('Usage: chameleon state <name> --feature <feature_name>');
      return ExitCode.usage.code;
    }
    final blocName = results.rest.first;

    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(blocName)) {
      logger.err(
        '"$blocName" is not a valid name '
        '(snake_case, must start with a lowercase letter).',
      );
      return ExitCode.usage.code;
    }

    // `mandatory: true` on the option only throws when its value is
    // actually accessed (an ArgumentError, not a UsageException) — check
    // explicitly so a missing --feature fails the same clean way every
    // other validation error here does, rather than an uncaught exception.
    if (!results.wasParsed('feature')) {
      logger.err('Usage: chameleon state <name> --feature <feature_name>');
      return ExitCode.usage.code;
    }
    final featureName = results['feature'] as String;
    final useCubit = results['cubit'] as bool;
    final projectRoot = Directory.current;

    final provenance = File(
      p.join(projectRoot.path, '.chameleon', 'template.yaml'),
    );
    if (!provenance.existsSync()) {
      logger.err(
        'No .chameleon/template.yaml found in ${projectRoot.path}.\n'
        'Run `chameleon state` from the root of a Chameleon app generated '
        'by `chameleon create`.',
      );
      return ExitCode.usage.code;
    }

    final stateManagement = results.wasParsed('state')
        ? results['state'] as String
        : readStateManagementDefault(projectRoot);

    final featureDir = Directory(
      p.join(projectRoot.path, 'lib', 'features', featureName),
    );
    if (!featureDir.existsSync()) {
      logger.err(
        'lib/features/$featureName does not exist. Run '
        '`chameleon feature $featureName` first, or pass an existing '
        'feature with --feature.',
      );
      return ExitCode.usage.code;
    }

    final stateFileName = switch (stateManagement) {
      'bloc' => '${blocName}_${useCubit ? 'cubit' : 'bloc'}.dart',
      'provider' => '${blocName}_controller.dart',
      'riverpod' => '${blocName}_provider.dart',
      _ => throw StateError('unreachable: $stateManagement'),
    };
    final stateFile = File(
      p.join(featureDir.path, 'presentation', 'state', stateFileName),
    );
    if (stateFile.existsSync()) {
      logger.err(
        '${stateFile.path} already exists. chameleon_state does not '
        'overwrite existing state.',
      );
      return ExitCode.usage.code;
    }

    final pubspecFile = File(p.join(projectRoot.path, 'pubspec.yaml'));
    final pubspecYaml = loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
    final projectName = pubspecYaml['name'] as String;

    final doctor = Doctor(runner: processRunner);
    final report = await doctor.check(directory: projectRoot.path);
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

    final vars = <String, dynamic>{
      'feature_name': featureName,
      'bloc_name': blocName,
      'state_management': stateManagement,
      'cubit': useCubit,
      'project_name': projectName,
    };

    final generationLabel = 'Generating $stateManagement "$blocName"';
    final generated = await step(generationLabel, () async {
      final generator = await mason.MasonGenerator.fromBundle(
        chameleonStateBundle,
      );
      Map<String, dynamic>? updatedVars;
      await generator.hooks.preGen(
        vars: vars,
        workingDirectory: projectRoot.path,
        onVarsChanged: (v) => updatedVars = v,
      );
      await generator.generate(
        mason.DirectoryGeneratorTarget(projectRoot),
        vars: updatedVars ?? vars,
        fileConflictResolution: mason.FileConflictResolution.overwrite,
      );
      await generator.hooks.postGen(
        vars: updatedVars ?? vars,
        workingDirectory: projectRoot.path,
      );
    });
    if (!generated) return ExitCode.software.code;

    if (results['codegen'] as bool) {
      final ok = await step(
        'Running build_runner',
        () => exec(dartExecutable, [
          ...dartPrefix,
          'run',
          'build_runner',
          'build',
          '--delete-conflicting-outputs',
        ], cwd: projectRoot.path),
      );
      if (!ok) return ExitCode.software.code;
    }

    if (results['verify'] as bool) {
      final verified = await verify(
        projectRoot.path,
        flutterExecutable,
        flutterPrefix,
      );
      if (!verified) return ExitCode.software.code;
    }

    final className = switch (stateManagement) {
      'bloc' => '${pascalCase(blocName)}${useCubit ? 'Cubit' : 'Bloc'}',
      'provider' => '${pascalCase(blocName)}Controller',
      'riverpod' => '${pascalCase(blocName)}Notifier',
      _ => throw StateError('unreachable: $stateManagement'),
    };
    final nextStep = switch (stateManagement) {
      'bloc' => useCubit ? 'start()' : '_onStarted',
      'provider' => 'start()',
      'riverpod' => 'start()',
      _ => throw StateError('unreachable: $stateManagement'),
    };

    logger
      ..info('')
      ..success(
        'lib/features/$featureName/presentation/state/$stateFileName is ready.',
      )
      ..info('')
      ..info('Next:')
      ..info(
        '  Replace the placeholder $nextStep body with the real work '
        '$className should do.',
      );
    return ExitCode.success.code;
  }
}
