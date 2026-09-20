import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../process_runner.dart';
import 'flutter_bloc_command.dart';
import 'flutter_create_command.dart';
import 'flutter_feature_command.dart';

/// Parent for every `chameleon flutter <...>` subcommand — kept as its own
/// category so a later `chameleon spring <...>` / `chameleon nest <...>` can
/// live in the same binary without reshaping this one.
class FlutterCommand extends Command<int> {
  FlutterCommand({required Logger logger, ProcessRunner? runner}) {
    addSubcommand(FlutterCreateCommand(logger: logger, runner: runner));
    addSubcommand(FlutterFeatureCommand(logger: logger, runner: runner));
    addSubcommand(FlutterBlocCommand(logger: logger, runner: runner));
  }

  @override
  String get name => 'flutter';

  @override
  String get description => 'Flutter project scaffolding.';
}
