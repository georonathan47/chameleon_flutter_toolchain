import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Bans raw `print`/`debugPrint`: an app's output goes through the logging
/// service (`ChameleonLogger` in `chameleon_core`), which writes user events
/// to a capped log file, reports to crash reporting, and only prints to the
/// console in non-prod flavors. A stray `print` bypasses all of that and
/// ships to production consoles.
///
/// Matches a bare call (`print(...)`, not `logger.print(...)`) and skips one
/// that resolves to a user-defined function of the same name — only
/// `dart:core`'s `print` and Flutter's `debugPrint` are the banned ones. An
/// unresolved name (an analysis context without Flutter) is flagged by name.
/// The logging service's own implementation is exempt by file name.
class NoPrint extends DartLintRule {
  const NoPrint() : super(code: _code);

  static const LintCode _code = LintCode(
    name: 'chameleon_no_print',
    problemMessage:
        'print/debugPrint bypass the logging service — output belongs in '
        'ChameleonLogger.',
    correctionMessage:
        'Log through ChameleonLogger (chameleon_core) instead: it writes to '
        'the capped log file and reports to crash reporting, and only '
        'prints to the console in non-prod flavors.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  static const _bannedNames = {'print', 'debugPrint'};

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (resolver.path.endsWith('logging_service.dart')) return;

    context.registry.addMethodInvocation((node) {
      if (!_bannedNames.contains(node.methodName.name)) return;
      if (node.target != null) return;

      final libraryUri = node.methodName.element?.library?.uri.toString();
      if (libraryUri != null &&
          !libraryUri.startsWith('dart:core') &&
          !libraryUri.startsWith('package:flutter/')) {
        return;
      }
      reporter.atNode(node, _code);
    });
  }
}
