import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/{{feature_name.snakeCase()}}.dart';

part '{{feature_name.snakeCase()}}_model.freezed.dart';
part '{{feature_name.snakeCase()}}_model.g.dart';

// Never stack @JsonSerializable on top of @freezed — freezed's own
// `fromJson` factory + `part '*.g.dart'` is the whole json integration
// (tasks/lessons.md guardrail #3).
@freezed
abstract class {{feature_name.pascalCase()}}Model with _${{feature_name.pascalCase()}}Model {
  const factory {{feature_name.pascalCase()}}Model({
    required String id,
    required String name,
  }) = _{{feature_name.pascalCase()}}Model;

  factory {{feature_name.pascalCase()}}Model.fromJson(Map<String, dynamic> json) =>
      _${{feature_name.pascalCase()}}ModelFromJson(json);
}

extension {{feature_name.pascalCase()}}ModelX on {{feature_name.pascalCase()}}Model {
  {{feature_name.pascalCase()}} toEntity() => {{feature_name.pascalCase()}}(id: id, name: name);
}
