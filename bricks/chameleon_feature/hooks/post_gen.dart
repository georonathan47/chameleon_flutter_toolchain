import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final name = context.vars['feature_name'] as String;
  final root = Directory.current;

  // Scoped to just this feature's own lib/test paths, not the whole
  // project — cheap, and avoids reformatting files this brick never
  // touched (same reasoning as chameleon_app's own post_gen hook).
  final targets = [
    'lib/features/$name',
    'test/features/$name',
  ].where((path) => Directory('${root.path}/$path').existsSync()).toList();

  if (targets.isEmpty) return;

  final result = await Process.run(Platform.resolvedExecutable, [
    'format',
    ...targets,
  ], workingDirectory: root.path);
  if (result.exitCode != 0) {
    context.logger.warn('dart format failed: ${result.stderr}');
  }

  context.logger.success('chameleon_feature "$name" applied.');
}
