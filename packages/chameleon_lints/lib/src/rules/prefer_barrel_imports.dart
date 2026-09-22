import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:path/path.dart' as p;

/// Prefers importing a feature's barrel file (`<feature>.dart`, exporting
/// its public surface — see e.g. `chameleon_feature`'s generated
/// `features/<feature>/<feature>.dart`) over reaching directly into one of
/// its internal layers (`data/`, `domain/`, `presentation/`, `di/`) from
/// outside that feature. Imports *within* the same feature are exempt —
/// those are expected to reach each other directly; only cross-feature or
/// app-level imports are flagged.
///
/// Pure path-segment matching against the import URI and the importing
/// file's own resolved path — doesn't probe the filesystem for whether a
/// barrel file actually exists there, to stay deterministic and consistent
/// with how the rest of this package's rules work off the AST alone.
class PreferBarrelImports extends DartLintRule {
  const PreferBarrelImports() : super(code: _code);

  static const LintCode _code = LintCode(
    name: 'chameleon_prefer_barrel_imports',
    problemMessage:
        'Reaches past a feature boundary into an internal layer instead of '
        "importing that feature's barrel file.",
    correctionMessage:
        "Import the feature's <feature_name>.dart barrel "
        'file instead of this internal path.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  static final RegExp _internalLayerPath = RegExp(
    r'features[/\\]([^/\\]+)[/\\](data|domain|presentation|di)[/\\]',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addImportDirective((node) {
      final uriValue = node.uri.stringValue;
      if (uriValue == null) return;

      final resolvedPath = _resolveImportPath(uriValue, resolver.path);
      final match = _internalLayerPath.firstMatch(resolvedPath);
      if (match == null) return;

      final feature = match.group(1)!;
      final ownFeatureSegment =
          '${p.separator}features${p.separator}'
          '$feature${p.separator}';
      if (p.normalize(resolver.path).contains(ownFeatureSegment)) {
        return;
      }

      reporter.atNode(node, _code);
    });
  }

  String _resolveImportPath(String uriValue, String importerPath) {
    if (uriValue.startsWith('package:') || uriValue.startsWith('dart:')) {
      return uriValue;
    }
    return p.normalize(p.join(p.dirname(importerPath), uriValue));
  }
}
