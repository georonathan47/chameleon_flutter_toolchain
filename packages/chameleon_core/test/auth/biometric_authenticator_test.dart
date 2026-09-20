import 'package:chameleon_core/chameleon_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoopBiometricAuthenticator', () {
    const authenticator = NoopBiometricAuthenticator();

    test('is never available', () async {
      expect(await authenticator.isAvailable, isFalse);
    });

    test('authenticate() always fails closed', () async {
      expect(
        await authenticator.authenticate(reason: 'Confirm transfer'),
        isFalse,
      );
    });
  });
}
