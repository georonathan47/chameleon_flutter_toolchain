import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// A DI **singleton** must be provided with `BlocProvider.value`.
///
/// `BlocProvider(create: (_) => getIt<X>())` closes the bloc when the widget
/// is disposed — fine for an `@injectable` factory (a fresh instance every
/// call, nothing else holds a reference), but wrong for a `@lazySingleton`/
/// `@singleton`: the DI container still holds that exact instance, so the
/// next widget that resolves it gets one already closed. See this project's
/// `tasks/lessons.md`.
///
/// Resolves the type argument of the `getIt<X>()`/`di<X>()` call and checks
/// `X`'s own `@lazySingleton`/`@Singleton` annotation — a plain syntactic
/// "calls getIt at all" check (an earlier version of this rule) flags
/// factory-scoped blocs too, which is exactly the pattern
/// `chameleon_feature`-generated pages use correctly; confirmed by actually
/// wiring this rule into a generated app and hitting that false positive,
/// not assumed.
class BlocProviderValueForDi extends DartLintRule {
  const BlocProviderValueForDi() : super(code: _code);

  static const LintCode _code = LintCode(
    name: 'chameleon_bloc_provider_value_for_di',
    problemMessage:
        'BlocProvider(create: ...) resolving a DI singleton closes it when '
        'the widget disposes, even though the container still holds it.',
    correctionMessage:
        'Use BlocProvider.value(value: getIt<X>()) for anything resolved '
        'from the DI container; reserve create: for instances the widget '
        'tree genuinely owns.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  static const _diAccessorNames = {'getIt', 'di'};
  static const _singletonAnnotationNames = {'LazySingleton', 'Singleton'};

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final constructorName = node.constructorName.type.name.lexeme;
      if (constructorName != 'BlocProvider') return;
      // BlocProvider.value(...) is exactly the pattern this rule wants —
      // don't flag it.
      if (node.constructorName.name?.name == 'value') return;

      NamedExpression? createArg;
      for (final arg in node.argumentList.arguments) {
        if (arg is NamedExpression && arg.name.label.name == 'create') {
          createArg = arg;
          break;
        }
      }
      if (createArg == null) return;

      if (_resolvesDiSingleton(createArg.expression)) {
        reporter.atNode(node, _code);
      }
    });
  }

  bool _resolvesDiSingleton(Expression createExpression) {
    var found = false;
    createExpression.visitChildren(
      _DiCallVisitor(_diAccessorNames, (element) {
        if (_isSingletonRegistration(element)) found = true;
      }),
    );
    return found;
  }

  static bool _isSingletonRegistration(ClassElement classElement) {
    for (final annotation in classElement.metadata.annotations) {
      final typeName = annotation.computeConstantValue()?.type?.element?.name;
      if (_singletonAnnotationNames.contains(typeName)) return true;
    }
    return false;
  }
}

class _DiCallVisitor extends RecursiveAstVisitor<void> {
  _DiCallVisitor(this._accessorNames, this._onMatch);

  final Set<String> _accessorNames;
  final void Function(ClassElement) _onMatch;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target == null && _accessorNames.contains(node.methodName.name)) {
      _reportIfResolvable(node.typeArguments);
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    final function = node.function;
    if (function is SimpleIdentifier &&
        _accessorNames.contains(function.name)) {
      _reportIfResolvable(node.typeArguments);
    }
    super.visitFunctionExpressionInvocation(node);
  }

  // Only acts on an explicit type argument (`getIt<X>()`) — the common,
  // and in this project's templates the only, shape. `getIt()` with the
  // type inferred from context isn't resolved here; better to miss a rare
  // shape than guess and flag something that isn't actually a singleton.
  void _reportIfResolvable(TypeArgumentList? typeArguments) {
    final typeArg = typeArguments?.arguments.firstOrNull;
    final element = typeArg?.type?.element;
    if (element is ClassElement) _onMatch(element);
  }
}
