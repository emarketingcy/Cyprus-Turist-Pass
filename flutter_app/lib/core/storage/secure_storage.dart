import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

final secureStorageProvider = Provider<SecureStorageService>(
  (_) => const SecureStorageService(),
);

class SecureStorageService {
  const SecureStorageService();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<void> saveToken(String token) =>
      _storage.write(key: ApiConstants.jwtKey, value: token);

  Future<String?> getToken() => _storage.read(key: ApiConstants.jwtKey);

  Future<void> deleteToken() => _storage.delete(key: ApiConstants.jwtKey);

  Future<void> saveUserRole(String role) =>
      _storage.write(key: ApiConstants.userRoleKey, value: role);

  Future<String?> getUserRole() =>
      _storage.read(key: ApiConstants.userRoleKey);

  Future<void> setBiometricEnabled(bool enabled) => _storage.write(
        key: ApiConstants.biometricKey,
        value: enabled.toString(),
      );

  Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: ApiConstants.biometricKey);
    return val == 'true';
  }

  Future<void> clearAll() => _storage.deleteAll();
}
