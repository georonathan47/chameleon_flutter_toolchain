import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// injectable resolves **every** constructor parameter on an
/// `@injectable`/`@lazySingleton`/`@singleton` class from the DI container —
/// optional ones included. A bare function-type parameter (a clock seam like
/// `DateTime Function()? now`) breaks the generator with "Can not resolve
/// function type." See this project's `tasks/lessons.md`.
class NoFunctionTypeInInjectableCtor extends DartLintRule {
  const NoFunctionTypeInInjectableCtor() : super(code: _code);

  static const LintCode _code = LintCode(
    name: 'chameleon_no_function_type_in_injectable_ctor',
    problemMessage:
        'injectable tries to resolve every constructor parameter from the '
        'DI container, including this function-typed one, and fails with '
        '"Can not resolve function type."',
    correctionMessage:
        'Keep the injected constructor argument-free for anything that '
        'is not a real registered dependency, and put a test/config seam '
        'on a separate named constructor instead (e.g. '
        'MyService.withClock(this._now)).',
    errorSeverity: ErrorSeverity.ERROR,
  );

  static const _injectableAnnotationNames = {
    'injectable',
    'Injectable',
    'lazySingleton',
    'LazySingleton',
    'singleton',
    'Singleton',
  };

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addConstructorDeclaration((node) {
      // injectable resolves the unnamed constructor by default — a named
      // one (`MyService.withClock(this._now)`) is exactly the escape hatch
      // this rule's own correctionMessage recommends, and injectable never
      // calls it unless separately configured to. Flagging it too would
      // make the rule reject its own suggested fix.
      if (node.name != null) return;

      final classDeclaration = node.parent;
      if (classDeclaration is! ClassDeclaration) return;
      if (!_hasInjectableAnnotation(classDeclaration)) return;

      for (final parameter in node.parameters.parameters) {
        if (_isFunctionTyped(parameter)) {
          reporter.atNode(parameter, _code);
        }
      }
    });
  }

  bool _hasInjectableAnnotation(ClassDeclaration classDeclaration) {
    for (final annotation in classDeclaration.metadata) {
      if (_injectableAnnotationNames.contains(annotation.name.name)) {
        return true;
      }
    }
    return false;
  }

  bool _isFunctionTyped(FormalParameter parameter) {
    // Unwraps `{Type name}` / `[Type name]` to the underlying parameter —
    // optional parameters are exactly the case injectable still tries (and
    // fails) to resolve.
    final actual = parameter is DefaultFormalParameter
        ? parameter.parameter
        : parameter;

    // Resolved-type check rather than matching AST shapes: covers
    // `void Function() name` written directly, `SomeType Function()? name`,
    // AND `this.callback` field-formal shorthand whose field is declared as
    // a function type — injectable resolves every one of those the same
    // (failing) way, so the AST shape the parameter happens to be written
    // in shouldn't matter.
    final element = actual.declaredFragment?.element;
    return element is FormalParameterElement && element.type is FunctionType;
  }
}
