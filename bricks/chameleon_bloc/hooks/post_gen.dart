import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final featureName = context.vars['feature_name'] as String;
  final blocName = context.vars['bloc_name'] as String;
  final useCubit = context.vars['use_cubit'] as bool;
  final root = Directory.current;

  final libDir = 'lib/features/$featureName/presentation/bloc';
  final testDir = 'test/features/$featureName/presentation';
  final suffix = useCubit ? 'cubit' : 'bloc';

  final targets = <String>[
    '$libDir/${blocName}_$suffix.dart',
    '$libDir/${blocName}_state.dart',
    if (!useCubit) '$libDir/${blocName}_event.dart',
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
    'chameleon_bloc "$blocName" (${useCubit ? 'cubit' : 'bloc'}) applied to '
    '$featureName.',
  );
}
