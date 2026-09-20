import 'dart:io';

import 'package:chameleon_cli/src/command_runner.dart';

Future<void> main(List<String> args) async {
  final exitCode = await ChameleonCommandRunner().run(args);
  exit(exitCode);
}
