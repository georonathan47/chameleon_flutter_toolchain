import 'dart:io';

import 'package:chameleon_cli/src/template_provenance.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('readStateManagementDefault', () {
    late Directory projectRoot;

    setUp(() {
      projectRoot = Directory.systemTemp.createTempSync(
        'chameleon_cli_provenance_test',
      );
      Directory(
        p.join(projectRoot.path, '.chameleon'),
      ).createSync(recursive: true);
    });

    tearDown(() {
      projectRoot.deleteSync(recursive: true);
    });

    void writeTemplate(String content) {
      File(
        p.join(projectRoot.path, '.chameleon', 'template.yaml'),
      ).writeAsStringSync(content);
    }

    test('reads an explicit state_management value', () {
      writeTemplate('generated_with:\n  state_management: riverpod\n');
      expect(readStateManagementDefault(projectRoot), 'riverpod');
    });

    test('falls back to bloc when the key is absent', () {
      writeTemplate('generated_with:\n  chameleon_app_brick: 1.0.0\n');
      expect(readStateManagementDefault(projectRoot), 'bloc');
    });

    test('falls back to bloc when the file does not exist', () {
      expect(readStateManagementDefault(projectRoot), 'bloc');
    });

    test('falls back to bloc for an unrecognized value', () {
      writeTemplate('generated_with:\n  state_management: mobx\n');
      expect(readStateManagementDefault(projectRoot), 'bloc');
    });

    test('falls back to bloc for a malformed YAML file', () {
      writeTemplate('not: [valid: yaml');
      expect(readStateManagementDefault(projectRoot), 'bloc');
    });
  });
}
