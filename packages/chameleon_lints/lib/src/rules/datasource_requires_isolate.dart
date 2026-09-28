import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// A datasource method must route its work through an isolate so network
/// I/O and JSON decoding never run on the UI thread (120fps target).
///
/// Ground truth is `chameleon_feature`'s generated remote datasource: its
/// public method is `=> runApiCall(..., fetchX)`, where `runApiCall` (like
/// `runInIsolate`) is `chameleon_core`'s thin wrapper over `compute()`. So a
/// method counts as safe if its body invokes `runApiCall`, `runInIsolate`,
/// `compute`, `Isolate.run`, or `Isolate.spawn`.
///
/// Scoped by file path to `data/datasources/`, and only checks public,
/// non-static, non-abstract methods: an abstract interface method has no
/// body, and the top-level (or static) `fetchX` worker *is* the isolate
/// body, so neither is the main-isolate entry point this rule guards.
///
/// A datasource that genuinely can't leave the root isolate (a
/// platform-channel or `shared_preferences` local source) should suppress
/// with `// ignore: chameleon_datasource_requires_isolate`.
class DatasourceRequiresIsolate extends DartLintRule {
  const DatasourceRequiresIsolate() : super(code: _code);

  static const LintCode _code = LintCode(
    name: 'chameleon_datasource_requires_isolate',
    problemMessage:
        'This datasource method does not route through an isolate, so its '
        'work runs on the UI thread.',
    correctionMessage:
        "Wrap the work in runApiCall/runInIsolate (chameleon_core's isolate "
        'helpers over compute()), or compute()/Isolate.run directly.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  static final RegExp _datasourcePath = RegExp(r'data[/\\]datasources[/\\]');

  static const _isolatePrimitives = {'runApiCall', 'runInIsolate', 'compute'};

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!_datasourcePath.hasMatch(resolver.path)) return;

    context.registry.addMethodDeclaration((node) {
      if (node.isAbstract ||
          node.isStatic ||
          node.isGetter ||
          node.isSetter ||
          node.isOperator ||
          node.body is EmptyFunctionBody ||
          node.name.lexeme.startsWith('_')) {
        return;
      }

      final finder = _IsolatePrimitiveFinder();
      node.body.accept(finder);
      if (finder.found) return;

      reporter.atToken(node.name, _code);
    });
  }
}

class _IsolatePrimitiveFinder extends RecursiveAstVisitor<void> {
  bool found = false;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final name = node.methodName.name;
    final target = node.target;
    if (DatasourceRequiresIsolate._isolatePrimitives.contains(name) ||
        (target is SimpleIdentifier &&
            target.name == 'Isolate' &&
            (name == 'run' || name == 'spawn'))) {
      found = true;
      return;
    }
    super.visitMethodInvocation(node);
  }
}
