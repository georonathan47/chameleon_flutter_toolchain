import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:chameleon_cli/src/commands/audit_command.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../support/fake_process_runner.dart';

void main() {
  group('AuditCommand', () {
    late Directory appRoot;

    setUp(() {
      appRoot = Directory.systemTemp.createTempSync('chameleon_cli_audit_cmd');
    });

    tearDown(() => appRoot.deleteSync(recursive: true));

    Future<int?> runAudit(FakeProcessRunner runner) {
      final commandRunner = CommandRunner<int>('chameleon', 'test')
        ..addCommand(
          AuditCommand(
            logger: Logger(level: Level.quiet),
            runner: runner,
          ),
        );
      final originalCwd = Directory.current;
      Directory.current = appRoot;
      return commandRunner.run(['audit']).whenComplete(() {
        Directory.current = originalCwd;
      });
    }

    test('rejects a directory with no .chameleon/template.yaml', () async {
      expect(await runAudit(FakeProcessRunner()), 64);
    });

    test('exits non-zero when the audit finds drift', () async {
      Directory(p.join(appRoot.path, '.chameleon')).createSync();
      File(
        p.join(appRoot.path, '.chameleon', 'template.yaml'),
      ).writeAsStringSync('generated_with:\n  chameleon_app_brick: 1.0.0\n');
      // No pubspec.yaml/analysis_options.yaml/tool/checks.sh at all — every
      // structural check fails.
      expect(await runAudit(FakeProcessRunner()), 70);
    });
  });
}
