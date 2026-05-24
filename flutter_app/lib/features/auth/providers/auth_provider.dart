import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';

@immutable
class AuthState {
  const AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
    this.biometricPending = false,
    this.promptBiometricSetup = false,
  });

  final UserModel? user;
  final String? token;
  final bool isLoading;
  final String? error;

  /// Token is in storage but biometric prompt is required before hydrating user.
  final bool biometricPending;

  /// True once after first password login — consumers should prompt bio setup.
  final bool promptBiometricSetup;

  bool get isAuthenticated => user != null && token != null;

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isLoading,
    String? error,
    bool? biometricPending,
    bool? promptBiometricSetup,
    bool clearUser = false,
    bool clearToken = false,
    bool clearError = false,
  }) =>
      AuthState(
        user: clearUser ? null : user ?? this.user,
        token: clearToken ? null : token ?? this.token,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
        biometricPending: biometricPending ?? this.biometricPending,
        promptBiometricSetup:
            promptBiometricSetup ?? this.promptBiometricSetup,
      );
}

/// Bridges Riverpod auth state to GoRouter's [Listenable] refresh.
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier(Ref ref) {
    ref.listen<AuthState>(authStateProvider, (_, __) => notifyListeners());
  }
}

final authChangeNotifierProvider = Provider<AuthChangeNotifier>((ref) {
  return AuthChangeNotifier(ref);
});

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _restoreSession();
    return const AuthState(isLoading: true);
  }

  // ── Session restore ──────────────────────────────────────────────────────

  Future<void> _restoreSession() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.getToken();

    if (token == null) {
      state = const AuthState();
      return;
    }

    // Try biometric gate if enabled.
    final bioEnabled = await storage.isBiometricEnabled();
    if (bioEnabled) {
      final bio = ref.read(biometricServiceProvider);
      if (await bio.isAvailable()) {
        final ok =
            await bio.authenticate('Unlock Tourist Pass Cyprus');
        if (!ok) {
          // Let user retry biometric or use password from auth screen.
          state = const AuthState(biometricPending: true);
          return;
        }
      }
    }

    await _hydrateUser(token);
  }

  Future<void> _hydrateUser(String token) async {
    try {
      final user = await ref.read(authServiceProvider).getMe();
      state = AuthState(user: user, token: token);
    } catch (_) {
      await ref.read(secureStorageProvider).clearAll();
      state = const AuthState();
    }
  }

  // ── Biometric unlock (called from auth screen) ───────────────────────────

  Future<void> unlockWithBiometric() async {
    final bio = ref.read(biometricServiceProvider);
    final ok = await bio.authenticate('Unlock Tourist Pass Cyprus');
    if (!ok) return; // stay on auth screen
    state = state.copyWith(isLoading: true, biometricPending: false);
    final token = await ref.read(secureStorageProvider).getToken();
    if (token == null) {
      state = const AuthState();
      return;
    }
    await _hydrateUser(token);
  }

  void cancelBiometric() {
    // Discard stored token — user will re-authenticate with password.
    ref.read(secureStorageProvider).clearAll();
    state = const AuthState();
  }

  // ── Login ────────────────────────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result =
          await ref.read(authServiceProvider).login(email, password);
      await ref.read(secureStorageProvider).saveToken(result.token);
      state = AuthState(
        user: result.user,
        token: result.token,
        promptBiometricSetup: true,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
          isLoading: false, error: 'An unexpected error occurred.');
    }
  }

  // ── Register ─────────────────────────────────────────────────────────────

  Future<void> register(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await ref.read(authServiceProvider).register(payload);
      await ref.read(secureStorageProvider).saveToken(result.token);
      state = AuthState(
        user: result.user,
        token: result.token,
        promptBiometricSetup: true,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
          isLoading: false, error: 'An unexpected error occurred.');
    }
  }

  // ── Misc ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await ref.read(secureStorageProvider).clearAll();
    state = const AuthState();
  }

  void clearError() => state = state.copyWith(clearError: true);

  void clearPromptBiometricSetup() =>
      state = state.copyWith(promptBiometricSetup: false);
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
