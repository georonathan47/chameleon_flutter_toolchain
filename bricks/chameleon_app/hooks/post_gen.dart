import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final root = Directory.current;

  // `very_good create flutter_app` ships a demo `counter` feature and its
  // test. It is never part of the Chameleon app (nothing in lib/app or
  // lib/core wires it in) and its test only ever passed against VGV's own
  // `pump_app.dart`, which sets up localization delegates the counter demo
  // needs — this brick's `pump_app.dart` replaces that helper with one built
  // for `App`/`ChameleonToastHost` and does not. Confirmed by actually
  // generating an app and running `flutter test`: left in place, the counter
  // test fails with a null localization lookup, not a template bug in the
  // Chameleon code itself. Delete it here rather than patch the test to keep
  // demo code no Chameleon app is meant to ship.
  for (final leftover in ['lib/counter', 'test/counter']) {
    final dir = Directory('${root.path}/$leftover');
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  }

  // envied generates env.g.dart from .env at build time. No .env, no
  // env.g.dart, and per chameleon_app's own tasks/lessons.md, that failure
  // surfaces as every other build_runner builder erroring at once — so this
  // must exist before anyone runs codegen.
  final env = File('${root.path}/.env');
  final envExample = File('${root.path}/.env.example');
  if (!env.existsSync() && envExample.existsSync()) {
    env.writeAsStringSync(envExample.readAsStringSync());
    context.logger.info(
      'Created .env from .env.example — fill in the real base URLs.',
    );
  }

  for (final scriptName in ['checks.sh', 'verify.sh']) {
    final script = File('${root.path}/tool/$scriptName');
    if (!script.existsSync()) continue;
    final result = await Process.run('chmod', ['+x', script.path]);
    if (result.exitCode != 0) {
      context.logger.warn('Could not chmod +x tool/$scriptName: ${result.stderr}');
    }
  }

  // Reformats the generated tree to dart_style's canonical output. Templates
  // can't practically stay byte-for-byte in canonical style across every
  // mustache conditional combination (a `{{#flag}}` block that changes
  // whether an argument list fits on one line shifts formatting for
  // everything after it) — this is cheap and needs nothing resolved yet
  // (no pub get, no build_runner), unlike the analyze/test/build steps the
  // future `chameleon` CLI owns, so it belongs here rather than being left
  // for the developer's first `tool/verify.sh` run to catch as a failure.
  final dartExecutable = Platform.resolvedExecutable;
  final formatResult = await Process.run(dartExecutable, [
    'format',
    'lib',
    'test',
  ], workingDirectory: root.path);
  if (formatResult.exitCode != 0) {
    context.logger.warn('dart format lib test failed: ${formatResult.stderr}');
  }

  // Records exactly what produced this project, so a later `chameleon
  // doctor` (once it exists) can tell a stale chameleon_ui/chameleon_core
  // ref apart from one that was never pinned in the first place.
  final provenance = File('${root.path}/.chameleon/template.yaml');
  provenance.createSync(recursive: true);
  provenance.writeAsStringSync('''
generated_with:
  chameleon_app_brick: ${context.vars['_brick_version'] ?? '1.0.0'}
  chameleon_ui_ref: ${context.vars['chameleon_ui_ref']}
  chameleon_core_ref: ${context.vars['chameleon_core_ref']}
  generated_at: ${DateTime.now().toUtc().toIso8601String()}
''');

  context.logger.success('chameleon_app template applied.');
}
