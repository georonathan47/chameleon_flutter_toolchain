import 'dart:io';

import 'package:chameleon_cli/src/auditor.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'support/fake_process_runner.dart';

const _lsRemoteAllCurrent = '''
aaa\trefs/tags/chameleon_core-v0.2.0
bbb\trefs/tags/chameleon_core-v0.3.0
ccc\trefs/tags/chameleon_ui-v0.5.0
ddd\trefs/tags/chameleon_lints-v0.2.1
''';

const _checksAllPassing = '✓ no setState\n✓ no SnackBar\n';

const _checksOnlyTodo =
    '✓ no setState\n'
    'lib/core/di/core_module.dart:25:/// TODO(chameleon): wire auth\n'
    '✗ no leftover TODOs: Template placeholders must be filled in.\n';

void main() {
  group('Auditor', () {
    late Directory appRoot;

    void writePubspec({
      String coreRef = 'chameleon_core-v0.3.0',
      bool withLints = true,
    }) {
      String git(String package, String ref) =>
          '    git:\n'
          '      url: https://example.com/repo\n'
          '      path: packages/$package\n'
          '      ref: $ref\n';
      const lintsRef = 'chameleon_lints-v0.2.1';
      final lintsDependency = withLints
          ? '  chameleon_lints:\n${git('chameleon_lints', lintsRef)}'
          : '  test: ^1.0.0\n';
      File(p.join(appRoot.path, 'pubspec.yaml')).writeAsStringSync(
        'name: sample_app\n'
        'dependencies:\n'
        '  chameleon_core:\n${git('chameleon_core', coreRef)}'
        '  chameleon_ui:\n${git('chameleon_ui', 'chameleon_ui-v0.5.0')}'
        'dev_dependencies:\n'
        '$lintsDependency',
      );
    }

    void writeAnalysisOptions({bool withPlugin = true}) {
      File(p.join(appRoot.path, 'analysis_options.yaml')).writeAsStringSync(
        withPlugin
            ? 'analyzer:\n  plugins:\n    - custom_lint\n'
            : 'analyzer:\n  errors: {}\n',
      );
    }

    setUp(() {
      appRoot = Directory.systemTemp.createTempSync('chameleon_cli_audit_test');
      Directory(p.join(appRoot.path, 'tool')).createSync();
      File(p.join(appRoot.path, 'tool', 'checks.sh')).writeAsStringSync('');
      writePubspec();
      writeAnalysisOptions();
    });

    tearDown(() => appRoot.deleteSync(recursive: true));

    Auditor auditorWith({
      String lsRemote = _lsRemoteAllCurrent,
      int lsRemoteExit = 0,
      String checks = _checksAllPassing,
    }) => Auditor(
      repoUrl: 'https://example.com/repo',
      runner: FakeProcessRunner(
        onRun: (executable, args) {
          if (executable == 'git') {
            return ProcessResult(0, lsRemoteExit, lsRemote, 'ls-remote failed');
          }
          if (executable == 'bash') return ProcessResult(0, 0, checks, '');
          return null;
        },
      ),
    );

    List<AuditCheck> named(AuditReport report, String fragment) =>
        report.checks.where((c) => c.name.contains(fragment)).toList();

    test(
      'a fresh app is all-clear (the deliberate TODO is only a warning)',
      () async {
        final report = await auditorWith(
          checks: _checksOnlyTodo,
        ).audit(appRoot);

        expect(report.hasFailures, isFalse);
        expect(
          report.checks.where((c) => c.status == AuditStatus.warn),
          hasLength(1),
        );
      },
    );

    test('a stale chameleon_core ref fails that check specifically', () async {
      writePubspec(coreRef: 'chameleon_core-v0.2.0');

      final report = await auditorWith().audit(appRoot);

      final core = named(report, 'chameleon_core').single;
      expect(core.status, AuditStatus.fail);
      expect(core.detail, contains('chameleon_core-v0.3.0'));
      expect(
        report.checks.where((c) => c.status == AuditStatus.fail),
        hasLength(1),
      );
    });

    test('a ref that is not a release tag only warns', () async {
      writePubspec(coreRef: 'main');

      final report = await auditorWith().audit(appRoot);

      expect(named(report, 'chameleon_core').single.status, AuditStatus.warn);
      expect(report.hasFailures, isFalse);
    });

    test('an unreachable remote warns instead of failing', () async {
      final report = await auditorWith(lsRemoteExit: 128).audit(appRoot);

      expect(report.hasFailures, isFalse);
      expect(named(report, 'pinned ref').map((c) => c.status), [
        AuditStatus.warn,
        AuditStatus.warn,
        AuditStatus.warn,
      ]);
    });

    test('missing chameleon_lints dev_dependency fails', () async {
      writePubspec(withLints: false);

      final report = await auditorWith().audit(appRoot);

      expect(
        named(report, 'in dev_dependencies').single.status,
        AuditStatus.fail,
      );
    });

    test('custom_lint not enabled in analysis_options fails', () async {
      writeAnalysisOptions(withPlugin: false);

      final report = await auditorWith().audit(appRoot);

      expect(
        named(report, 'custom_lint enabled').single.status,
        AuditStatus.fail,
      );
    });

    test(
      'a tool/checks.sh guardrail failure is reported as a failure',
      () async {
        final report = await auditorWith(
          checks: '✗ no setState: Bloc/Cubit owns all state.\n',
        ).audit(appRoot);

        final guardrail = named(report, 'guardrails').single;
        expect(guardrail.status, AuditStatus.fail);
        expect(guardrail.detail, contains('no setState'));
      },
    );

    test('a missing tool/checks.sh fails', () async {
      File(p.join(appRoot.path, 'tool', 'checks.sh')).deleteSync();

      final report = await auditorWith().audit(appRoot);

      expect(named(report, 'guardrails').single.status, AuditStatus.fail);
    });
  });
}
