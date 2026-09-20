import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:chameleon_cli/src/commands/update_command.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:test/test.dart';

import '../support/fake_process_runner.dart';

FakeProcessRunner _runnerWithTag(String tag) => FakeProcessRunner(
  onRun: (executable, args) {
    if (executable == 'git' && args.contains('ls-remote')) {
      return ProcessResult(0, 0, 'abc123\trefs/tags/$tag\n', '');
    }
    return null;
  },
);

Future<int?> runUpdate(List<String> args, FakeProcessRunner runner) {
  final commandRunner = CommandRunner<int>('chameleon', 'test')
    ..addCommand(
      UpdateCommand(
        logger: Logger(level: Level.quiet),
        runner: runner,
      ),
    );
  return commandRunner.run(['update', ...args]);
}

void main() {
  group('UpdateCommand', () {
    test('defaults --repo-url to the real toolchain repo', () async {
      final runner = _runnerWithTag('chameleon_cli-v1.0.0');

      final exitCode = await runUpdate([], runner);

      expect(exitCode, equals(0));
      final lsRemoteCall = runner.calls.firstWhere(
        (call) => call.$1 == 'git' && call.$2.contains('ls-remote'),
      );
      expect(
        lsRemoteCall.$2,
        contains(
          'https://github.com/georonathan47/chameleon_flutter_toolchain',
        ),
      );
    });

    test('reports already up to date and does not reactivate', () async {
      final runner = _runnerWithTag('chameleon_cli-v0.1.0');

      final exitCode = await runUpdate([
        '--repo-url',
        'https://example.com/repo.git',
      ], runner);

      expect(exitCode, equals(0));
      expect(
        runner.calls.any(
          (call) => call.$1 == 'dart' && call.$2.contains('activate'),
        ),
        isFalse,
      );
    });

    test('dry-run reports a newer version without reactivating', () async {
      final runner = _runnerWithTag('chameleon_cli-v9.9.9');

      final exitCode = await runUpdate([
        '--repo-url',
        'https://example.com/repo.git',
        '--dry-run',
      ], runner);

      expect(exitCode, equals(0));
      expect(
        runner.calls.any(
          (call) => call.$1 == 'dart' && call.$2.contains('activate'),
        ),
        isFalse,
      );
    });

    test('reactivates via git when a newer tag exists', () async {
      final runner = _runnerWithTag('chameleon_cli-v9.9.9');

      final exitCode = await runUpdate([
        '--repo-url',
        'https://example.com/repo.git',
      ], runner);

      expect(exitCode, equals(0));
      final activateCall = runner.calls.firstWhere(
        (call) => call.$1 == 'dart' && call.$2.contains('activate'),
      );
      expect(
        activateCall.$2,
        containsAll([
          '--git-ref',
          'chameleon_cli-v9.9.9',
          '--git-path',
          'cli/chameleon_cli',
        ]),
      );
    });

    test('reports no matching tags without error', () async {
      final runner = FakeProcessRunner(
        onRun: (executable, args) {
          if (executable == 'git' && args.contains('ls-remote')) {
            return ProcessResult(
              0,
              0,
              'abc123\trefs/tags/unrelated-v1.0.0\n',
              '',
            );
          }
          return null;
        },
      );

      final exitCode = await runUpdate([
        '--repo-url',
        'https://example.com/repo.git',
      ], runner);

      expect(exitCode, equals(0));
    });
  });
}
