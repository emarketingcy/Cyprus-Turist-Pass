import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/admin_providers.dart';
import '../services/admin_service.dart';

class AdminApp extends ConsumerStatefulWidget {
  const AdminApp({super.key});

  @override
  ConsumerState<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends ConsumerState<AdminApp> {
  int _tab = 0;

  static const _tabs = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard_rounded),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.storefront_outlined),
      selectedIcon: Icon(Icons.storefront_rounded),
      label: 'Merchants',
    ),
    NavigationDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long_rounded),
      label: 'Transactions',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface900,
      appBar: AppBar(
        backgroundColor: AppColors.surface800,
        title: const Text('Admin Panel',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.surface400),
            tooltip: 'Logout',
            onPressed: () =>
                ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: const [
          _DashboardTab(),
          _MerchantsTab(),
          _TransactionsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface800,
        indicatorColor: AppColors.primary.withAlpha(40),
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: _tabs,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w400,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.surface400,
          ),
        ),
      ),
    );
  }
}

// ── Dashboard ─────────────────────────────────────────────────────────────────

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return statsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => _ErrorView(
        message: e.toString().replaceAll('Exception: ', ''),
        onRetry: () => ref.invalidate(adminStatsProvider),
      ),
      data: (stats) => RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => ref.invalidate(adminStatsProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            const _SectionHeader('Overview'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Volume',
                    value: '€${stats.totalVolume.toStringAsFixed(0)}',
                    icon: Icons.bar_chart_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Revenue',
                    value: '€${stats.platformRevenue.toStringAsFixed(0)}',
                    icon: Icons.trending_up_rounded,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Merchants',
                    value: '${stats.activeMerchants}',
                    icon: Icons.storefront_rounded,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Tourists',
                    value: '${stats.totalTourists}',
                    icon: Icons.people_rounded,
                    color: AppColors.activity,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const _SectionHeader('Recent Transactions'),
            const SizedBox(height: 12),
            if (stats.recentTransactions.isEmpty)
              const _EmptyHint('No transactions yet.')
            else
              ...stats.recentTransactions.map(_TxRow.new),
          ],
        ),
      ),
    );
  }
}

// ── Merchants ─────────────────────────────────────────────────────────────────

class _MerchantsTab extends ConsumerStatefulWidget {
  const _MerchantsTab();

  @override
  ConsumerState<_MerchantsTab> createState() => _MerchantsTabState();
}

class _MerchantsTabState extends ConsumerState<_MerchantsTab> {
  bool _working = false;

  Future<void> _setStatus(int id, String status) async {
    setState(() => _working = true);
    try {
      await ref.read(adminServiceProvider).updateMerchantStatus(id, status);
      ref.invalidate(adminMerchantsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final merchantsAsync = ref.watch(adminMerchantsProvider);

    return merchantsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => _ErrorView(
        message: e.toString().replaceAll('Exception: ', ''),
        onRetry: () => ref.invalidate(adminMerchantsProvider),
      ),
      data: (merchants) => Stack(
        children: [
          RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(adminMerchantsProvider),
            child: merchants.isEmpty
                ? const CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                          child: _EmptyHint('No merchants found.')),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: merchants.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _MerchantCard(
                      merchant: merchants[i],
                      onApprove: _working
                          ? null
                          : () => _setStatus(merchants[i].id, 'APPROVED'),
                      onReject: _working
                          ? null
                          : () => _setStatus(merchants[i].id, 'REJECTED'),
                      onSuspend: _working
                          ? null
                          : () => _setStatus(merchants[i].id, 'SUSPENDED'),
                    ),
                  ),
          ),
          if (_working)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x55000000),
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Transactions ──────────────────────────────────────────────────────────────

class _TransactionsTab extends ConsumerWidget {
  const _TransactionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(adminTransactionsProvider);

    return txAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => _ErrorView(
        message: e.toString().replaceAll('Exception: ', ''),
        onRetry: () => ref.invalidate(adminTransactionsProvider),
      ),
      data: (page) => RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => ref.invalidate(adminTransactionsProvider),
        child: page.transactions.isEmpty
            ? const CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                      child: _EmptyHint('No transactions found.')),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                itemCount: page.transactions.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Showing ${page.transactions.length} of ${page.total}',
                        style: const TextStyle(
                            color: AppColors.surface500, fontSize: 12),
                      ),
                    );
                  }
                  return _TxRow(page.transactions[i - 1]);
                },
              ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface800,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surface700),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.surface400, fontSize: 11)),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      );
}

class _TxRow extends StatelessWidget {
  const _TxRow(this.tx);
  final AdminTransaction tx;

  static final _fmtEur =
      NumberFormat.currency(symbol: '€', decimalDigits: 2);
  static final _fmtDate = DateFormat('d MMM, HH:mm');

  Color get _statusColor => switch (tx.status) {
        'COMPLETED' => AppColors.success,
        'PENDING' => AppColors.warning,
        _ => AppColors.error,
      };

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface800,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surface700),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _statusColor.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                tx.status == 'COMPLETED'
                    ? Icons.check_rounded
                    : Icons.error_outline_rounded,
                color: _statusColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.merchantName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  Text(tx.customerName,
                      style: const TextStyle(
                          color: AppColors.surface400, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_fmtEur.format(tx.finalAmount),
                    style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                Text(_fmtDate.format(tx.createdAt.toLocal()),
                    style: const TextStyle(
                        color: AppColors.surface500, fontSize: 10)),
              ],
            ),
          ],
        ),
      );
}

class _MerchantCard extends StatelessWidget {
  const _MerchantCard({
    required this.merchant,
    this.onApprove,
    this.onReject,
    this.onSuspend,
  });

  final AdminMerchant merchant;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onSuspend;

  Color get _statusColor => switch (merchant.status) {
        'APPROVED' => AppColors.success,
        'PENDING' => AppColors.warning,
        'SUSPENDED' => AppColors.error,
        _ => AppColors.surface500,
      };

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface800,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surface700),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(merchant.businessName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(
                          '${merchant.ownerName} · ${merchant.businessType}'
                          '${merchant.city != null ? ' · ${merchant.city}' : ''}',
                          style: const TextStyle(
                              color: AppColors.surface400, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(merchant.status,
                      style: TextStyle(
                          color: _statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.percent_rounded,
                    size: 13, color: AppColors.surface500),
                const SizedBox(width: 4),
                Text('${merchant.discountRate.toInt()}% discount',
                    style: const TextStyle(
                        color: AppColors.surface400, fontSize: 12)),
                const SizedBox(width: 16),
                Icon(Icons.receipt_outlined,
                    size: 13, color: AppColors.surface500),
                const SizedBox(width: 4),
                Text('${merchant.transactionCount} tx',
                    style: const TextStyle(
                        color: AppColors.surface400, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                if (merchant.status != 'APPROVED')
                  _ActionButton(
                    label: 'Approve',
                    color: AppColors.success,
                    onPressed: onApprove,
                  ),
                if (merchant.status != 'SUSPENDED')
                  _ActionButton(
                    label: 'Suspend',
                    color: AppColors.warning,
                    onPressed: onSuspend,
                  ),
                if (merchant.status != 'REJECTED')
                  _ActionButton(
                    label: 'Reject',
                    color: AppColors.error,
                    onPressed: onReject,
                  ),
              ],
            ),
          ],
        ),
      );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withAlpha(120)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      );
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined,
                size: 48, color: AppColors.surface600),
            const SizedBox(height: 12),
            Text(message,
                style: const TextStyle(
                    color: AppColors.surface400, fontSize: 14)),
          ],
        ),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
}
