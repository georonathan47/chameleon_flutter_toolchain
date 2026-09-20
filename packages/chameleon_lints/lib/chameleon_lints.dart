import 'package:chameleon_lints/src/rules/bloc_provider_value_for_di.dart';
import 'package:chameleon_lints/src/rules/no_function_type_in_injectable_ctor.dart';
import 'package:chameleon_lints/src/rules/no_set_state.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

export 'src/rules/bloc_provider_value_for_di.dart';
export 'src/rules/no_function_type_in_injectable_ctor.dart';
export 'src/rules/no_set_state.dart';

PluginBase createPlugin() => _ChameleonLintsPlugin();

class _ChameleonLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => const [
    NoSetState(),
    BlocProviderValueForDi(),
    NoFunctionTypeInInjectableCtor(),
  ];
}
