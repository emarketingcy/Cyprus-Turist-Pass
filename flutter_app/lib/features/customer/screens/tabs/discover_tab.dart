import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/merchant_model.dart';
import '../../providers/merchant_provider.dart';

class DiscoverTab extends ConsumerStatefulWidget {
  const DiscoverTab({super.key, required this.onMerchantQr});

  final ValueChanged<int> onMerchantQr;

  @override
  ConsumerState<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends ConsumerState<DiscoverTab> {
  final _searchCtrl = TextEditingController();
  String? _selectedType;

  static const _types = [
    null,
    'RESTAURANT',
    'HOTEL',
    'ACTIVITY',
    'TOUR',
    'SPA',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final merchantsAsync = ref.watch(merchantListProvider);

    return Column(
      children: [
        _buildSearchBar(),
        _buildTypeFilters(),
        const Divider(height: 1),
        Expanded(
          child: merchantsAsync.when(
            data: (merchants) => merchants.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: merchants.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _MerchantCard(
                      merchant: merchants[i],
                      onQrTap: () => widget.onMerchantQr(merchants[i].id),
                    ),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _buildError(e.toString()),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: 'Search merchants…',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchCtrl.clear();
                      ref.read(merchantListProvider.notifier).search('');
                    },
                  )
                : null,
          ),
          onChanged: (v) =>
              ref.read(merchantListProvider.notifier).search(v),
        ),
      );

  Widget _buildTypeFilters() => SizedBox(
        height: 44,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: _types.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final t = _types[i];
            final selected = _selectedType == t;
            final label = t == null
                ? 'All'
                : _typeLabel(t);
            return FilterChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) {
                setState(() => _selectedType = t);
                ref.read(merchantListProvider.notifier).filterType(t);
              },
              selectedColor: AppColors.primaryContainer,
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.primary : AppColors.surface600,
              ),
            );
          },
        ),
      );

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_outlined, size: 52, color: AppColors.surface300),
            const SizedBox(height: 12),
            const Text('No merchants found',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.surface600)),
            const SizedBox(height: 4),
            const Text('Try a different search or filter.',
                style: TextStyle(color: AppColors.surface500, fontSize: 13)),
          ],
        ),
      );

  Widget _buildError(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(msg.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error)),
        ),
      );

  String _typeLabel(String t) => switch (t) {
        'RESTAURANT' => 'Restaurant',
        'HOTEL' => 'Hotel',
        'ACTIVITY' => 'Activity',
        'TOUR' => 'Tour',
        'SPA' => 'Spa',
        _ => t,
      };
}

// ─── Merchant card ────────────────────────────────────────────────────────────

class _MerchantCard extends StatelessWidget {
  const _MerchantCard({
    required this.merchant,
    required this.onQrTap,
  });

  final Merchant merchant;
  final VoidCallback onQrTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: merchant.imageUrl != null
                  ? Image.network(
                      merchant.imageUrl!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          merchant.businessName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.surface800),
                        ),
                      ),
                      _DiscountBadge(rate: merchant.discountRate),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: merchant.typeColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          merchant.typeLabel,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: merchant.typeColor),
                        ),
                      ),
                      if (merchant.city != null) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.surface400),
                        const SizedBox(width: 2),
                        Text(merchant.city!,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.surface500)),
                      ],
                    ],
                  ),
                  if (merchant.description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      merchant.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.surface500,
                          height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onQrTap,
                      icon: const Icon(Icons.qr_code_rounded, size: 16),
                      label: const Text('Get QR Code'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 64,
        height: 64,
        color: merchant.typeColor.withAlpha(20),
        child: Icon(Icons.storefront_rounded,
            color: merchant.typeColor.withAlpha(120), size: 30),
      );
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.rate});
  final double rate;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${rate.toInt()}% OFF',
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary),
        ),
      );
}
