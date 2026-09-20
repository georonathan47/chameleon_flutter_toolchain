import 'dart:io';

import 'package:mason/mason.dart';

const _dartReservedWords = <String>{
  'assert', 'break', 'case', 'catch', 'class', 'const', 'continue', 'default',
  'do', 'else', 'enum', 'extends', 'false', 'final', 'finally', 'for', 'if',
  'in', 'is', 'new', 'null', 'rethrow', 'return', 'super', 'switch', 'this',
  'throw', 'true', 'try', 'var', 'void', 'while', 'with',
};

void run(HookContext context) {
  final name = context.vars['feature_name'] as String;

  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
    context.logger.err(
      '"$name" is not a valid feature name '
      '(snake_case, must start with a lowercase letter).',
    );
    throw Exception('invalid feature_name');
  }
  if (_dartReservedWords.contains(name)) {
    context.logger.err('"$name" is a Dart reserved word.');
    throw Exception('reserved feature_name');
  }

  // This brick generates into an existing app's lib/features/, not a fresh
  // directory — unlike chameleon_app, overwriting silently here would delete
  // a developer's real work, so refuse outright rather than merge/prompt.
  final existing = Directory('lib/features/$name');
  if (existing.existsSync()) {
    context.logger.err(
      'lib/features/$name already exists. chameleon_feature does not '
      'overwrite an existing feature — remove it first if you really '
      'want to regenerate it.',
    );
    throw Exception('feature already exists');
  }
}
