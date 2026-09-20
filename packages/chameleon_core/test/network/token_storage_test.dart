import 'package:chameleon_core/chameleon_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  group('TokenStorage', () {
    late _MockSecureStorage secure;
    late SharedPreferences prefs;
    late TokenStorage storage;

    setUp(() async {
      secure = _MockSecureStorage();
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      storage = TokenStorage(secure, prefs);
    });

    test('getAccessToken() reads through SecureStorage', () async {
      when(
        () => secure.read('access_token'),
      ).thenAnswer((_) async => 'the-access-token');

      expect(await storage.getAccessToken(), equals('the-access-token'));
      verify(() => secure.read('access_token')).called(1);
    });

    test('getRefreshToken() reads through SecureStorage', () async {
      when(
        () => secure.read('refresh_token'),
      ).thenAnswer((_) async => 'the-refresh-token');

      expect(await storage.getRefreshToken(), equals('the-refresh-token'));
      verify(() => secure.read('refresh_token')).called(1);
    });

    test(
      'saveTokens() writes both tokens and mirrors the access token to '
      'SharedPreferences',
      () async {
        when(() => secure.write(any(), any())).thenAnswer((_) async {});

        await storage.saveTokens('access-1', 'refresh-1');

        verify(() => secure.write('access_token', 'access-1')).called(1);
        verify(() => secure.write('refresh_token', 'refresh-1')).called(1);
        expect(prefs.getString('access_token'), equals('access-1'));
      },
    );

    test(
      'saveTokens() with no refresh token only writes the access token',
      () async {
        when(() => secure.write(any(), any())).thenAnswer((_) async {});

        await storage.saveTokens('access-1');

        verify(() => secure.write('access_token', 'access-1')).called(1);
        verifyNever(() => secure.write('refresh_token', any()));
      },
    );

    test(
      'clearTokens() deletes both tokens and removes the SharedPreferences '
      'mirror',
      () async {
        await prefs.setString('access_token', 'stale');
        when(() => secure.delete(any())).thenAnswer((_) async {});

        await storage.clearTokens();

        verify(() => secure.delete('access_token')).called(1);
        verify(() => secure.delete('refresh_token')).called(1);
        expect(prefs.getString('access_token'), isNull);
      },
    );
  });
}
