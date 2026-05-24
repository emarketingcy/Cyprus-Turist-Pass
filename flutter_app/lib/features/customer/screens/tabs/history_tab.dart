import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';

class HistoryTab extends ConsumerWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionListProvider);

    return txAsync.when(
      data: (txs) => txs.isEmpty ? _buildEmpty() : _buildList(txs),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            e.toString().replaceAll('Exception: ', ''),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Transaction> txs) {
    final grouped = <String, List<Transaction>>{};
    for (final t in txs) {
      final key = DateFormat('MMMM yyyy').format(t.createdAt);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: grouped.length,
      itemBuilder: (_, i) {
        final month = grouped.keys.elementAt(i);
        final monthTxs = grouped[month]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                month,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.surface500,
                    letterSpacing: 0.5),
              ),
            ),
            ...monthTxs.map((t) => _TxCard(tx: t)),
          ],
        );
      },
    );
  }

  Widget _buildEmpty() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 52, color: AppColors.surface300),
            SizedBox(height: 12),
            Text('No transactions yet',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.surface600)),
            SizedBox(height: 4),
            Text(
              'Your discount redemptions will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.surface500, fontSize: 13),
            ),
          ],
        ),
      );
}

class _TxCard extends StatelessWidget {
  const _TxCard({required this.tx});
  final Transaction tx;

  @override
  Widget build(BuildContext context) {
    final fmtDate = DateFormat('d MMM, HH:mm').format(tx.createdAt);
    final fmtEur = NumberFormat.currency(symbol: '€', decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    tx.merchantName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.surface800),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tx.statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tx.status,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: tx.statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(fmtDate,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.surface400)),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _amount('Original', fmtEur.format(tx.originalAmount),
                    AppColors.surface600, false),
                const SizedBox(width: 12),
                _amount(
                    'Saved (${tx.discountRate.toInt()}%)',
                    '-${fmtEur.format(tx.discountAmount)}',
                    AppColors.success,
                    false),
                const Spacer(),
                _amount(
                    'You paid',
                    fmtEur.format(tx.finalAmount),
                    AppColors.surface800,
                    true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _amount(String label, String value, Color color, bool bold) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.surface400)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: color),
          ),
        ],
      );
}
