import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:chameleon_cli/src/commands/bloc_command.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../support/fake_process_runner.dart';

/// These tests exercise the command's own validation — invalid input, the
/// provenance-file check, the existing-feature guard, and the doctor
/// pre-check — all of which fail before mason ever runs. The real pipeline
/// (mason generate -> build_runner -> analyze -> test, for both the Bloc
/// and Cubit code paths) is verified by actually running
/// `chameleon bloc` against a real generated app and feature — see
/// the toolchain repo's tasks/todo.md.
void main() {
  group('BlocCommand', () {
    late Directory appRoot;

    setUp(() {
      appRoot = Directory.systemTemp.createTempSync('chameleon_cli_bloc_test');
      File(
        p.join(appRoot.path, 'pubspec.yaml'),
      ).writeAsStringSync('name: sample_app\n');
      Directory(
        p.join(appRoot.path, '.chameleon'),
      ).createSync(recursive: true);
      File(
        p.join(appRoot.path, '.chameleon', 'template.yaml'),
      ).writeAsStringSync('generated_with:\n  chameleon_app_brick: 1.0.0\n');
      Directory(
        p.join(appRoot.path, 'lib', 'features', 'beneficiaries'),
      ).createSync(recursive: true);
    });

    tearDown(() {
      appRoot.deleteSync(recursive: true);
    });

    Future<int?> runBloc(
      List<String> args, {
      FakeProcessRunner? runner,
      Directory? cwd,
    }) {
      final commandRunner = CommandRunner<int>('chameleon', 'test')
        ..addCommand(
          BlocCommand(
            logger: Logger(level: Level.quiet),
            runner: runner ?? FakeProcessRunner(),
          ),
        );
      final originalCwd = Directory.current;
      Directory.current = cwd ?? appRoot;
      return commandRunner.run(['bloc', ...args]).whenComplete(() {
        Directory.current = originalCwd;
      });
    }

    test('requires --feature', () async {
      final exitCode = await runBloc(['filters']);
      expect(exitCode, equals(64));
    });

    test('rejects a bloc name that is not snake_case', () async {
      final exitCode = await runBloc([
        'NotSnakeCase',
        '--feature',
        'beneficiaries',
      ]);
      expect(exitCode, equals(64));
    });

    test('rejects a project root with no .chameleon/template.yaml', () async {
      final isolated = Directory.systemTemp.createTempSync(
        'chameleon_cli_bloc_isolated_test',
      );
      addTearDown(() => isolated.deleteSync(recursive: true));

      final exitCode = await runBloc(
        ['filters', '--feature', 'beneficiaries'],
        cwd: isolated,
      );
      expect(exitCode, equals(64));
    });

    test('rejects a feature that does not exist', () async {
      final exitCode = await runBloc([
        'filters',
        '--feature',
        'does_not_exist',
      ]);
      expect(exitCode, equals(64));
    });

    test('rejects a bloc that already exists', () async {
      final existingBlocDir = Directory(
        p.join(
          appRoot.path,
          'lib',
          'features',
          'beneficiaries',
          'presentation',
          'bloc',
        ),
      )..createSync(recursive: true);
      File(
        p.join(existingBlocDir.path, 'filters_bloc.dart'),
      ).writeAsStringSync('// existing');

      final exitCode = await runBloc(['filters', '--feature', 'beneficiaries']);
      expect(exitCode, equals(64));
    });

    test('exits unavailable when the toolchain is not usable', () async {
      final exitCode = await runBloc(
        ['filters', '--feature', 'beneficiaries'],
        runner: FakeProcessRunner(missing: {'git'}),
      );
      expect(exitCode, equals(69));
    });
  });
}
