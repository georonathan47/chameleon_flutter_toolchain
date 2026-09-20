import 'dart:io';

import 'package:chameleon_cli/src/doctor.dart';
import 'package:test/test.dart';

import 'support/fake_process_runner.dart';

void main() {
  group('Doctor', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync(
        'chameleon_cli_doctor_test',
      );
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('is usable when every required tool is present', () async {
      final doctor = Doctor(runner: FakeProcessRunner());
      final report = await doctor.check(directory: tempDir.path);

      expect(report.isUsable, isTrue);
      expect(report.useFvm, isFalse);
      expect(report.hasVeryGoodCli, isTrue);
    });

    test('stays usable when only warning-only tools are missing', () async {
      final doctor = Doctor(
        runner: FakeProcessRunner(missing: {'very_good', 'pod'}),
      );
      final report = await doctor.check(directory: tempDir.path);

      expect(report.isUsable, isTrue);
      expect(report.hasVeryGoodCli, isFalse);
    });

    test('is not usable when a required tool is missing', () async {
      final doctor = Doctor(runner: FakeProcessRunner(missing: {'git'}));
      final report = await doctor.check(directory: tempDir.path);

      expect(report.isUsable, isFalse);
    });

    test('is not usable when a required tool exits non-zero', () async {
      final doctor = Doctor(
        runner: FakeProcessRunner(exitCodes: {'flutter': 1}),
      );
      final report = await doctor.check(directory: tempDir.path);

      expect(report.isUsable, isFalse);
    });

    test('detects fvm via a .fvmrc in the checked directory', () async {
      File(
        '${tempDir.path}/.fvmrc',
      ).writeAsStringSync('{"flutter": "3.44.0"}');

      final doctor = Doctor(runner: FakeProcessRunner());
      final report = await doctor.check(directory: tempDir.path);

      expect(report.useFvm, isTrue);
    });
  });
}
