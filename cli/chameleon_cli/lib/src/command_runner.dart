import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import 'commands/doctor_command.dart';
import 'commands/firebase_command.dart';
import 'commands/flutter_command.dart';
import 'commands/update_command.dart';
import 'process_runner.dart';

/// Top-level `chameleon` command tree — `chameleon <category> <command>`, so
/// this binary can later grow `chameleon spring <...>` / `chameleon nest
/// <...>` without reshaping the `flutter` category.
class ChameleonCommandRunner extends CommandRunner<int> {
  ChameleonCommandRunner({Logger? logger, ProcessRunner? runner})
    : _logger = logger ?? Logger(),
      super('chameleon', 'Chameleon project scaffolding.') {
    addCommand(DoctorCommand(logger: _logger, runner: runner));
    addCommand(FirebaseCommand(logger: _logger, runner: runner));
    addCommand(FlutterCommand(logger: _logger, runner: runner));
    addCommand(UpdateCommand(logger: _logger, runner: runner));
  }

  final Logger _logger;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final result = await super.run(args);
      return result ?? ExitCode.success.code;
    } on UsageException catch (error) {
      _logger
        ..err(error.message)
        ..info('')
        ..info(error.usage);
      return ExitCode.usage.code;
    }
  }
}
