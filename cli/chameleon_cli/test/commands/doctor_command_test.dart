import 'package:args/command_runner.dart';
import 'package:chameleon_cli/src/commands/doctor_command.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:test/test.dart';

import '../support/fake_process_runner.dart';

void main() {
  group('DoctorCommand', () {
    test('exits 0 when the toolchain is usable', () async {
      final runner = CommandRunner<int>('chameleon', 'test')
        ..addCommand(
          DoctorCommand(
            logger: Logger(level: Level.quiet),
            runner: FakeProcessRunner(),
          ),
        );

      final exitCode = await runner.run(['doctor']);

      expect(exitCode, equals(0));
    });

    test('exits non-zero when a required tool is missing', () async {
      final runner = CommandRunner<int>('chameleon', 'test')
        ..addCommand(
          DoctorCommand(
            logger: Logger(level: Level.quiet),
            runner: FakeProcessRunner(missing: {'git'}),
          ),
        );

      final exitCode = await runner.run(['doctor']);

      expect(exitCode, isNot(equals(0)));
    });
  });
}
