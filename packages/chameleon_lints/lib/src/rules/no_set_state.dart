import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Bans `setState` — see this project's `tasks/lessons.md`: every piece of
/// state, including small widget-local UI state, belongs in a Cubit or
/// Bloc, driven with `BlocBuilder`/`BlocSelector`/`BlocConsumer`.
class NoSetState extends DartLintRule {
  const NoSetState() : super(code: _code);

  static const LintCode _code = LintCode(
    name: 'chameleon_no_set_state',
    problemMessage: 'setState is banned — state belongs in a Cubit or Bloc.',
    correctionMessage:
        'Move this state into a Cubit and rebuild with '
        'BlocBuilder/BlocSelector/BlocConsumer.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'setState') return;
      // A bare call — `setState(() {...})` — not `widget.setState(...)` or
      // some other receiver's method that merely happens to share the name.
      if (node.target != null) return;
      reporter.atNode(node, _code);
    });
  }
}
