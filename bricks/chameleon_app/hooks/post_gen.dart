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

  // `--permissions` sets the ios/Podfile PERMISSION_* macros (via the
  // brick's own mustache templating) and derives usage_descriptions/
  // android_permissions in pre_gen.dart, but neither Info.plist nor
  // AndroidManifest.xml are brick-templated files — `very_good create`
  // owns them, generated before this brick ever overlays anything — so
  // the actual keys/permissions have to be patched in here, post-generation,
  // or a requested permission silently never reaches either native project
  // (an ITMS-90683 App Store rejection on iOS; a permission_handler request
  // that resolves "denied" with no OS prompt at all on Android, since the
  // platform itself gates on the manifest before permission_handler is
  // ever called). `tool/checks.sh`'s permission-macro-drift check is what
  // originally caught this being missing.
  final usageDescriptions = (context.vars['usage_descriptions'] as List)
      .cast<Map<dynamic, dynamic>>();
  _insertPlistEntries(
    File('${root.path}/ios/Runner/Info.plist'),
    usageDescriptions,
  );
  final androidPermissions = (context.vars['android_permissions'] as List)
      .cast<String>();
  _insertManifestPermissions(
    File('${root.path}/android/app/src/main/AndroidManifest.xml'),
    androidPermissions,
  );

  // Same reasoning as the permissions block above — AndroidManifest.xml
  // isn't brick-templated, so the <receiver> that registers
  // ChameleonHomeWidgetProvider has to be patched in here. Unlike
  // <uses-permission>, a <receiver> has to land *inside*
  // <application>...</application>, not before it — a different insertion
  // point from _insertManifestPermissions.
  if (context.vars['use_home_widget'] == true) {
    _insertManifestReceiver(
      File('${root.path}/android/app/src/main/AndroidManifest.xml'),
    );
    // home_widget's SPM package requires iOS 14+ (confirmed by actually
    // building: `flutter build ios` fails with "requires minimum platform
    // version 14.0... but this target supports 13.0" otherwise).
    // project.pbxproj isn't brick-templated either, so this has to be a
    // post-gen patch too, same reasoning as Info.plist/AndroidManifest.xml
    // above — raising a version-number string is a narrow, low-risk edit,
    // not structural project-file surgery (no target/file-graph changes).
    // The Podfile's matching `platform :ios, 14.0` bump is a normal
    // brick-templated mustache conditional, not a post-gen patch, since
    // the Podfile (unlike project.pbxproj) already lives under __brick__.
    _bumpIosDeploymentTarget(
      File('${root.path}/ios/Runner.xcodeproj/project.pbxproj'),
    );
  }

  for (final scriptName in ['checks.sh', 'verify.sh']) {
    final script = File('${root.path}/tool/$scriptName');
    if (!script.existsSync()) continue;
    final result = await Process.run('chmod', ['+x', script.path]);
    if (result.exitCode != 0) {
      context.logger.warn(
        'Could not chmod +x tool/$scriptName: ${result.stderr}',
      );
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

/// Inserts each `{key, value}` usage-description pair as a
/// `<key>...</key><string>...</string>` entry into `Info.plist`'s outer
/// `<dict>`, right before its closing tag. No-op if there's nothing to add
/// or the file doesn't exist (Android-only project, unlikely but cheap to
/// guard).
void _insertPlistEntries(
  File infoPlist,
  List<Map<dynamic, dynamic>> usageDescriptions,
) {
  if (usageDescriptions.isEmpty || !infoPlist.existsSync()) return;

  final entries = StringBuffer();
  for (final entry in usageDescriptions) {
    final key = entry['key'] as String;
    final value = entry['value'] as String;
    if (key.isEmpty) continue;
    entries
      ..writeln('\t<key>$key</key>')
      ..writeln('\t<string>${_escapeXml(value)}</string>');
  }
  if (entries.isEmpty) return;

  final content = infoPlist.readAsStringSync();
  final closing = RegExp(r'</dict>\s*</plist>\s*$');
  if (!closing.hasMatch(content)) {
    throw StateError(
      'ios/Runner/Info.plist does not end with the expected </dict>\n'
      '</plist> — very_good_cli/flutter create may have changed its '
      'template shape.',
    );
  }
  infoPlist.writeAsStringSync(
    content.replaceFirst(closing, '$entries</dict>\n</plist>\n'),
  );
}

/// Inserts each Android permission as a `<uses-permission>` element right
/// before `AndroidManifest.xml`'s `<application` tag. No-op if there's
/// nothing to add or the file doesn't exist.
void _insertManifestPermissions(File manifest, List<String> permissions) {
  if (permissions.isEmpty || !manifest.existsSync()) return;

  final content = manifest.readAsStringSync();
  final marker = content.indexOf('<application');
  if (marker == -1) {
    throw StateError(
      'android/app/src/main/AndroidManifest.xml has no <application> tag — '
      'very_good_cli/flutter create may have changed its template shape.',
    );
  }
  final lines = permissions
      .map(
        (permission) => '    <uses-permission android:name="$permission" />\n',
      )
      .join();
  manifest.writeAsStringSync(
    '${content.substring(0, marker)}$lines\n    ${content.substring(marker)}',
  );
}

/// Inserts the `<receiver>` that registers `ChameleonHomeWidgetProvider`
/// right before `AndroidManifest.xml`'s closing `</application>` tag — a
/// `<receiver>`, unlike a `<uses-permission>`, has to be a child of
/// `<application>`, not a sibling before it. No-op if the file doesn't
/// exist.
void _insertManifestReceiver(File manifest) {
  if (!manifest.existsSync()) return;

  final content = manifest.readAsStringSync();
  final marker = content.lastIndexOf('</application>');
  if (marker == -1) {
    throw StateError(
      'android/app/src/main/AndroidManifest.xml has no </application> tag '
      '— very_good_cli/flutter create may have changed its template shape.',
    );
  }

  const receiver = '''
    <receiver
        android:name="dev.chameleon.homewidget.ChameleonHomeWidgetProvider"
        android:exported="true">
        <intent-filter>
            <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
        </intent-filter>
        <meta-data
            android:name="android.appwidget.provider"
            android:resource="@xml/chameleon_home_widget_info" />
    </receiver>

''';

  manifest.writeAsStringSync(
    '${content.substring(0, marker)}$receiver${content.substring(marker)}',
  );
}

/// Raises every `IPHONEOS_DEPLOYMENT_TARGET = 13.0;` (Debug/Release/Profile
/// × Runner/RunnerTests, `very_good_cli`'s default) to `14.0` —
/// `home_widget`'s SPM package won't resolve below that. No-op if the file
/// doesn't exist or nothing matches (e.g. `very_good_cli` already defaults
/// to 14.0+ in a future version).
void _bumpIosDeploymentTarget(File pbxproj) {
  if (!pbxproj.existsSync()) return;

  final content = pbxproj.readAsStringSync();
  final updated = content.replaceAll(
    'IPHONEOS_DEPLOYMENT_TARGET = 13.0;',
    'IPHONEOS_DEPLOYMENT_TARGET = 14.0;',
  );
  if (updated != content) pbxproj.writeAsStringSync(updated);
}

String _escapeXml(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
