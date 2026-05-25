# Flutter wrapper
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# App entry point — R8 must not rename or strip MainActivity
-keep class com.malaka.touristpass.** { *; }

# Keep local_auth classes
-keep class androidx.biometric.** { *; }

# Keep mobile_scanner / MLKit
-keep class com.google.mlkit.** { *; }

# Keep secure storage
-keep class androidx.security.crypto.** { *; }
