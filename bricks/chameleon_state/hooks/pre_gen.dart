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
  final stateManagement = context.vars['state_management'] as String;
  final cubit = context.vars['cubit'] as bool;

  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(blocName)) {
    context.logger.err(
      '"$blocName" is not a valid name '
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
      '`chameleon feature $featureName` first, or pass an existing '
      'feature name.',
    );
    throw Exception('feature does not exist');
  }

  final isBloc = stateManagement == 'bloc';
  final isProvider = stateManagement == 'provider';
  final isRiverpod = stateManagement == 'riverpod';
  context.vars['is_bloc'] = isBloc;
  context.vars['is_provider'] = isProvider;
  context.vars['is_riverpod'] = isRiverpod;

  // `cubit` only chooses a shape within `bloc` — same "bloc folds cubit"
  // convention `chameleon create`/`chameleon feature` use, so it's ignored
  // outright rather than erroring when state_management is provider/riverpod.
  context.vars['use_cubit'] = isBloc && cubit;
  context.vars['use_bloc'] = isBloc && !cubit;

  final fileName = switch (stateManagement) {
    'bloc' => '${blocName}_${cubit ? 'cubit' : 'bloc'}.dart',
    'provider' => '${blocName}_controller.dart',
    'riverpod' => '${blocName}_provider.dart',
    _ => throw StateError('unreachable: $stateManagement'),
  };
  final existing = File(
    'lib/features/$featureName/presentation/state/$fileName',
  );
  if (existing.existsSync()) {
    context.logger.err(
      '${existing.path} already exists. chameleon_state does not overwrite '
      'existing state.',
    );
    throw Exception('state already exists');
  }
}
