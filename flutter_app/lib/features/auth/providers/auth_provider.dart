import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

@immutable
class AuthState {
  const AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });

  final UserModel? user;
  final String? token;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => user != null && token != null;

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearToken = false,
    bool clearError = false,
  }) =>
      AuthState(
        user: clearUser ? null : user ?? this.user,
        token: clearToken ? null : token ?? this.token,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
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

  // ── Session restore ──────────────────────────────────────────────────────────

  Future<void> _restoreSession() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.getToken();
    if (token == null) {
      state = const AuthState();
      return;
    }
    try {
      final user = await ref.read(authServiceProvider).getMe();
      state = AuthState(user: user, token: token);
    } catch (_) {
      // Token expired or invalid — force re-login.
      await storage.clearAll();
      state = const AuthState();
    }
  }

  // ── Login ────────────────────────────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result =
          await ref.read(authServiceProvider).login(email, password);
      await ref.read(secureStorageProvider).saveToken(result.token);
      state = AuthState(user: result.user, token: result.token);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
          isLoading: false, error: 'An unexpected error occurred.');
    }
  }

  // ── Register ─────────────────────────────────────────────────────────────────

  Future<void> register(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await ref.read(authServiceProvider).register(payload);
      await ref.read(secureStorageProvider).saveToken(result.token);
      state = AuthState(user: result.user, token: result.token);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
          isLoading: false, error: 'An unexpected error occurred.');
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await ref.read(secureStorageProvider).clearAll();
    state = const AuthState();
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
