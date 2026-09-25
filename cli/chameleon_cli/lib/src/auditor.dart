import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import 'process_runner.dart';
import 'updater.dart';

enum AuditStatus { pass, warn, fail }

class AuditCheck {
  const AuditCheck(this.name, this.status, [this.detail]);

  final String name;
  final AuditStatus status;
  final String? detail;
}

class AuditReport {
  const AuditReport(this.checks);

  final List<AuditCheck> checks;

  bool get hasFailures =>
      checks.any((check) => check.status == AuditStatus.fail);
}

/// Checks whether an existing generated app has drifted from the toolchain's
/// current guardrails. Report-only — never modifies the app.
///
/// A remote that can't be reached downgrades the tag comparison to a
/// warning instead of a failure: an audit that goes red because GitHub is
/// down would be useless as a CI gate.
class Auditor {
  Auditor({required this.runner, required this.repoUrl})
    : _updater = Updater(runner: runner);

  static const _pinnedPackages = [
    'chameleon_core',
    'chameleon_ui',
    'chameleon_lints',
  ];

  // `tool/checks.sh` prints this one on every freshly generated app by
  // design (core_module.dart ships a TODO(chameleon) until a real backend
  // contract is wired) — see e2e/run_matrix.sh's header comment.
  static const _expectedLeftoverTodoPrefix = '✗ no leftover TODOs';

  final ProcessRunner runner;
  final String repoUrl;
  final Updater _updater;

  Future<AuditReport> audit(Directory appRoot) async {
    final pubspec = _loadYamlMap(File(p.join(appRoot.path, 'pubspec.yaml')));

    return AuditReport([
      for (final package in _pinnedPackages)
        await _checkPinnedRef(package, pubspec),
      _checkLintsDependency(pubspec),
      _checkLintsPlugin(appRoot),
      ...await _checkGuardrails(appRoot),
    ]);
  }

  Future<AuditCheck> _checkPinnedRef(String package, YamlMap? pubspec) async {
    final name = '$package pinned ref';
    final ref = _gitRef(pubspec, package);
    if (ref == null) {
      return AuditCheck(
        name,
        _dependency(pubspec, package) == null
            ? AuditStatus.fail
            : AuditStatus.warn,
        _dependency(pubspec, package) == null
            ? 'not a dependency in pubspec.yaml'
            : 'not pinned to a git ref',
      );
    }

    final prefix = '$package-v';
    final Version pinned;
    try {
      if (!ref.startsWith(prefix)) throw const FormatException();
      pinned = Version.parse(ref.substring(prefix.length));
    } on FormatException {
      return AuditCheck(
        name,
        AuditStatus.warn,
        '"$ref" is not a release tag, so it can\'t be compared to the '
        'latest release',
      );
    }

    final Version? latest;
    try {
      latest = await _updater.latestTag(repoUrl, prefix);
    } on Object catch (error) {
      return AuditCheck(
        name,
        AuditStatus.warn,
        'skipped — could not reach $repoUrl ($error)',
      );
    }
    if (latest == null) {
      return AuditCheck(name, AuditStatus.warn, 'no "$prefix*" tags found');
    }
    if (pinned < latest) {
      return AuditCheck(
        name,
        AuditStatus.fail,
        'pinned to $ref, latest is $prefix$latest',
      );
    }
    return AuditCheck(name, AuditStatus.pass, ref);
  }

  AuditCheck _checkLintsDependency(YamlMap? pubspec) {
    const name = 'chameleon_lints in dev_dependencies';
    final devDependencies = pubspec?['dev_dependencies'];
    final present =
        devDependencies is YamlMap &&
        devDependencies.containsKey('chameleon_lints');
    return present
        ? const AuditCheck(name, AuditStatus.pass)
        : const AuditCheck(name, AuditStatus.fail, 'missing from pubspec.yaml');
  }

  AuditCheck _checkLintsPlugin(Directory appRoot) {
    const name = 'custom_lint enabled in analysis_options.yaml';
    final analysisOptions = _loadYamlMap(
      File(p.join(appRoot.path, 'analysis_options.yaml')),
    );
    final analyzer = analysisOptions?['analyzer'];
    final plugins = analyzer is YamlMap ? analyzer['plugins'] : null;
    final enabled = plugins is YamlList && plugins.contains('custom_lint');
    return enabled
        ? const AuditCheck(name, AuditStatus.pass)
        : const AuditCheck(
            name,
            AuditStatus.fail,
            'analyzer.plugins does not list custom_lint, so '
            "chameleon_lints' rules never run",
          );
  }

  Future<List<AuditCheck>> _checkGuardrails(Directory appRoot) async {
    const name = 'guardrails (tool/checks.sh)';
    if (!File(p.join(appRoot.path, 'tool', 'checks.sh')).existsSync()) {
      return const [
        AuditCheck(name, AuditStatus.fail, 'tool/checks.sh is missing'),
      ];
    }

    final ProcessResult result;
    try {
      result = await runner.run(
        'bash',
        ['tool/checks.sh'],
        workingDirectory: appRoot.path,
      );
    } on ProcessException catch (error) {
      return [AuditCheck(name, AuditStatus.fail, 'could not run: $error')];
    }

    // The script's exit code can't be trusted (it's non-zero on every fresh
    // app because of the deliberate TODO), so its `✗` lines are the signal.
    final failures = '${result.stdout}'
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.startsWith('✗'))
        .toList();

    if (failures.isEmpty) {
      return result.exitCode == 0
          ? const [AuditCheck(name, AuditStatus.pass)]
          : [
              AuditCheck(
                name,
                AuditStatus.fail,
                'tool/checks.sh exited ${result.exitCode}: '
                '${'${result.stderr}'.trim()}',
              ),
            ];
    }

    return [
      for (final line in failures)
        AuditCheck(
          name,
          line.startsWith(_expectedLeftoverTodoPrefix)
              ? AuditStatus.warn
              : AuditStatus.fail,
          line.substring(1).trim(),
        ),
    ];
  }

  Object? _dependency(YamlMap? pubspec, String package) {
    for (final section in const ['dependencies', 'dev_dependencies']) {
      final dependencies = pubspec?[section];
      if (dependencies is YamlMap && dependencies.containsKey(package)) {
        return dependencies[package];
      }
    }
    return null;
  }

  String? _gitRef(YamlMap? pubspec, String package) {
    final dependency = _dependency(pubspec, package);
    final git = dependency is YamlMap ? dependency['git'] : null;
    final ref = git is YamlMap ? git['ref'] : null;
    return ref is String ? ref : null;
  }

  YamlMap? _loadYamlMap(File file) {
    if (!file.existsSync()) return null;
    try {
      final doc = loadYaml(file.readAsStringSync());
      return doc is YamlMap ? doc : null;
    } on YamlException {
      return null;
    }
  }
}
