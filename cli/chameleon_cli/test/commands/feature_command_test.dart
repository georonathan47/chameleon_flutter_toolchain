import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:chameleon_cli/src/commands/feature_command.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../support/fake_process_runner.dart';

/// These tests exercise the command's own validation — invalid input, the
/// provenance-file check, the existing-feature guard, the state_management
/// default-resolution logic, and the doctor pre-check — all of which fail
/// (or resolve) before mason ever runs. The real pipeline (mason generate ->
/// build_runner -> analyze -> test, for bloc/provider/riverpod) is verified
/// by actually running `chameleon feature` against a real generated app —
/// see the toolchain repo's e2e/run_matrix.sh.
void main() {
  group('FeatureCommand', () {
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
      appRoot = Directory.systemTemp.createTempSync(
        'chameleon_cli_feature_test',
      );
      File(
        p.join(appRoot.path, 'pubspec.yaml'),
      ).writeAsStringSync('name: sample_app\n');
      Directory(
        p.join(appRoot.path, '.chameleon'),
      ).createSync(recursive: true);
      writeProvenance();
    });

    tearDown(() {
      appRoot.deleteSync(recursive: true);
    });

    Future<int?> runFeature(
      List<String> args, {
      FakeProcessRunner? runner,
      Directory? cwd,
    }) {
      final commandRunner = CommandRunner<int>('chameleon', 'test')
        ..addCommand(
          FeatureCommand(
            logger: Logger(level: Level.quiet),
            runner: runner ?? FakeProcessRunner(),
          ),
        );
      final originalCwd = Directory.current;
      Directory.current = cwd ?? appRoot;
      return commandRunner.run(['feature', ...args]).whenComplete(() {
        Directory.current = originalCwd;
      });
    }

    test('requires a feature name', () async {
      final exitCode = await runFeature([]);
      expect(exitCode, equals(64));
    });

    test('rejects a feature name that is not snake_case', () async {
      final exitCode = await runFeature(['NotSnakeCase']);
      expect(exitCode, equals(64));
    });

    test('rejects a project root with no .chameleon/template.yaml', () async {
      final isolated = Directory.systemTemp.createTempSync(
        'chameleon_cli_feature_isolated_test',
      );
      addTearDown(() => isolated.deleteSync(recursive: true));

      final exitCode = await runFeature(['beneficiaries'], cwd: isolated);
      expect(exitCode, equals(64));
    });

    test('rejects a feature that already exists', () async {
      Directory(
        p.join(appRoot.path, 'lib', 'features', 'beneficiaries'),
      ).createSync(recursive: true);

      final exitCode = await runFeature(['beneficiaries']);
      expect(exitCode, equals(64));
    });

    test('rejects an invalid --state value', () async {
      await expectLater(
        () => runFeature(['beneficiaries', '--state', 'mobx']),
        throwsA(isA<UsageException>()),
      );
    });

    test('exits unavailable when the toolchain is not usable', () async {
      final exitCode = await runFeature(
        ['beneficiaries'],
        runner: FakeProcessRunner(missing: {'git'}),
      );
      expect(exitCode, equals(69));
    });

    test(
      "proceeds past validation with the app's own state_management "
      'default when --state is not passed',
      () async {
        writeProvenance(stateManagement: 'riverpod');

        final exitCode = await runFeature(
          ['beneficiaries'],
          runner: FakeProcessRunner(missing: {'git'}),
        );
        // Doesn't fail on state_management resolution — proceeds to the
        // doctor check, which fails for an unrelated reason (69), not the
        // usage errors (64) that guard the earlier validation steps.
        expect(exitCode, equals(69));
      },
    );

    test(
      'proceeds past validation with an explicit --state override',
      () async {
        writeProvenance(stateManagement: 'bloc');

        final exitCode = await runFeature(
          ['beneficiaries', '--state', 'riverpod'],
          runner: FakeProcessRunner(missing: {'git'}),
        );
        expect(exitCode, equals(69));
      },
    );
  });
}
