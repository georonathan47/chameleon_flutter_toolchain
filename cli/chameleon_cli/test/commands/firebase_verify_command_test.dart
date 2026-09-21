import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:chameleon_cli/src/commands/firebase_command.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:test/test.dart';

import '../support/fake_process_runner.dart';

void main() {
  group('FirebaseVerifyCommand', () {
    Future<int?> runVerify(List<String> args, {FakeProcessRunner? runner}) {
      final commandRunner = CommandRunner<int>('chameleon', 'test')
        ..addCommand(
          FirebaseCommand(
            logger: Logger(level: Level.quiet),
            runner: runner ?? FakeProcessRunner(),
          ),
        );
      return commandRunner.run(['firebase', 'verify', ...args]);
    }

    test('requires at least one project id', () async {
      final exitCode = await runVerify([]);
      expect(exitCode, equals(64));
    });

    test(
      'exits unavailable when firebase-tools is missing',
      () async {
        final exitCode = await runVerify(
          ['my-project'],
          runner: FakeProcessRunner(missing: {'firebase'}),
        );
        expect(exitCode, equals(69));
      },
    );

    test(
      'verifies a project id via firebase apps:list, no side effects',
      () async {
        final runner = FakeProcessRunner();

        final exitCode = await runVerify(
          ['chameleonapp-dev'],
          runner: runner,
        );

        expect(exitCode, equals(0));
        final calls = runner.calls.where(
          (call) => call.$1 == 'firebase' && call.$2.contains('apps:list'),
        );
        expect(calls, hasLength(1));
        expect(
          calls.single.$2,
          equals(['apps:list', '--project=chameleonapp-dev']),
        );
      },
    );

    test('verifies multiple project ids, one call each', () async {
      final runner = FakeProcessRunner();

      final exitCode = await runVerify([
        'chameleonapp-dev',
        'chameleonapp-stg',
      ], runner: runner);

      expect(exitCode, equals(0));
      final calls = runner.calls.where(
        (call) => call.$1 == 'firebase' && call.$2.contains('apps:list'),
      );
      expect(calls, hasLength(2));
      expect(
        calls.map((call) => call.$2.last),
        containsAll(<String>[
          '--project=chameleonapp-dev',
          '--project=chameleonapp-stg',
        ]),
      );
    });

    test(
      'reports failure for a project id firebase rejects, without '
      'aborting the rest',
      () async {
        final runner = FakeProcessRunner(
          onRun: (executable, args) {
            if (executable == 'firebase' && args.contains('--project=bad-id')) {
              return ProcessResult(0, 1, '', 'not found');
            }
            return null;
          },
        );

        final exitCode = await runVerify([
          'bad-id',
          'chameleonapp-dev',
        ], runner: runner);

        expect(exitCode, isNot(equals(0)));
        final calls = runner.calls.where(
          (call) => call.$1 == 'firebase' && call.$2.contains('apps:list'),
        );
        expect(
          calls,
          hasLength(2),
          reason: 'the second id should still be checked',
        );
      },
    );
  });
}
