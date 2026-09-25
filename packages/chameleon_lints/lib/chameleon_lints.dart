import 'package:chameleon_lints/src/rules/bloc_provider_value_for_di.dart';
import 'package:chameleon_lints/src/rules/chopper_requires_error_check.dart';
import 'package:chameleon_lints/src/rules/datasource_requires_isolate.dart';
import 'package:chameleon_lints/src/rules/no_function_type_in_injectable_ctor.dart';
import 'package:chameleon_lints/src/rules/no_print.dart';
import 'package:chameleon_lints/src/rules/no_set_state.dart';
import 'package:chameleon_lints/src/rules/prefer_barrel_imports.dart';
import 'package:chameleon_lints/src/rules/prefer_dot_shorthands.dart';
import 'package:chameleon_lints/src/rules/prefer_sealed_class.dart';
import 'package:chameleon_lints/src/rules/task_either_requires_safe_construction.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

export 'src/rules/bloc_provider_value_for_di.dart';
export 'src/rules/chopper_requires_error_check.dart';
export 'src/rules/datasource_requires_isolate.dart';
export 'src/rules/no_function_type_in_injectable_ctor.dart';
export 'src/rules/no_print.dart';
export 'src/rules/no_set_state.dart';
export 'src/rules/prefer_barrel_imports.dart';
export 'src/rules/prefer_dot_shorthands.dart';
export 'src/rules/prefer_sealed_class.dart';
export 'src/rules/task_either_requires_safe_construction.dart';

PluginBase createPlugin() => _ChameleonLintsPlugin();

class _ChameleonLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => const [
    NoSetState(),
    NoPrint(),
    DatasourceRequiresIsolate(),
    ChopperRequiresErrorCheck(),
    BlocProviderValueForDi(),
    NoFunctionTypeInInjectableCtor(),
    PreferDotShorthands(),
    PreferBarrelImports(),
    PreferSealedClass(),
    TaskEitherRequiresSafeConstruction(),
  ];
}
