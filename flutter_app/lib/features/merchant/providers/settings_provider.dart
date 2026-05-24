import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/providers/auth_provider.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../services/merchant_service.dart';

@immutable
class SettingsState {
  const SettingsState({
    this.isSaving = false,
    this.isSuccess = false,
    this.error,
    this.logoFile,
    this.menuFile,
    this.menuFileName,
  });

  final bool isSaving;
  final bool isSuccess;
  final String? error;

  /// Newly picked logo (not yet saved).
  final XFile? logoFile;

  /// Newly picked menu file path (not yet saved).
  final String? menuFile;

  /// Display name for the picked menu file.
  final String? menuFileName;

  SettingsState copyWith({
    bool? isSaving,
    bool? isSuccess,
    String? error,
    XFile? logoFile,
    String? menuFile,
    String? menuFileName,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearLogo = false,
    bool clearMenu = false,
  }) =>
      SettingsState(
        isSaving: isSaving ?? this.isSaving,
        isSuccess: isSuccess ?? this.isSuccess,
        error: clearError ? null : error ?? this.error,
        logoFile: clearLogo ? null : logoFile ?? this.logoFile,
        menuFile: clearMenu ? null : menuFile ?? this.menuFile,
        menuFileName: clearMenu ? null : menuFileName ?? this.menuFileName,
      );
}

class SettingsNotifier extends AutoDisposeNotifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  // ── File pickers ─────────────────────────────────────────────────────────

  Future<void> pickLogo() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (file != null) {
      state = state.copyWith(logoFile: file, clearSuccess: true);
    }
  }

  Future<void> pickLogoCamera() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (file != null) {
      state = state.copyWith(logoFile: file, clearSuccess: true);
    }
  }

  Future<void> pickMenu() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      state = state.copyWith(
        menuFile: file.path,
        menuFileName: file.name,
        clearSuccess: true,
      );
    }
  }

  void clearLogo() => state = state.copyWith(clearLogo: true);
  void clearMenu() => state = state.copyWith(clearMenu: true);

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> save({
    required String businessName,
    required double discountRate,
    String? description,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true, clearSuccess: true);

    try {
      await ref.read(merchantServiceProvider).updateProfile(
            businessName: businessName,
            discountRate: discountRate,
            description: description,
            logoPath: state.logoFile?.path,
            menuPath: state.menuFile,
          );

      // Refresh user from /auth/me so MerchantProfile reflects new data.
      final token = await ref.read(secureStorageProvider).getToken();
      if (token != null) {
        try {
          final user = await ref.read(authServiceProvider).getMe();
          ref.read(authStateProvider.notifier).setAuthenticated(
                user: user,
                token: token,
              );
        } catch (_) {}
      }

      state = state.copyWith(
        isSaving: false,
        isSuccess: true,
        clearLogo: true,
        clearMenu: true,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isSaving: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
          isSaving: false, error: 'Failed to save settings.');
    }
  }
}

final settingsProvider =
    AutoDisposeNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
