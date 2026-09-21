import 'package:mason/mason.dart';

const _dartReservedWords = <String>{
  'assert', 'break', 'case', 'catch', 'class', 'const', 'continue', 'default',
  'do', 'else', 'enum', 'extends', 'false', 'final', 'finally', 'for', 'if',
  'in', 'is', 'new', 'null', 'rethrow', 'return', 'super', 'switch', 'this',
  'throw', 'true', 'try', 'var', 'void', 'while', 'with',
};

/// Maps a requested runtime permission to the `permission_handler` build
/// macro that must be set to `1` in `ios/Podfile`'s `post_install` block —
/// per chameleon_app's own `tasks/lessons.md`: without this, every request
/// for that permission resolves `permanentlyDenied` with no OS prompt ever
/// shown, no matter what Info.plist says.
String _permissionMacro(String permission) =>
    'PERMISSION_${permission.toUpperCase()}=1';

/// Maps a requested permission to its `Info.plist` usage-description key and
/// a default (placeholder) copy the app owner should replace.
({String key, String value}) _usageDescription(String permission) {
  return switch (permission) {
    'camera' => (
      key: 'NSCameraUsageDescription',
      value: 'TODO(chameleon): explain why this app needs camera access.',
    ),
    'microphone' => (
      key: 'NSMicrophoneUsageDescription',
      value: 'TODO(chameleon): explain why this app needs microphone access.',
    ),
    'photos' => (
      key: 'NSPhotoLibraryUsageDescription',
      value: 'TODO(chameleon): explain why this app needs photo library access.',
    ),
    'location' => (
      key: 'NSLocationWhenInUseUsageDescription',
      value: 'TODO(chameleon): explain why this app needs location access.',
    ),
    'contacts' => (
      key: 'NSContactsUsageDescription',
      value: 'TODO(chameleon): explain why this app needs contacts access.',
    ),
    // Notifications need no Info.plist usage-description key.
    'notification' => (key: '', value: ''),
    _ => throw ArgumentError('Unknown permission: $permission'),
  };
}

/// Maps a requested permission to the Android manifest permission(s)
/// `permission_handler` needs declared in `AndroidManifest.xml` — without
/// these, the OS rejects the runtime request before permission_handler ever
/// gets to show a prompt, the same silent-failure shape `_usageDescription`
/// exists to prevent on iOS. See permission_handler's own README for this
/// exact mapping.
List<String> _androidPermissions(String permission) {
  return switch (permission) {
    'camera' => const ['android.permission.CAMERA'],
    'microphone' => const ['android.permission.RECORD_AUDIO'],
    'photos' => const ['android.permission.READ_MEDIA_IMAGES'],
    'location' => const [
      'android.permission.ACCESS_FINE_LOCATION',
      'android.permission.ACCESS_COARSE_LOCATION',
    ],
    'notification' => const ['android.permission.POST_NOTIFICATIONS'],
    'contacts' => const [
      'android.permission.READ_CONTACTS',
      'android.permission.WRITE_CONTACTS',
    ],
    _ => throw ArgumentError('Unknown permission: $permission'),
  };
}

void run(HookContext context) {
  final name = context.vars['project_name'] as String;

  // Fail early and loudly — a bad package name surfaces as an
  // incomprehensible Gradle error forty seconds later.
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
    context.logger.err(
      '"$name" is not a valid Dart package name '
      '(snake_case, must start with a lowercase letter).',
    );
    throw Exception('invalid project_name');
  }
  if (_dartReservedWords.contains(name)) {
    context.logger.err('"$name" is a Dart reserved word.');
    throw Exception('reserved project_name');
  }

  // Derived vars so templates stay free of logic.
  context.vars['is_bloc'] = context.vars['state_management'] == 'bloc';

  final router = context.vars['router'] as String;
  context.vars['use_go_router'] = router == 'go_router';

  final permissions = (context.vars['permissions'] as List).cast<String>();
  context.vars['has_permissions'] = permissions.isNotEmpty;
  context.vars['permission_macros'] = permissions.map(_permissionMacro).toList();
  context.vars['usage_descriptions'] = [
    for (final permission in permissions)
      if (permission != 'notification')
        {
          'key': _usageDescription(permission).key,
          'value': _usageDescription(permission).value,
        },
  ];
  context.vars['android_permissions'] = [
    for (final permission in permissions) ..._androidPermissions(permission),
  ];
}
