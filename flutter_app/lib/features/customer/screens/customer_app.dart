import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/biometric_service.dart';
import 'tabs/discover_tab.dart';
import 'tabs/history_tab.dart';
import 'tabs/qr_tab.dart';
import 'tabs/validate_tab.dart';

class CustomerApp extends ConsumerStatefulWidget {
  const CustomerApp({super.key});

  @override
  ConsumerState<CustomerApp> createState() => _CustomerAppState();
}

class _CustomerAppState extends ConsumerState<CustomerApp> {
  int _tab = 0;
  int? _qrMerchantId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _maybeSuggestBiometric());
  }

  // ── Biometric setup prompt (shown once after first password login) ────────

  Future<void> _maybeSuggestBiometric() async {
    final auth = ref.read(authStateProvider);
    if (!auth.promptBiometricSetup) return;
    ref.read(authStateProvider.notifier).clearPromptBiometricSetup();

    final bio = ref.read(biometricServiceProvider);
    if (!await bio.isAvailable()) return;

    final storage = ref.read(secureStorageProvider);
    if (await storage.isBiometricEnabled()) return;

    if (!mounted) return;
    final label = await bio.label();
    if (!mounted) return;

    final enable = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _BiometricSetupSheet(label: label),
    );

    if (enable == true) {
      await storage.setBiometricEnabled(true);
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _goToQr(int merchantId) {
    setState(() {
      _qrMerchantId = merchantId;
      _tab = 2;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.location_on_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('Tourist Pass'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 48),
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  (user?.firstName.isNotEmpty ?? false)
                      ? user!.firstName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ),
              itemBuilder: (_) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(user?.email ?? '',
                          style: const TextStyle(
                              color: AppColors.surface500, fontSize: 12)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'logout', child: Text('Sign Out')),
              ],
              onSelected: (v) {
                if (v == 'logout') {
                  ref.read(authStateProvider.notifier).logout();
                }
              },
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          const ValidateTab(),
          DiscoverTab(onMerchantQr: _goToQr),
          QrTab(preselectedMerchantId: _qrMerchantId),
          const HistoryTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) {
          if (i != 2) setState(() => _qrMerchantId = null);
          setState(() => _tab = i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.verified_user_outlined),
            selectedIcon: Icon(Icons.verified_user_rounded),
            label: 'My Pass',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_outlined),
            selectedIcon: Icon(Icons.qr_code_2_rounded),
            label: 'QR Code',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

// ─── Biometric setup bottom sheet ────────────────────────────────────────────

class _BiometricSetupSheet extends StatelessWidget {
  const _BiometricSetupSheet({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surface300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.fingerprint_rounded,
                  color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              'Enable $label Sign-In',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.surface800),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in faster next time using $label instead of your password.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.surface500, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Enable $label'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Not now'),
            ),
          ],
        ),
      );
}
