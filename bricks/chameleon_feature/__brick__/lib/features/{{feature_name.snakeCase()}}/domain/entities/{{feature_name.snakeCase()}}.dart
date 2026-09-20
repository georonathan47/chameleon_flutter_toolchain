import 'package:equatable/equatable.dart';

/// A single {{feature_name.snakeCase()}} item. Scaffolded with just an id
/// and a name — add the real fields this feature needs, and update the
/// model/mapping in `data/models/` to match.
class {{feature_name.pascalCase()}} extends Equatable {
  const {{feature_name.pascalCase()}}({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
