import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'router/app_router.dart';

class TouristPassApp extends ConsumerWidget {
  const TouristPassApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dismiss the native splash as soon as the auth state finishes loading.
    ref.listen<AuthState>(authStateProvider, (prev, next) {
      if ((prev == null || prev.isLoading) && !next.isLoading) {
        FlutterNativeSplash.remove();
      }
    });

    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Tourist Pass Cyprus',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
