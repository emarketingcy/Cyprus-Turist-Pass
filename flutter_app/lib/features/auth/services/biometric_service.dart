import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

final biometricServiceProvider =
    Provider<BiometricService>((_) => const BiometricService());

class BiometricService {
  const BiometricService();

  static final _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      final can = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();
      return can && supported;
    } catch (_) {
      return false;
    }
  }

  /// Human-readable label for the biometric type on this device.
  Future<String> label() async {
    try {
      final types = await _auth.getAvailableBiometrics();
      if (types.contains(BiometricType.face)) return 'Face ID';
      if (types.contains(BiometricType.fingerprint)) return 'Fingerprint';
    } catch (_) {}
    return 'Biometrics';
  }

  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // PIN fallback allowed
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
