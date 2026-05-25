import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

class TouristPassApp extends ConsumerWidget {
  const TouristPassApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Drop the native splash on the first Flutter frame so our animated
    // SplashScreen is immediately visible while auth loads in the background.
    FlutterNativeSplash.remove();

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
