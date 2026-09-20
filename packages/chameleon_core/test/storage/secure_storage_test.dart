import 'package:chameleon_core/chameleon_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('SecureStorageImpl', () {
    late _MockFlutterSecureStorage secure;
    late SecureStorage storage;

    setUp(() {
      secure = _MockFlutterSecureStorage();
      storage = SecureStorageImpl(secure);
    });

    test('read() delegates to FlutterSecureStorage.read', () async {
      when(
        () => secure.read(key: 'pin'),
      ).thenAnswer((_) async => '1234');

      expect(await storage.read('pin'), equals('1234'));
      verify(() => secure.read(key: 'pin')).called(1);
    });

    test('write() delegates to FlutterSecureStorage.write', () async {
      when(
        () => secure.write(key: 'pin', value: '1234'),
      ).thenAnswer((_) async {});

      await storage.write('pin', '1234');
      verify(() => secure.write(key: 'pin', value: '1234')).called(1);
    });

    test('delete() delegates to FlutterSecureStorage.delete', () async {
      when(() => secure.delete(key: 'pin')).thenAnswer((_) async {});

      await storage.delete('pin');
      verify(() => secure.delete(key: 'pin')).called(1);
    });

    test('deleteAll() delegates to FlutterSecureStorage.deleteAll', () async {
      when(() => secure.deleteAll()).thenAnswer((_) async {});

      await storage.deleteAll();
      verify(() => secure.deleteAll()).called(1);
    });
  });
}
