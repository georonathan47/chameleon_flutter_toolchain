import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final featureName = context.vars['feature_name'] as String;
  final blocName = context.vars['bloc_name'] as String;
  final stateManagement = context.vars['state_management'] as String;
  final useCubit = context.vars['use_cubit'] as bool;
  final root = Directory.current;

  final libDir = 'lib/features/$featureName/presentation/state';
  final testDir = 'test/features/$featureName/presentation';

  final suffix = switch (stateManagement) {
    'bloc' => useCubit ? 'cubit' : 'bloc',
    'provider' => 'controller',
    'riverpod' => 'provider',
    _ => throw StateError('unreachable: $stateManagement'),
  };

  final targets = <String>[
    '$libDir/${blocName}_$suffix.dart',
    '$libDir/${blocName}_state.dart',
    if (stateManagement == 'bloc' && !useCubit) '$libDir/${blocName}_event.dart',
    '$testDir/${blocName}_${suffix}_test.dart',
  ].where((path) => File('${root.path}/$path').existsSync()).toList();

  if (targets.isEmpty) return;

  final result = await Process.run(Platform.resolvedExecutable, [
    'format',
    ...targets,
  ], workingDirectory: root.path);
  if (result.exitCode != 0) {
    context.logger.warn('dart format failed: ${result.stderr}');
  }

  context.logger.success(
    'chameleon_state "$blocName" ($stateManagement'
    '${stateManagement == 'bloc' ? (useCubit ? '/cubit' : '/bloc') : ''}) '
    'applied to $featureName.',
  );
}
