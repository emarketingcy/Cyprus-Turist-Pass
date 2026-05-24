import 'package:flutter/material.dart';

/// Design tokens extracted from the React Tailwind source.
abstract final class AppColors {
  // ── Indigo (primary / tourist) ────────────────────────────────────
  static const primary = Color(0xFF4F46E5); // indigo-600
  static const primaryDark = Color(0xFF4338CA); // indigo-700
  static const primaryDeep = Color(0xFF312E81); // indigo-900
  static const primaryLight = Color(0xFFEEF2FF); // indigo-50
  static const primaryContainer = Color(0xFFE0E7FF); // indigo-100

  // ── Slate (surfaces / neutrals) ───────────────────────────────────
  static const surface900 = Color(0xFF0F172A); // slate-900
  static const surface800 = Color(0xFF1E293B); // slate-800
  static const surface700 = Color(0xFF334155); // slate-700
  static const surface600 = Color(0xFF475569); // slate-600
  static const surface500 = Color(0xFF64748B); // slate-500
  static const surface400 = Color(0xFF94A3B8); // slate-400
  static const surface300 = Color(0xFFCBD5E1); // slate-300
  static const surface200 = Color(0xFFE2E8F0); // slate-200
  static const surface100 = Color(0xFFF1F5F9); // slate-100
  static const surface50 = Color(0xFFF8FAFC); // slate-50

  // ── Emerald (success / merchant) ──────────────────────────────────
  static const success = Color(0xFF059669); // emerald-600
  static const successMid = Color(0xFF34D399); // emerald-400 (dark mode)
  static const successLight = Color(0xFFD1FAE5); // emerald-100
  static const successSurface = Color(0xFFECFDF5); // emerald-50

  // ── Amber (warning / admin) ───────────────────────────────────────
  static const warning = Color(0xFFD97706); // amber-600
  static const warningLight = Color(0xFFFEF3C7); // amber-100

  // ── Red (error) ───────────────────────────────────────────────────
  static const error = Color(0xFFDC2626); // red-600
  static const errorLight = Color(0xFFFEE2E2); // red-100

  // ── Business type accents ─────────────────────────────────────────
  static const restaurant = Color(0xFFEA580C); // orange-600
  static const hotel = Color(0xFF2563EB); // blue-600
  static const activity = Color(0xFF059669); // emerald-600
  static const spa = Color(0xFF9333EA); // purple-600
  static const tour = Color(0xFF0891B2); // cyan-600
}

abstract final class AppTheme {
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: Colors.white,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.primaryDeep,
          secondary: AppColors.success,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.successLight,
          onSecondaryContainer: const Color(0xFF064E3B),
          tertiary: AppColors.warning,
          onTertiary: Colors.white,
          tertiaryContainer: AppColors.warningLight,
          onTertiaryContainer: const Color(0xFF78350F),
          error: AppColors.error,
          onError: Colors.white,
          errorContainer: AppColors.errorLight,
          onErrorContainer: const Color(0xFF7F1D1D),
          surface: Colors.white,
          onSurface: AppColors.surface800,
          surfaceContainerHighest: AppColors.surface100,
          outline: AppColors.surface200,
          outlineVariant: AppColors.surface300,
        ),
        scaffoldBackgroundColor: AppColors.surface100,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.surface800,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: AppColors.surface200,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.surface800,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.surface200),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.surface200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.surface200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: const TextStyle(color: AppColors.surface500),
          hintStyle: const TextStyle(color: AppColors.surface400),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surface100,
          selectedColor: AppColors.primaryContainer,
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          side: const BorderSide(color: AppColors.surface200),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.surface400,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primaryContainer,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primary);
            }
            return const IconThemeData(color: AppColors.surface400);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary);
            }
            return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.surface400);
          }),
          elevation: 0,
          shadowColor: AppColors.surface200,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.surface200,
          thickness: 1,
          space: 1,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              color: AppColors.surface800,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5),
          displayMedium: TextStyle(
              color: AppColors.surface800,
              fontWeight: FontWeight.w700,
              letterSpacing: -1),
          displaySmall: TextStyle(
              color: AppColors.surface800,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5),
          headlineLarge: TextStyle(
              color: AppColors.surface800,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5),
          headlineMedium: TextStyle(
              color: AppColors.surface800,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3),
          headlineSmall: TextStyle(
              color: AppColors.surface800, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(
              color: AppColors.surface800, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(
              color: AppColors.surface700, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(
              color: AppColors.surface600, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: AppColors.surface700),
          bodyMedium: TextStyle(color: AppColors.surface600),
          bodySmall: TextStyle(color: AppColors.surface500, fontSize: 12),
          labelLarge: TextStyle(
              color: AppColors.surface700, fontWeight: FontWeight.w500),
          labelMedium: TextStyle(
              color: AppColors.surface600, fontWeight: FontWeight.w500),
          labelSmall: TextStyle(
              color: AppColors.surface500,
              fontWeight: FontWeight.w400,
              fontSize: 11),
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: const Color(0xFF818CF8), // indigo-400
          onPrimary: AppColors.surface900,
          primaryContainer: const Color(0xFF3730A3), // indigo-800
          onPrimaryContainer: const Color(0xFFE0E7FF),
          secondary: AppColors.successMid, // emerald-400
          onSecondary: AppColors.surface900,
          secondaryContainer: const Color(0xFF065F46),
          onSecondaryContainer: AppColors.successLight,
          tertiary: const Color(0xFFFBBF24), // amber-400
          onTertiary: AppColors.surface900,
          tertiaryContainer: const Color(0xFF92400E),
          onTertiaryContainer: AppColors.warningLight,
          error: const Color(0xFFF87171), // red-400
          onError: AppColors.surface900,
          errorContainer: const Color(0xFF7F1D1D),
          onErrorContainer: AppColors.errorLight,
          surface: AppColors.surface800,
          onSurface: AppColors.surface100,
          surfaceContainerHighest: AppColors.surface700,
          outline: AppColors.surface700,
          outlineVariant: AppColors.surface600,
        ),
        scaffoldBackgroundColor: AppColors.surface900,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface800,
          foregroundColor: AppColors.surface100,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface800,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.surface700),
          ),
          margin: EdgeInsets.zero,
        ),
      );
}
