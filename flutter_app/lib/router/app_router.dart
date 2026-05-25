import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/screens/admin_app.dart';
import '../features/auth/models/user_model.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/auth_screen.dart';
import '../features/customer/screens/customer_app.dart';
import '../features/merchant/screens/merchant_app.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const auth = '/auth';
  static const customer = '/customer';
  static const merchant = '/merchant';
  static const admin = '/admin';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(authChangeNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final loc = state.matchedLocation;

      if (auth.isLoading) return null; // wait for session restore

      final onAuth = loc == AppRoutes.auth;

      if (!auth.isAuthenticated && !onAuth) return AppRoutes.auth;

      if (auth.isAuthenticated && onAuth) {
        return _homeForRole(auth.user!.role);
      }

      // Prevent cross-role access
      if (auth.isAuthenticated) {
        final expected = _homeForRole(auth.user!.role);
        if (!loc.startsWith(expected)) return expected;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const _SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (_, __) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.customer,
        builder: (_, __) => const CustomerApp(),
      ),
      GoRoute(
        path: AppRoutes.merchant,
        builder: (_, __) => const MerchantApp(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (_, __) => const AdminApp(),
      ),
    ],
  );
});

String _homeForRole(UserRole role) => switch (role) {
      UserRole.customer => AppRoutes.customer,
      UserRole.merchant => AppRoutes.merchant,
      UserRole.admin => AppRoutes.admin,
    };

// ─── Internal placeholder screens (removed when each phase lands) ────────────

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FlutterLogo(size: 64),
            const SizedBox(height: 24),
            Text(
              'Tourist Pass Cyprus',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
