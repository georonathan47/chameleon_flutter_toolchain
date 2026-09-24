import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// A method/function returning `TaskEither<Failure, ...>` promises its
/// caller a `Success` or a `Failure` — never a thrown exception. That
/// promise only holds if the body is actually built through a safe
/// `TaskEither` constructor (`tryCatch`/`of`/`right`/`left`/`fromEither`/
/// `fromTask`/`fromOption`); a plain `async`/`await` block can still throw
/// straight past its own return type. See this project's
/// `tasks/lessons.md` and `docs/architecture.md` — every
/// `chameleon_feature`-generated repository implementation already follows
/// the safe `=> TaskEither.tryCatch(...)` shape this rule checks for.
///
/// Deliberately does **not** flag the paired *datasource* layer for
/// throwing — that's the other, correct half of this handoff (the
/// datasource throws, the repository's `TaskEither.tryCatch` catches it and
/// maps it to a `Failure`). This rule only guards the repository-facing
/// contract, where a swallowed throw would actually escape to a caller.
///
/// Only inspects a method's own body, not what it delegates to — a method
/// that simply forwards to a private helper (`=> _fetch();`) is flagged
/// even when that helper is itself safely constructed. Splitting a safe
/// `TaskEither.tryCatch(...)` out into a helper isn't traced through today;
/// better to miss delegated safety than to silently trust an arbitrary call.
class TaskEitherRequiresSafeConstruction extends DartLintRule {
  const TaskEitherRequiresSafeConstruction() : super(code: _code);

  static const LintCode _code = LintCode(
    name: 'chameleon_task_either_requires_safe_construction',
    problemMessage:
        'This TaskEither<Failure, ...> method is not built from a safe '
        'TaskEither constructor, so a thrown exception here would escape '
        'its Success/Failure contract instead of surfacing as a Failure.',
    correctionMessage:
        'Wrap the body in TaskEither.tryCatch(() async { ... }, onError) '
        '(or another safe constructor: .of/.right/.left/.fromEither/ '
        '.fromTask/.fromOption).',
    errorSeverity: ErrorSeverity.ERROR,
  );

  static const _safeConstructors = {
    'tryCatch',
    'of',
    'right',
    'left',
    'fromEither',
    'fromTask',
    'fromOption',
  };

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration((node) {
      final body = node.body;
      _check(node.returnType?.type, body, node, reporter);
    });

    context.registry.addFunctionDeclaration((node) {
      final body = node.functionExpression.body;
      _check(node.returnType?.type, body, node, reporter);
    });
  }

  void _check(
    DartType? returnType,
    FunctionBody body,
    AstNode reportNode,
    ErrorReporter reporter,
  ) {
    if (!_isFailureTaskEither(returnType)) return;
    if (_isSafelyConstructed(body)) return;
    reporter.atNode(reportNode, _code);
  }

  bool _isFailureTaskEither(DartType? type) {
    if (type is! InterfaceType) return false;
    if (type.element.name != 'TaskEither') return false;

    return _isFailureType(type.typeArguments.firstOrNull);
  }

  bool _isFailureType(DartType? type) {
    if (type is! InterfaceType) return false;
    if (type.element.name == 'Failure') return true;
    return type.element.allSupertypes.any(
      (supertype) => supertype.element.name == 'Failure',
    );
  }

  bool _isSafelyConstructed(FunctionBody body) {
    // An abstract method/interface signature (no body at all — the `;`
    // after the declaration) has nothing to construct unsafely; found for
    // real against chameleon_feature's own generated
    // `WidgetsRepository.getWidgets()` abstract interface method, which
    // this rule flagged despite having no body to check.
    if (body is EmptyFunctionBody) return true;

    if (body is ExpressionFunctionBody) {
      return _isSafeTaskEitherConstruction(body.expression);
    }

    if (body is BlockFunctionBody) {
      final statements = body.block.statements;
      // A block containing exactly `return TaskEither.tryCatch(...);` is
      // functionally identical to the arrow form — not the imperative
      // async/await risk this rule exists to catch.
      if (statements.length != 1) return false;
      final only = statements.single;
      final expression = only is ReturnStatement ? only.expression : null;
      return expression != null && _isSafeTaskEitherConstruction(expression);
    }

    return false;
  }

  // Unwraps a fluent chain (`TaskEither.tryCatch(...).map(...)`) down to
  // its root call and checks that root is one of the safe constructors.
  // `TaskEither.tryCatch(...)` etc. are named *constructors*, not static
  // methods — the analyzer represents an unchained call as
  // InstanceCreationExpression, and only a chained `.map`/`.flatMap`/...
  // on top of it as MethodInvocation, so both shapes need handling.
  bool _isSafeTaskEitherConstruction(Expression expression) {
    var current = expression;
    while (current is MethodInvocation) {
      final target = current.target;
      if (target is MethodInvocation || target is InstanceCreationExpression) {
        current = target!;
      } else {
        break;
      }
    }

    if (current is InstanceCreationExpression) {
      final typeName = current.constructorName.type.name.lexeme;
      final constructorName = current.constructorName.name?.name;
      return typeName == 'TaskEither' &&
          constructorName != null &&
          _safeConstructors.contains(constructorName);
    }

    if (current is MethodInvocation) {
      final target = current.target;
      if (target is SimpleIdentifier && target.name == 'TaskEither') {
        return _safeConstructors.contains(current.methodName.name);
      }
    }

    return false;
  }
}
