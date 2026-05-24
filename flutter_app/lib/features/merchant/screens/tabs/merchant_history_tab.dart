import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../customer/models/transaction_model.dart';
import '../../providers/merchant_tx_provider.dart';

class MerchantHistoryTab extends ConsumerWidget {
  const MerchantHistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(merchantTxProvider);

    return Container(
      color: AppColors.surface900,
      child: txAsync.when(
        data: (txs) => txs.isEmpty ? _buildEmpty() : _buildList(txs),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.success),
        ),
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
      ),
    );
  }

  Widget _buildList(List<Transaction> txs) {
    final fmtEur = NumberFormat.currency(symbol: '€', decimalDigits: 2);
    final fmtDate = DateFormat('d MMM, HH:mm');

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: txs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final t = txs[i];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface800,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surface700),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: t.statusBg.withAlpha(40),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  t.status == 'COMPLETED'
                      ? Icons.check_rounded
                      : Icons.error_outline_rounded,
                  color: t.statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.merchantName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(fmtDate.format(t.createdAt),
                        style: const TextStyle(
                            color: AppColors.surface400, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(fmtEur.format(t.merchantPayout.isNaN ? t.finalAmount : t.merchantPayout),
                      style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  Text(
                    '${t.discountRate.toInt()}% disc.',
                    style: const TextStyle(
                        color: AppColors.surface500, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 52, color: AppColors.surface600),
            SizedBox(height: 12),
            Text('No transactions yet',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.surface400)),
            SizedBox(height: 4),
            Text('Processed payments will appear here.',
                style: TextStyle(color: AppColors.surface600, fontSize: 13)),
          ],
        ),
      );
}
