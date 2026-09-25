import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import 'commands/audit_command.dart';
import 'commands/create_command.dart';
import 'commands/doctor_command.dart';
import 'commands/feature_command.dart';
import 'commands/firebase_command.dart';
import 'commands/state_command.dart';
import 'commands/update_command.dart';
import 'process_runner.dart';

/// Top-level `chameleon` command tree — `chameleon <command>`, flat rather
/// than categorized: `create`/`feature`/`state` used to live under a
/// `chameleon flutter <...>` category, but with only one framework this
/// binary scaffolds for, the extra nesting was just friction.
class ChameleonCommandRunner extends CommandRunner<int> {
  ChameleonCommandRunner({Logger? logger, ProcessRunner? runner})
    : _logger = logger ?? Logger(),
      super('chameleon', 'Chameleon project scaffolding.') {
    addCommand(AuditCommand(logger: _logger, runner: runner));
    addCommand(CreateCommand(logger: _logger, runner: runner));
    addCommand(DoctorCommand(logger: _logger, runner: runner));
    addCommand(FeatureCommand(logger: _logger, runner: runner));
    addCommand(FirebaseCommand(logger: _logger, runner: runner));
    addCommand(StateCommand(logger: _logger, runner: runner));
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
