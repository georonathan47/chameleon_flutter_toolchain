import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:chameleon_cli/src/commands/create_command.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../support/fake_process_runner.dart';

/// These tests exercise the command's own validation — invalid input and
/// the doctor pre-check — all of which fail before mason ever runs, so no
/// real brick generation happens here. The real end-to-end pipeline is
/// verified by actually running `chameleon create` (see the
/// toolchain repo's tasks/todo.md), the same way the brick itself was
/// verified beyond a structural check.
void main() {
  group('CreateCommand', () {
    late Directory workspace;

    setUp(() {
      workspace = Directory.systemTemp.createTempSync(
        'chameleon_cli_create_test',
      );
    });

    tearDown(() {
      workspace.deleteSync(recursive: true);
    });

    Future<int?> runCreate(
      List<String> args, {
      FakeProcessRunner? runner,
    }) {
      final commandRunner = CommandRunner<int>('chameleon', 'test')
        ..addCommand(
          CreateCommand(
            logger: Logger(level: Level.quiet),
            runner: runner ?? FakeProcessRunner(),
          ),
        );
      return commandRunner.run(['create', ...args]);
    }

    test('rejects a project name that is not snake_case', () async {
      final exitCode = await runCreate([
        'NotSnakeCase',
        '-o',
        workspace.path,
      ]);
      expect(exitCode, equals(64));
    });

    test('requires a project name', () async {
      final exitCode = await runCreate(['-o', workspace.path]);
      expect(exitCode, equals(64));
    });

    test(
      'rejects an output directory that already exists and is not empty',
      () async {
        final existing = Directory(p.join(workspace.path, 'sample_app'))
          ..createSync();
        File(p.join(existing.path, 'marker.txt')).writeAsStringSync('x');

        final exitCode = await runCreate(['sample_app', '-o', workspace.path]);
        expect(exitCode, equals(64));
      },
    );

    test('exits unavailable when the toolchain is not usable', () async {
      final exitCode = await runCreate(
        ['sample_app', '-o', workspace.path],
        runner: FakeProcessRunner(missing: {'git'}),
      );
      expect(exitCode, equals(69));
    });
  });
}
