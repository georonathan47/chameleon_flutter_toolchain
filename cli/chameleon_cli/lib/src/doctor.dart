import 'dart:io';

import 'package:path/path.dart' as path;

import 'process_runner.dart';

/// One toolchain dependency's status.
class ToolCheck {
  const ToolCheck({
    required this.name,
    required this.installed,
    this.detail,
    this.isWarningOnly = false,
  });

  final String name;
  final bool installed;
  final String? detail;

  /// If true, a missing tool is reported but [DoctorReport.isUsable] stays
  /// true anyway.
  final bool isWarningOnly;
}

class DoctorReport {
  const DoctorReport({
    required this.checks,
    required this.useFvm,
    required this.hasVeryGoodCli,
    required this.hasFirebaseTools,
    required this.hasXcode,
  });

  final List<ToolCheck> checks;

  /// Whether a `.fvmrc` was found in the directory `doctor` was run from —
  /// callers should prefer `fvm flutter`/`fvm dart` over the bare commands
  /// when this is true.
  final bool useFvm;
  final bool hasVeryGoodCli;

  /// Whether `firebase` (firebase-tools) is installed — required by
  /// `chameleon firebase verify`. Not auto-installed: it's an npm package,
  /// not a Dart pub package, and needs `firebase login` regardless of how
  /// it's installed.
  final bool hasFirebaseTools;

  /// Whether `xcodebuild` (Xcode) is installed — macOS/iOS builds resolve
  /// their native dependencies through it via Swift Package Manager
  /// (Flutter's default since 3.44, this toolchain's pinned version), so an
  /// Xcode-version mismatch is now a first-class build concern distinct
  /// from CocoaPods itself. Warning-only: irrelevant to Android-only
  /// development, and not installable by this CLI either way.
  final bool hasXcode;

  /// False if any non-warning check failed — `create` refuses to start.
  bool get isUsable =>
      checks.where((check) => !check.isWarningOnly).every((c) => c.installed);
}

/// Verifies the tools `chameleon create` shells out to are present,
/// so a missing tool fails here with a plain message instead of surfacing
/// as an opaque error partway through generation.
///
/// Deliberately does not check Azure DevOps reachability or git auth —
/// there is no toolchain remote to check against yet (see the toolchain
/// repo's README, Phase 6). Once one exists, this is the place to add
/// `git ls-remote` and a Git Credential Manager check.
class Doctor {
  Doctor({required this.runner});

  final ProcessRunner runner;

  Future<DoctorReport> check({String? directory}) async {
    final cwd = directory ?? Directory.current.path;
    final useFvm = File(path.join(cwd, '.fvmrc')).existsSync();
    final flutterExecutable = useFvm ? 'fvm' : 'flutter';
    final flutterArgs = useFvm ? ['flutter', '--version'] : ['--version'];
    final dartExecutable = useFvm ? 'fvm' : 'dart';
    final dartArgs = useFvm ? ['dart', '--version'] : ['--version'];

    final flutter = await _versionCheck(
      'Flutter',
      flutterExecutable,
      flutterArgs,
    );
    final dart = await _versionCheck('Dart', dartExecutable, dartArgs);
    final git = await _versionCheck('git', 'git', ['--version']);
    final veryGood = await _versionCheck(
      'very_good_cli',
      'very_good',
      ['--version'],
      isWarningOnly: true,
    );
    final cocoapods = await _versionCheck(
      'CocoaPods',
      'pod',
      ['--version'],
      isWarningOnly: true,
    );
    final xcode = await _versionCheck(
      'Xcode',
      'xcodebuild',
      ['-version'],
      isWarningOnly: true,
    );
    final firebaseTools = await _versionCheck(
      'firebase-tools',
      'firebase',
      ['--version'],
      isWarningOnly: true,
    );

    return DoctorReport(
      checks: [flutter, dart, git, veryGood, cocoapods, xcode, firebaseTools],
      useFvm: useFvm,
      hasVeryGoodCli: veryGood.installed,
      hasFirebaseTools: firebaseTools.installed,
      hasXcode: xcode.installed,
    );
  }

  Future<ToolCheck> _versionCheck(
    String name,
    String executable,
    List<String> args, {
    bool isWarningOnly = false,
  }) async {
    try {
      final result = await runner.run(executable, args);
      if (result.exitCode != 0) {
        return ToolCheck(
          name: name,
          installed: false,
          isWarningOnly: isWarningOnly,
        );
      }
      final output = '${result.stdout}'.trim().split('\n').first;
      return ToolCheck(
        name: name,
        installed: true,
        detail: output,
        isWarningOnly: isWarningOnly,
      );
    } on ProcessException {
      return ToolCheck(
        name: name,
        installed: false,
        isWarningOnly: isWarningOnly,
      );
    }
  }
}
