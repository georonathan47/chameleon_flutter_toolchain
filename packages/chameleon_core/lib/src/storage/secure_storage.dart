import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// General-purpose OS-level secure key/value storage for arbitrary app
/// secrets (a biometric opt-in flag, a PIN hash, etc.) — separate from
/// `TokenStorage`, which stays a dedicated, isolate-safety-documented type
/// for the auth token pair specifically. Introducing a new use case for
/// secure storage should reach for this interface rather than growing
/// `TokenStorage`'s own surface.
abstract interface class SecureStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

/// Wraps [FlutterSecureStorage] — the same dependency `TokenStorage` already
/// uses, so this adds no new package dependency. A consuming app's DI setup
/// binds a `FlutterSecureStorage` singleton for `TokenStorage`'s sake; that
/// same binding satisfies this constructor with no extra wiring.
@LazySingleton(as: SecureStorage)
class SecureStorageImpl implements SecureStorage {
  SecureStorageImpl(this._secure);

  final FlutterSecureStorage _secure;

  @override
  Future<String?> read(String key) => _secure.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _secure.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _secure.delete(key: key);

  @override
  Future<void> deleteAll() => _secure.deleteAll();
}
