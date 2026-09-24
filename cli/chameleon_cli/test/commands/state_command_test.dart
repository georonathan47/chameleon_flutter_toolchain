import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:chameleon_cli/src/commands/state_command.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../support/fake_process_runner.dart';

/// These tests exercise the command's own validation — invalid input, the
/// provenance-file check, the existing-feature guard, the state_management
/// default-resolution logic, and the doctor pre-check — all of which fail
/// (or resolve) before mason ever runs. The real pipeline (mason generate ->
/// build_runner -> analyze -> test, for bloc/cubit/provider/riverpod) is
/// verified by actually running `chameleon state` against a real generated
/// app and feature — see the toolchain repo's e2e/run_matrix.sh.
void main() {
  group('StateCommand', () {
    late Directory appRoot;

    void writeProvenance({String? stateManagement}) {
      final yaml = StringBuffer(
        'generated_with:\n  chameleon_app_brick: 1.0.0\n',
      );
      if (stateManagement != null) {
        yaml.writeln('  state_management: $stateManagement');
      }
      File(
        p.join(appRoot.path, '.chameleon', 'template.yaml'),
      ).writeAsStringSync(yaml.toString());
    }

    setUp(() {
      appRoot = Directory.systemTemp.createTempSync('chameleon_cli_state_test');
      File(
        p.join(appRoot.path, 'pubspec.yaml'),
      ).writeAsStringSync('name: sample_app\n');
      Directory(
        p.join(appRoot.path, '.chameleon'),
      ).createSync(recursive: true);
      writeProvenance();
      Directory(
        p.join(appRoot.path, 'lib', 'features', 'beneficiaries'),
      ).createSync(recursive: true);
    });

    tearDown(() {
      appRoot.deleteSync(recursive: true);
    });

    Future<int?> runState(
      List<String> args, {
      FakeProcessRunner? runner,
      Directory? cwd,
    }) {
      final commandRunner = CommandRunner<int>('chameleon', 'test')
        ..addCommand(
          StateCommand(
            logger: Logger(level: Level.quiet),
            runner: runner ?? FakeProcessRunner(),
          ),
        );
      final originalCwd = Directory.current;
      Directory.current = cwd ?? appRoot;
      return commandRunner.run(['state', ...args]).whenComplete(() {
        Directory.current = originalCwd;
      });
    }

    test('requires --feature', () async {
      final exitCode = await runState(['filters']);
      expect(exitCode, equals(64));
    });

    test('rejects a name that is not snake_case', () async {
      final exitCode = await runState([
        'NotSnakeCase',
        '--feature',
        'beneficiaries',
      ]);
      expect(exitCode, equals(64));
    });

    test('rejects an invalid --state value', () async {
      await expectLater(
        () => runState([
          'filters',
          '--feature',
          'beneficiaries',
          '--state',
          'mobx',
        ]),
        throwsA(isA<UsageException>()),
      );
    });

    test('rejects a project root with no .chameleon/template.yaml', () async {
      final isolated = Directory.systemTemp.createTempSync(
        'chameleon_cli_state_isolated_test',
      );
      addTearDown(() => isolated.deleteSync(recursive: true));

      final exitCode = await runState(
        ['filters', '--feature', 'beneficiaries'],
        cwd: isolated,
      );
      expect(exitCode, equals(64));
    });

    test('rejects a feature that does not exist', () async {
      final exitCode = await runState([
        'filters',
        '--feature',
        'does_not_exist',
      ]);
      expect(exitCode, equals(64));
    });

    test('rejects a bloc that already exists', () async {
      final existingStateDir = Directory(
        p.join(
          appRoot.path,
          'lib',
          'features',
          'beneficiaries',
          'presentation',
          'state',
        ),
      )..createSync(recursive: true);
      File(
        p.join(existingStateDir.path, 'filters_bloc.dart'),
      ).writeAsStringSync('// existing');

      final exitCode = await runState([
        'filters',
        '--feature',
        'beneficiaries',
      ]);
      expect(exitCode, equals(64));
    });

    test(
      'rejects an already-existing controller when the app defaults to '
      'provider',
      () async {
        writeProvenance(stateManagement: 'provider');
        final existingStateDir = Directory(
          p.join(
            appRoot.path,
            'lib',
            'features',
            'beneficiaries',
            'presentation',
            'state',
          ),
        )..createSync(recursive: true);
        File(
          p.join(existingStateDir.path, 'filters_controller.dart'),
        ).writeAsStringSync('// existing');

        final exitCode = await runState([
          'filters',
          '--feature',
          'beneficiaries',
        ]);
        expect(exitCode, equals(64));
      },
    );

    test(
      'an explicit --state overrides the app default when checking for an '
      'existing file',
      () async {
        // The app defaults to provider, but --state riverpod is passed
        // explicitly — only a pre-existing filters_provider.dart (not
        // filters_controller.dart) should block generation.
        writeProvenance(stateManagement: 'provider');
        final existingStateDir = Directory(
          p.join(
            appRoot.path,
            'lib',
            'features',
            'beneficiaries',
            'presentation',
            'state',
          ),
        )..createSync(recursive: true);
        File(
          p.join(existingStateDir.path, 'filters_controller.dart'),
        ).writeAsStringSync('// existing, but a different state_management');

        final exitCode = await runState(
          ['filters', '--feature', 'beneficiaries', '--state', 'riverpod'],
          runner: FakeProcessRunner(missing: {'git'}),
        );
        // Doesn't hit the "already exists" guard (64) — proceeds past it to
        // the doctor check, which fails for a different reason (69).
        expect(exitCode, equals(69));
      },
    );

    test('exits unavailable when the toolchain is not usable', () async {
      final exitCode = await runState(
        ['filters', '--feature', 'beneficiaries'],
        runner: FakeProcessRunner(missing: {'git'}),
      );
      expect(exitCode, equals(69));
    });
  });
}
