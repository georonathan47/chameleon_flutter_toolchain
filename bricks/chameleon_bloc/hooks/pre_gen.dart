import 'dart:io';

import 'package:mason/mason.dart';

const _dartReservedWords = <String>{
  'assert', 'break', 'case', 'catch', 'class', 'const', 'continue', 'default',
  'do', 'else', 'enum', 'extends', 'false', 'final', 'finally', 'for', 'if',
  'in', 'is', 'new', 'null', 'rethrow', 'return', 'super', 'switch', 'this',
  'throw', 'true', 'try', 'var', 'void', 'while', 'with',
};

void run(HookContext context) {
  final blocName = context.vars['bloc_name'] as String;
  final featureName = context.vars['feature_name'] as String;
  final cubit = context.vars['cubit'] as bool;

  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(blocName)) {
    context.logger.err(
      '"$blocName" is not a valid bloc/cubit name '
      '(snake_case, must start with a lowercase letter).',
    );
    throw Exception('invalid bloc_name');
  }
  if (_dartReservedWords.contains(blocName)) {
    context.logger.err('"$blocName" is a Dart reserved word.');
    throw Exception('reserved bloc_name');
  }

  // This brick nests inside an existing feature — it doesn't create one.
  final featureDir = Directory('lib/features/$featureName');
  if (!featureDir.existsSync()) {
    context.logger.err(
      'lib/features/$featureName does not exist. Run '
      '`chameleon flutter feature $featureName` first, or pass an existing '
      'feature name.',
    );
    throw Exception('feature does not exist');
  }

  final blocFileName = cubit ? '${blocName}_cubit.dart' : '${blocName}_bloc.dart';
  final existing = File('lib/features/$featureName/presentation/bloc/$blocFileName');
  if (existing.existsSync()) {
    context.logger.err(
      '${existing.path} already exists. chameleon_bloc does not overwrite an '
      'existing bloc/cubit.',
    );
    throw Exception('bloc already exists');
  }

  // File-path conditionals in this brick's templates use positive sections
  // only (verified pattern already used by chameleon_app's own
  // {{#use_biometrics}}file{{/use_biometrics}} paths) — deriving both
  // booleans here avoids depending on an untested {{^cond}}
  // path-conditional.
  context.vars['use_cubit'] = cubit;
  context.vars['use_bloc'] = !cubit;
}
