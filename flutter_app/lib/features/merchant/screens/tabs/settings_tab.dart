import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({super.key});

  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<SettingsTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  double _rate = 10.0;
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initFromProfile();
  }

  void _initFromProfile() {
    if (_initialized) return;
    final profile = ref.read(authStateProvider).user?.merchantProfile;
    if (profile == null) return;
    setState(() {
      _nameCtrl.text = profile.businessName;
      _descCtrl.text = profile.description ?? '';
      _rate = profile.discountRate.clamp(5.0, 50.0);
      _initialized = true;
    });
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await ref.read(settingsProvider.notifier).save(
          businessName: _nameCtrl.text.trim(),
          discountRate: _rate,
          description:
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final profile = ref.watch(authStateProvider).user?.merchantProfile;

    return Container(
      color: AppColors.surface900,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionHeader(Icons.tune_rounded, 'Merchant Settings'),
              const SizedBox(height: 20),

              // ── Logo ───────────────────────────────────────────────────
              _sectionLabel('Business Logo'),
              const SizedBox(height: 12),
              _buildLogoSection(settings, profile?.imageUrl),
              const SizedBox(height: 24),

              // ── Business info ──────────────────────────────────────────
              _sectionLabel('Business Information'),
              const SizedBox(height: 12),
              _buildInfoCard(settings),
              const SizedBox(height: 24),

              // ── Menu ───────────────────────────────────────────────────
              _sectionLabel('Menu / Brochure'),
              const SizedBox(height: 12),
              _buildMenuSection(settings, profile?.menuUrl),
              const SizedBox(height: 28),

              // ── Feedback ───────────────────────────────────────────────
              if (settings.error != null) ...[
                _buildErrorBanner(settings.error!),
                const SizedBox(height: 16),
              ],
              if (settings.isSuccess) ...[
                _buildSuccessBanner(),
                const SizedBox(height: 16),
              ],

              // ── Save button ────────────────────────────────────────────
              ElevatedButton(
                onPressed: settings.isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  disabledBackgroundColor: AppColors.surface700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: settings.isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Save Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Logo section ──────────────────────────────────────────────────────────

  Widget _buildLogoSection(SettingsState settings, String? currentUrl) {
    return Row(
      children: [
        // Logo preview
        GestureDetector(
          onTap: () => _showLogoOptions(settings),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _logoImage(settings.logoFile?.path, currentUrl),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_rounded,
                      color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tap the image to change your logo',
                style:
                    TextStyle(color: AppColors.surface400, fontSize: 13),
              ),
              const SizedBox(height: 6),
              const Text(
                'Recommended: 512×512 px, JPG or PNG',
                style:
                    TextStyle(color: AppColors.surface600, fontSize: 12),
              ),
              if (settings.logoFile != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 14),
                    const SizedBox(width: 4),
                    const Text(
                      'New logo selected',
                      style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () =>
                          ref.read(settingsProvider.notifier).clearLogo(),
                      child: const Text('Remove',
                          style: TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _logoImage(String? localPath, String? networkUrl) {
    if (localPath != null) {
      return Image.file(
        File(localPath),
        width: 88,
        height: 88,
        fit: BoxFit.cover,
      );
    }
    if (networkUrl != null && networkUrl.isNotEmpty) {
      return Image.network(
        networkUrl,
        width: 88,
        height: 88,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _logoPlaceholder(),
      );
    }
    return _logoPlaceholder();
  }

  Widget _logoPlaceholder() => Container(
        width: 88,
        height: 88,
        color: AppColors.surface800,
        child: const Icon(Icons.storefront_rounded,
            color: AppColors.surface600, size: 40),
      );

  void _showLogoOptions(SettingsState settings) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface800,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surface600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _sheetTile(Icons.photo_library_rounded, 'Choose from Gallery',
                () {
              Navigator.pop(context);
              ref.read(settingsProvider.notifier).pickLogo();
            }),
            _sheetTile(Icons.camera_alt_rounded, 'Take a Photo', () {
              Navigator.pop(context);
              ref.read(settingsProvider.notifier).pickLogoCamera();
            }),
            if (settings.logoFile != null)
              _sheetTile(Icons.delete_outline_rounded, 'Remove selected',
                  () {
                Navigator.pop(context);
                ref.read(settingsProvider.notifier).clearLogo();
              }, color: AppColors.error),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sheetTile(IconData icon, String label, VoidCallback onTap,
      {Color? color}) =>
      ListTile(
        leading: Icon(icon, color: color ?? Colors.white),
        title:
            Text(label, style: TextStyle(color: color ?? Colors.white)),
        onTap: onTap,
      );

  // ── Business info card ────────────────────────────────────────────────────

  Widget _buildInfoCard(SettingsState settings) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface800,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surface700),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business name
            _darkField(
              ctrl: _nameCtrl,
              label: 'Shop Name',
              hint: 'Your business name',
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Shop name is required'
                  : null,
            ),
            const SizedBox(height: 16),

            // Discount rate slider
            _buildRateSlider(),
            const SizedBox(height: 16),

            // Description
            _darkField(
              ctrl: _descCtrl,
              label: 'Description (optional)',
              hint: 'Short description shown to tourists',
              maxLines: 3,
            ),
          ],
        ),
      );

  Widget _buildRateSlider() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Discount Commission',
                  style: TextStyle(
                      color: AppColors.surface400,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withAlpha(60)),
                ),
                child: Text(
                  '${_rate.toInt()}%',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surface700,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withAlpha(30),
              valueIndicatorColor: AppColors.primary,
              trackHeight: 4,
            ),
            child: Slider(
              value: _rate,
              min: 5,
              max: 50,
              divisions: 45,
              label: '${_rate.toInt()}%',
              onChanged: (v) => setState(() => _rate = v),
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('5% min',
                  style: TextStyle(
                      color: AppColors.surface600, fontSize: 11)),
              Text('50% max',
                  style: TextStyle(
                      color: AppColors.surface600, fontSize: 11)),
            ],
          ),
        ],
      );

  // ── Menu section ──────────────────────────────────────────────────────────

  Widget _buildMenuSection(SettingsState settings, String? currentMenuUrl) =>
      GestureDetector(
        onTap: () => ref.read(settingsProvider.notifier).pickMenu(),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface800,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: settings.menuFile != null
                  ? AppColors.success.withAlpha(80)
                  : AppColors.surface700,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: settings.menuFile != null
                      ? AppColors.success.withAlpha(30)
                      : AppColors.surface700,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  settings.menuFile != null
                      ? Icons.description_rounded
                      : Icons.upload_file_rounded,
                  color: settings.menuFile != null
                      ? AppColors.success
                      : AppColors.surface400,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settings.menuFile != null
                          ? settings.menuFileName ?? 'File selected'
                          : currentMenuUrl != null
                              ? 'Menu uploaded — tap to replace'
                              : 'Upload Menu / Brochure',
                      style: TextStyle(
                        color: settings.menuFile != null
                            ? AppColors.success
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'PDF, JPG or PNG accepted',
                      style: TextStyle(
                          color: AppColors.surface500, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (settings.menuFile != null)
                GestureDetector(
                  onTap: () =>
                      ref.read(settingsProvider.notifier).clearMenu(),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.surface400, size: 20),
                )
              else
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.surface600),
            ],
          ),
        ),
      );

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionHeader(IconData icon, String title) => Row(
        children: [
          Icon(icon, color: AppColors.success, size: 22),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3),
          ),
        ],
      );

  Widget _sectionLabel(String label) => Text(
        label,
        style: const TextStyle(
            color: AppColors.surface400,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5),
      );

  Widget _darkField({
    required TextEditingController ctrl,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: AppColors.surface400),
          hintStyle: const TextStyle(color: AppColors.surface600),
          filled: true,
          fillColor: AppColors.surface900,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.surface700),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.surface700),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.success, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        validator: validator,
      );

  Widget _buildErrorBanner(String msg) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withAlpha(60)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg,
                  style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                      height: 1.4)),
            ),
          ],
        ),
      );

  Widget _buildSuccessBanner() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.success.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withAlpha(60)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 18),
            SizedBox(width: 10),
            Text('Settings saved successfully.',
                style: TextStyle(
                    color: AppColors.success,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
}
