import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../process_runner.dart';
import 'firebase_verify_command.dart';

/// Parent for every `chameleon firebase <...>` subcommand — `verify` is the
/// only one today, but a category keeps room for more without a breaking
/// rename (unlike `create`/`feature`/`bloc`, which are top-level commands).
class FirebaseCommand extends Command<int> {
  FirebaseCommand({required Logger logger, ProcessRunner? runner}) {
    addSubcommand(FirebaseVerifyCommand(logger: logger, runner: runner));
  }

  @override
  String get name => 'firebase';

  @override
  String get description => 'Firebase project checks.';
}
