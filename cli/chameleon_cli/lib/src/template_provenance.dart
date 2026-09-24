import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

const _validStateManagementValues = {'bloc', 'provider', 'riverpod'};

/// Reads the `state_management` choice `chameleon create` recorded in a
/// generated app's `.chameleon/template.yaml` — so `chameleon feature`/
/// `chameleon state` can default to the same choice instead of asking for
/// it on every invocation. Falls back to `'bloc'` when the key is absent
/// (an app generated before this field existed) or the file can't be
/// parsed as expected — never throws, since a missing/malformed provenance
/// field shouldn't block feature generation the way a missing provenance
/// *file* already does (that's checked separately, before this is called).
String readStateManagementDefault(Directory projectRoot) {
  final file = File(p.join(projectRoot.path, '.chameleon', 'template.yaml'));
  if (!file.existsSync()) return 'bloc';

  try {
    final doc = loadYaml(file.readAsStringSync());
    final generatedWith = doc is YamlMap ? doc['generated_with'] : null;
    final value = generatedWith is YamlMap
        ? generatedWith['state_management']
        : null;
    if (value is String && _validStateManagementValues.contains(value)) {
      return value;
    }
    return 'bloc';
  } on Object {
    return 'bloc';
  }
}
