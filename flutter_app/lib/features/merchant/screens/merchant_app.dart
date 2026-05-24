import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import 'tabs/merchant_history_tab.dart';
import 'tabs/pos_tab.dart';

class MerchantApp extends ConsumerStatefulWidget {
  const MerchantApp({super.key});

  @override
  ConsumerState<MerchantApp> createState() => _MerchantAppState();
}

class _MerchantAppState extends ConsumerState<MerchantApp> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final profile = user?.merchantProfile;
    final isPending = profile?.isPending ?? false;

    return Scaffold(
      backgroundColor: AppColors.surface900,
      appBar: AppBar(
        backgroundColor: AppColors.surface900,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.storefront_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.businessName ?? 'Merchant POS',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isPending)
                    const Text(
                      'PENDING APPROVAL',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFBBF24), // amber-400
                          letterSpacing: 0.5),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 48),
              color: AppColors.surface800,
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.success.withAlpha(40),
                child: Text(
                  profile?.businessName.isNotEmpty == true
                      ? profile!.businessName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: AppColors.success,
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
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                      Text(user?.email ?? '',
                          style: const TextStyle(
                              color: AppColors.surface400, fontSize: 12)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                    value: 'logout',
                    child: Text('Sign Out',
                        style: TextStyle(color: Colors.white))),
              ],
              onSelected: (v) {
                if (v == 'logout') ref.read(authStateProvider.notifier).logout();
              },
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          const PosTab(),
          const MerchantHistoryTab(),
          // Settings placeholder — replaced in Phase 5
          const _SettingsPlaceholder(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface800,
        indicatorColor: AppColors.success.withAlpha(40),
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined, color: AppColors.surface400),
            selectedIcon:
                Icon(Icons.qr_code_scanner_rounded, color: AppColors.success),
            label: 'POS',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined, color: AppColors.surface400),
            selectedIcon:
                Icon(Icons.receipt_long_rounded, color: AppColors.success),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined, color: AppColors.surface400),
            selectedIcon: Icon(Icons.tune_rounded, color: AppColors.success),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _SettingsPlaceholder extends StatelessWidget {
  const _SettingsPlaceholder();

  @override
  Widget build(BuildContext context) => const Center(
        child: Text('Settings — Phase 5',
            style: TextStyle(color: AppColors.surface400)),
      );
}
