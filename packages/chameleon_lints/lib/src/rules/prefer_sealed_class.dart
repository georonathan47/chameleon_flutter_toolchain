import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Prefers `sealed class` for a closed abstract hierarchy — a non-sealed
/// `abstract class`/`abstract base class`/`abstract interface class` with
/// 2+ subtypes declared in the same file gets nothing from staying
/// unsealed (an exhaustive `switch` over it can't be checked by the
/// analyzer), and every bloc event/state and route-guard-state hierarchy in
/// this project already uses `sealed class` for exactly that reason. See
/// this project's `tasks/lessons.md`.
///
/// Doesn't try to guess when a hierarchy is deliberately left open for
/// external subclassing (e.g. `chameleon_core`'s `Failure`, whose own doc
/// comment explains why it can't be sealed even though every subclass
/// shipped with the package today lives in the same file) — that's an
/// intent this rule can't read off the AST. Suppress a genuine case with
/// `// ignore: chameleon_prefer_sealed_class` on the class declaration.
class PreferSealedClass extends DartLintRule {
  const PreferSealedClass() : super(code: _code);

  static const LintCode _code = LintCode(
    name: 'chameleon_prefer_sealed_class',
    problemMessage:
        'Every subtype of this abstract class is declared in the same '
        'file — nothing prevents sealing it, and sealing it enables '
        'exhaustive switches over the hierarchy.',
    correctionMessage:
        'Replace "abstract class"/"abstract base class" with "sealed '
        'class", or suppress with // ignore: chameleon_prefer_sealed_class '
        'if this hierarchy is deliberately open to external subclassing.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((unit) {
      final classes = unit.declarations.whereType<ClassDeclaration>().toList();

      for (final classDeclaration in classes) {
        if (classDeclaration.sealedKeyword != null) continue;
        if (classDeclaration.abstractKeyword == null) continue;

        final element = classDeclaration.declaredFragment?.element;
        if (element == null) continue;

        final subtypeCount = classes
            .where((candidate) => !identical(candidate, classDeclaration))
            .where((candidate) => _extendsOrImplements(candidate, element))
            .length;

        if (subtypeCount >= 2) {
          reporter.atToken(classDeclaration.name, _code);
        }
      }
    });
  }

  bool _extendsOrImplements(ClassDeclaration candidate, Element target) {
    if (candidate.extendsClause?.superclass.element == target) return true;

    final interfaces = candidate.implementsClause?.interfaces;
    if (interfaces == null) return false;
    return interfaces.any((interface) => interface.element == target);
  }
}
