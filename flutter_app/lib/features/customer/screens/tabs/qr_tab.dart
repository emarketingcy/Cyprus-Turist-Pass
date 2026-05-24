import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/merchant_model.dart';
import '../../models/qr_token_model.dart';
import '../../providers/contract_provider.dart';
import '../../providers/merchant_provider.dart';
import '../../providers/qr_provider.dart';

class QrTab extends ConsumerStatefulWidget {
  const QrTab({super.key, this.preselectedMerchantId});

  final int? preselectedMerchantId;

  @override
  ConsumerState<QrTab> createState() => _QrTabState();
}

class _QrTabState extends ConsumerState<QrTab> with WidgetsBindingObserver {
  int? _merchantId;
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _merchantId = widget.preselectedMerchantId;
  }

  @override
  void didUpdateWidget(QrTab old) {
    super.didUpdateWidget(old);
    if (widget.preselectedMerchantId != old.preselectedMerchantId &&
        widget.preselectedMerchantId != null) {
      setState(() => _merchantId = widget.preselectedMerchantId);
      // Auto-generate when merchant is set from Discover tab.
      WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Disable wakelock when app is backgrounded.
    if (state != AppLifecycleState.resumed) {
      WakelockPlus.disable();
    } else {
      final qr = ref.read(qrProvider).valueOrNull;
      if (qr != null && !qr.isExpired) WakelockPlus.enable();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ── Timer ────────────────────────────────────────────────────────────────

  void _startTimer(QrToken token) {
    _timer?.cancel();
    _remaining = token.remaining;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = token.remaining);
      if (_remaining == Duration.zero) {
        _timer?.cancel();
        WakelockPlus.disable();
      }
    });
  }

  // ── Generate ─────────────────────────────────────────────────────────────

  Future<void> _generate() async {
    if (_merchantId == null) return;
    await ref.read(qrProvider.notifier).generate(_merchantId!);
    final token = ref.read(qrProvider).valueOrNull;
    if (token != null) {
      WakelockPlus.enable();
      _startTimer(token);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final contractAsync = ref.watch(contractProvider);
    final qrAsync = ref.watch(qrProvider);
    final merchantsAsync = ref.watch(merchantListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          contractAsync.when(
            data: (contract) {
              if (contract == null || !contract.isValid) {
                return _buildNoContractBanner();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  merchantsAsync.when(
                    data: (merchants) => _buildMerchantPicker(merchants),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                  if (_merchantId != null)
                    qrAsync.when(
                      data: (token) => token != null
                          ? _buildQrDisplay(token)
                          : _buildGenerateButton(),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (e, _) => _buildErrorCard(e.toString()),
                    )
                  else
                    _buildPickHint(),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _buildNoContractBanner(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QR Code',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.surface800,
                letterSpacing: -0.3),
          ),
          const SizedBox(height: 4),
          const Text(
            'Show this to the merchant cashier to redeem your discount.',
            style: TextStyle(color: AppColors.surface500, fontSize: 14),
          ),
        ],
      );

  Widget _buildNoContractBanner() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warningLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withAlpha(60)),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: AppColors.warning, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Validate your rental contract on the My Pass tab first.',
                style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );

  Widget _buildMerchantPicker(List<Merchant> merchants) {
    if (merchants.isEmpty) return const SizedBox.shrink();
    return DropdownButtonFormField<int>(
      value: _merchantId,
      decoration: const InputDecoration(
        labelText: 'Select Merchant',
        prefixIcon: Icon(Icons.storefront_rounded),
      ),
      items: merchants
          .map((m) => DropdownMenuItem(
                value: m.id,
                child: Text('${m.businessName} — ${m.discountRate.toInt()}% off'),
              ))
          .toList(),
      onChanged: (v) {
        setState(() {
          _merchantId = v;
          ref.read(qrProvider.notifier).clear();
          _timer?.cancel();
          WakelockPlus.disable();
        });
      },
    );
  }

  Widget _buildPickHint() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surface200),
        ),
        child: const Column(
          children: [
            Icon(Icons.touch_app_rounded, size: 40, color: AppColors.surface300),
            SizedBox(height: 10),
            Text(
              'Select a merchant above to generate your QR code.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.surface500, fontSize: 13),
            ),
          ],
        ),
      );

  Widget _buildGenerateButton() => ElevatedButton.icon(
        onPressed: _generate,
        icon: const Icon(Icons.qr_code_2_rounded),
        label: const Text('Generate QR Code'),
      );

  Widget _buildQrDisplay(QrToken token) {
    final expired = token.isExpired || _remaining == Duration.zero;
    final minutes = _remaining.inMinutes;
    final seconds = _remaining.inSeconds % 60;
    final timerStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: expired ? AppColors.error : AppColors.success,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (expired ? AppColors.error : AppColors.success)
                    .withAlpha(30),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                token.merchantName,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.surface800),
              ),
              const SizedBox(height: 4),
              Text(
                '${token.discountRate.toInt()}% Discount',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
              const SizedBox(height: 20),
              if (expired)
                _buildExpiredOverlay()
              else
                QrImageView(
                  data: token.qrToken,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                ),
              const SizedBox(height: 16),
              if (!expired)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: _remaining.inMinutes < 3
                          ? AppColors.error
                          : AppColors.surface500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Expires in $timerStr',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _remaining.inMinutes < 3
                            ? AppColors.error
                            : AppColors.surface500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (expired)
          ElevatedButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Generate New Code'),
          ),
      ],
    );
  }

  Widget _buildExpiredOverlay() => Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer_off_rounded, color: AppColors.error, size: 48),
            SizedBox(height: 8),
            Text(
              'Code Expired',
              style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 16),
            ),
          ],
        ),
      );

  Widget _buildErrorCard(String msg) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withAlpha(60)),
        ),
        child: Text(
          msg.replaceAll('Exception: ', ''),
          style: const TextStyle(color: AppColors.error, fontSize: 13),
        ),
      );
}
