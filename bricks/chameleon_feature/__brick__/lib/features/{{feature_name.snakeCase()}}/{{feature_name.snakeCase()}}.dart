export 'data/models/{{feature_name.snakeCase()}}_model.dart';
export 'data/repositories/{{feature_name.snakeCase()}}_repository_impl.dart';
export 'data/services/{{feature_name.snakeCase()}}_api_client.dart';
export 'di/{{feature_name.snakeCase()}}_module.dart';
export 'domain/entities/{{feature_name.snakeCase()}}.dart';
export 'domain/repositories/{{feature_name.snakeCase()}}_repository.dart';
export 'domain/usecases/get_{{feature_name.snakeCase()}}.dart';
{{#is_bloc}}
export 'presentation/state/{{feature_name.snakeCase()}}_bloc.dart';
export 'presentation/state/{{feature_name.snakeCase()}}_event.dart';
export 'presentation/state/{{feature_name.snakeCase()}}_state.dart';
{{/is_bloc}}
{{#is_provider}}
export 'presentation/state/{{feature_name.snakeCase()}}_controller.dart';
export 'presentation/state/{{feature_name.snakeCase()}}_state.dart';
{{/is_provider}}
{{#is_riverpod}}
export 'presentation/state/{{feature_name.snakeCase()}}_provider.dart';
{{/is_riverpod}}
export 'presentation/pages/{{feature_name.snakeCase()}}_page.dart';
