import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

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

/// Bridges Riverpod auth state changes to GoRouter's [Listenable] refresh.
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
    // Restore token from secure storage on cold start.
    // Full hydration (GET /auth/me) happens in Phase 2.
    _restoreSession();
    return const AuthState();
  }

  Future<void> _restoreSession() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.getToken();
    if (token != null) {
      // Phase 2 will call /auth/me here and set user.
      state = state.copyWith(token: token, isLoading: false);
    }
  }

  /// Called by Phase 2 login flow after successful WP JWT exchange.
  void setAuthenticated({required UserModel user, required String token}) {
    state = AuthState(user: user, token: token);
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    await storage.clearAll();
    state = const AuthState();
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
