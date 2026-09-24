import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;

import '../auditor.dart';
import '../process_runner.dart';

/// `chameleon audit` — reports whether an existing generated app has drifted
/// from the toolchain's current guardrails (stale pinned refs, lints not
/// wired, `tool/checks.sh` failures). Report-only. Distinct from `chameleon
/// doctor`, which checks the machine's toolchain, not an app.
class AuditCommand extends Command<int> {
  AuditCommand({required Logger logger, ProcessRunner? runner})
    : _logger = logger,
      _runner = runner ?? const SystemProcessRunner() {
    argParser.addOption(
      'repo-url',
      defaultsTo: _defaultRepoUrl,
      help:
          'Git URL of the chameleon_flutter_toolchain repo to compare '
          'pinned refs against.',
    );
  }

  static const _defaultRepoUrl =
      'https://github.com/georonathan47/chameleon_flutter_toolchain';

  final Logger _logger;
  final ProcessRunner _runner;

  @override
  String get name => 'audit';

  @override
  String get description =>
      "Check a generated app for drift from the toolchain's current "
      'guardrails.';

  @override
  Future<int> run() async {
    final appRoot = Directory.current;
    final provenance = File(
      p.join(appRoot.path, '.chameleon', 'template.yaml'),
    );
    if (!provenance.existsSync()) {
      _logger.err(
        'No .chameleon/template.yaml found in ${appRoot.path}.\n'
        'Run `chameleon audit` from the root of a Chameleon app generated '
        'by `chameleon create`.',
      );
      return ExitCode.usage.code;
    }

    final auditor = Auditor(
      runner: _runner,
      repoUrl: argResults!['repo-url'] as String,
    );
    final progress = _logger.progress('Auditing ${p.basename(appRoot.path)}');
    final report = await auditor.audit(appRoot);
    progress.complete();

    _logger.info('${styleBold.wrap('Chameleon app audit')}');
    for (final check in report.checks) {
      _logger.info('  ${_line(check)}');
    }

    if (report.hasFailures) {
      _logger
        ..info('')
        ..err('Drift found — see docs/audit.md for how to fix each check.');
      return ExitCode.software.code;
    }

    _logger
      ..info('')
      ..success('No drift found.');
    return ExitCode.success.code;
  }

  String _line(AuditCheck check) {
    final symbol = switch (check.status) {
      AuditStatus.pass => green.wrap('✓'),
      AuditStatus.warn => yellow.wrap('⚠'),
      AuditStatus.fail => red.wrap('✗'),
    };
    final detail = check.detail != null ? '  (${check.detail})' : '';
    return '$symbol ${check.name}$detail';
  }
}
