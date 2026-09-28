import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// A chopper `Response`'s `.body` is null (or unusable) when the call
/// failed, so reading it without ever consulting `.isSuccessful` or `.error`
/// lets a failed HTTP call silently look like a success further up the
/// chain.
///
/// Checked per function/method body: every `.body` read on a chopper
/// `Response` needs the *same variable* to have its `.isSuccessful` or
/// `.error` read somewhere in that same body. Order-insensitive on purpose
/// — `chameleon_feature`'s own generated datasource reads
/// `final envelope = response.body;` and *then* tests
/// `response.isSuccessful`, which is correct; a "check must come first"
/// rule would flag the toolchain's own template. A `.body` read off a
/// non-variable expression (`(await service.get()).body`) has no variable
/// to tie a check to, so it's flagged.
class ChopperRequiresErrorCheck extends DartLintRule {
  const ChopperRequiresErrorCheck() : super(code: _code);

  static const LintCode _code = LintCode(
    name: 'chameleon_chopper_requires_error_check',
    problemMessage:
        'This chopper Response.body is read without checking isSuccessful or '
        'error, so a failed HTTP call can look like a success.',
    correctionMessage:
        'Check response.isSuccessful (or response.error) before using '
        'response.body, and throw a typed exception when the call failed.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    void check(FunctionBody body) {
      final scan = _ResponseUseScan();
      body.accept(scan);
      for (final bodyRead in scan.bodyReads) {
        final variable = bodyRead.variableName;
        if (variable != null && scan.checkedVariables.contains(variable)) {
          continue;
        }
        reporter.atNode(bodyRead.node, _code);
      }
    }

    context.registry.addMethodDeclaration((node) => check(node.body));
    context.registry.addFunctionDeclaration(
      (node) => check(node.functionExpression.body),
    );
  }
}

class _BodyRead {
  _BodyRead(this.node, this.variableName);

  final AstNode node;
  final String? variableName;
}

class _ResponseUseScan extends RecursiveAstVisitor<void> {
  final bodyReads = <_BodyRead>[];
  final checkedVariables = <String>{};

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    _record(
      node.prefix.staticType,
      node.identifier.name,
      node,
      node.prefix.name,
    );
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    final target = node.target;
    _record(
      target?.staticType,
      node.propertyName.name,
      node,
      target is SimpleIdentifier ? target.name : null,
    );
    super.visitPropertyAccess(node);
  }

  void _record(
    DartType? targetType,
    String property,
    AstNode node,
    String? variableName,
  ) {
    if (!_isChopperResponse(targetType)) return;
    if (property == 'body') {
      bodyReads.add(_BodyRead(node, variableName));
    } else if ((property == 'isSuccessful' || property == 'error') &&
        variableName != null) {
      checkedVariables.add(variableName);
    }
  }

  bool _isChopperResponse(DartType? type) {
    if (type is! InterfaceType) return false;
    return type.element.name == 'Response' &&
        type.element.library.uri.toString().startsWith('package:chopper/');
  }
}
