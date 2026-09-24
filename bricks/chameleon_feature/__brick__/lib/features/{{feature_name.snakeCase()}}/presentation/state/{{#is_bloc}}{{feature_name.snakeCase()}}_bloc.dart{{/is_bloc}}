import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_{{feature_name.snakeCase()}}.dart';
import '{{feature_name.snakeCase()}}_event.dart';
import '{{feature_name.snakeCase()}}_state.dart';

@injectable
class {{feature_name.pascalCase()}}Bloc
    extends Bloc<{{feature_name.pascalCase()}}Event, {{feature_name.pascalCase()}}State> {
  {{feature_name.pascalCase()}}Bloc(this._get{{feature_name.pascalCase()}})
    : super(const {{feature_name.pascalCase()}}Initial()) {
    on<{{feature_name.pascalCase()}}Requested>(_onRequested);
  }

  final Get{{feature_name.pascalCase()}} _get{{feature_name.pascalCase()}};

  Future<void> _onRequested(
    {{feature_name.pascalCase()}}Requested event,
    Emitter<{{feature_name.pascalCase()}}State> emit,
  ) async {
    emit(const {{feature_name.pascalCase()}}Loading());
    final result = await _get{{feature_name.pascalCase()}}().run();
    result.match(
      (failure) => emit({{feature_name.pascalCase()}}LoadError(failure)),
      (items) => emit({{feature_name.pascalCase()}}Loaded(items)),
    );
  }
}
