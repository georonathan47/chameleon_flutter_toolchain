import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Prefers Dart's dot-shorthand syntax (`.member`) over a fully-qualified
/// `Type.member` when the surrounding context already pins down `Type` —
/// an explicitly-typed variable, an argument whose parameter has a declared
/// type, or the enclosing function's declared return type.
///
/// Scoped to exactly those three positions to stay high-confidence:
/// anywhere else, the "known target type" the shorthand relies on isn't
/// guaranteed to be exactly `Type` (it could come from a wider context this
/// rule doesn't try to model), so it stays silent rather than guess. An
/// expression already written as `.member` never reaches this rule at all —
/// dot-shorthand syntax parses to a different AST node than
/// `PrefixedIdentifier`/`MethodInvocation`.
class PreferDotShorthands extends DartLintRule {
  const PreferDotShorthands() : super(code: _code);

  static const LintCode _code = LintCode(
    name: 'chameleon_prefer_dot_shorthands',
    problemMessage:
        'The target type here is already known from context — this '
        'qualified access can be written as a dot shorthand.',
    correctionMessage: 'Replace Type.member with .member.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addPrefixedIdentifier((node) {
      _check(node, node.prefix.element, reporter);
    });

    context.registry.addMethodInvocation((node) {
      final target = node.target;
      if (target is! SimpleIdentifier) return;
      _check(node, target.element, reporter);
    });
  }

  void _check(
    Expression node,
    Element? prefixElement,
    ErrorReporter reporter,
  ) {
    if (prefixElement is! InterfaceElement) return;

    final contextElement = _typeElementOf(_contextTypeFor(node));
    if (contextElement == null) return;

    if (contextElement == prefixElement) {
      reporter.atNode(node, _code);
    }
  }

  Element? _typeElementOf(DartType? type) {
    if (type is InterfaceType) return type.element;
    return null;
  }

  // The three positions where the shorthand's target type is unambiguous.
  DartType? _contextTypeFor(Expression node) {
    final parameterType = node.correspondingParameter?.type;
    if (parameterType != null) return parameterType;

    final parent = node.parent;

    if (parent is VariableDeclaration && parent.initializer == node) {
      final list = parent.parent;
      if (list is VariableDeclarationList) return list.type?.type;
      return null;
    }

    if (parent is ReturnStatement && parent.expression == node) {
      return _declaredReturnTypeFor(node);
    }

    if (parent is ExpressionFunctionBody && parent.expression == node) {
      return _declaredReturnTypeFor(node);
    }

    return null;
  }

  // Stops at the nearest enclosing function/method body, so an expression
  // inside a nested closure is never misattributed to an outer method's
  // return type. A top-level/local function's body sits under a
  // FunctionExpression, not directly under its FunctionDeclaration — a
  // method's body sits directly under its MethodDeclaration instead, no
  // such wrapper — so both shapes need handling.
  DartType? _declaredReturnTypeFor(AstNode node) {
    final owner = node.thisOrAncestorOfType<FunctionBody>()?.parent;
    if (owner is MethodDeclaration) return owner.returnType?.type;
    if (owner is FunctionExpression && owner.parent is FunctionDeclaration) {
      return (owner.parent! as FunctionDeclaration).returnType?.type;
    }
    return null;
  }
}
