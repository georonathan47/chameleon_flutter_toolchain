import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../doctor.dart';
import '../process_runner.dart';

class DoctorCommand extends Command<int> {
  DoctorCommand({required Logger logger, ProcessRunner? runner})
    : _logger = logger,
      _doctor = Doctor(runner: runner ?? const SystemProcessRunner());

  final Logger _logger;
  final Doctor _doctor;

  @override
  String get name => 'doctor';

  @override
  String get description => 'Check the Chameleon Flutter toolchain.';

  @override
  Future<int> run() async {
    final report = await _doctor.check();

    _logger.info('${styleBold.wrap('Chameleon toolchain')}');
    for (final check in report.checks) {
      _logger.info('  ${_line(check)}');
    }
    if (report.useFvm) {
      _logger.info('  ${lightBlue.wrap('using fvm (.fvmrc found)')}');
    }

    if (!report.isUsable) {
      _logger
        ..info('')
        ..err(
          'One or more required tools are missing. Install them and re-run.',
        );
      return ExitCode.unavailable.code;
    }

    _logger
      ..info('')
      ..success('Toolchain OK.');
    return ExitCode.success.code;
  }

  String _line(ToolCheck check) {
    if (check.installed) {
      final detail = check.detail != null ? '  (${check.detail})' : '';
      return '${green.wrap('✓')} ${check.name}$detail';
    }
    final symbol = check.isWarningOnly ? yellow.wrap('⚠') : red.wrap('✗');
    return '$symbol ${check.name} not found';
  }
}
