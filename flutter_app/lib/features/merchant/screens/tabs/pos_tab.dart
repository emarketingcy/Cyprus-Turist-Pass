import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../models/pos_state.dart';
import '../../providers/pos_provider.dart';

class PosTab extends ConsumerStatefulWidget {
  const PosTab({super.key});

  @override
  ConsumerState<PosTab> createState() => _PosTabState();
}

class _PosTabState extends ConsumerState<PosTab>
    with SingleTickerProviderStateMixin {
  final _scannerCtrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  final _amountCtrl = TextEditingController();
  final _amountFormKey = GlobalKey<FormState>();

  // Flash animation for success / failure feedback
  late final AnimationController _flashCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final Animation<double> _flashOpacity =
      CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut);
  Color _flashColor = AppColors.success;

  PosView? _lastView;

  @override
  void dispose() {
    _scannerCtrl.dispose();
    _amountCtrl.dispose();
    _flashCtrl.dispose();
    super.dispose();
  }

  // ── State-change reactions ────────────────────────────────────────────────

  void _onStateChanged(PosState? prev, PosState next) {
    if (prev?.view == next.view) return;

    if (next.view == PosView.result) {
      if (next.isSuccess) {
        _triggerSuccessFeedback();
      } else {
        _triggerFailFeedback();
      }
    }

    if (next.view == PosView.scan) {
      _amountCtrl.clear();
    }
  }

  void _triggerSuccessFeedback() {
    HapticFeedback.heavyImpact();
    _flashColor = AppColors.success;
    _flashCtrl.forward(from: 0);
  }

  void _triggerFailFeedback() async {
    HapticFeedback.vibrate();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    HapticFeedback.vibrate();
    _flashColor = AppColors.error;
    _flashCtrl.forward(from: 0);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.listen<PosState>(posProvider, _onStateChanged);
    final pos = ref.watch(posProvider);
    final profile = ref.watch(authStateProvider).user?.merchantProfile;
    final isPending = profile?.isPending ?? false;

    return Stack(
      children: [
        // Main body switches on pos.view
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: KeyedSubtree(
            key: ValueKey(pos.view),
            child: switch (pos.view) {
              PosView.scan => _buildScanner(isPending),
              PosView.calculate => _buildCalculate(pos, profile?.platformFeeRate ?? 10.0),
              PosView.processing => _buildProcessing(),
              PosView.result => _buildResult(pos),
            },
          ),
        ),

        // Flash overlay for feedback
        IgnorePointer(
          child: FadeTransition(
            opacity: _flashOpacity,
            child: Container(color: _flashColor.withAlpha(60)),
          ),
        ),

        // Scan error snackbar (non-blocking)
        if (pos.view == PosView.scan && pos.error != null)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: _ErrorToast(message: pos.error!),
          ),
      ],
    );
  }

  // ── Scanner view ──────────────────────────────────────────────────────────

  Widget _buildScanner(bool isPending) => Stack(
        children: [
          if (!isPending)
            MobileScanner(
              controller: _scannerCtrl,
              onDetect: (capture) {
                final raw = capture.barcodes.firstOrNull?.rawValue;
                if (raw != null) {
                  ref.read(posProvider.notifier).onQrDetected(raw);
                }
              },
            )
          else
            Container(color: AppColors.surface900),

          // Scan frame overlay
          CustomPaint(
            painter: _ScanFramePainter(
              frameColor: isPending
                  ? AppColors.warning
                  : AppColors.success,
            ),
            child: const SizedBox.expand(),
          ),

          // Top instructions
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  isPending ? 'Account Pending Approval' : 'Scan Customer QR',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isPending
                      ? 'You cannot process payments until approved by admin.'
                      : 'Point the camera at the tourist\'s discount QR code',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                  ),
                ),
              ],
            ),
          ),

          // Torch toggle (bottom-right)
          if (!isPending)
            Positioned(
              bottom: 32,
              right: 24,
              child: GestureDetector(
                onTap: () => _scannerCtrl.toggleTorch(),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withAlpha(60), width: 1.5),
                  ),
                  child: const Icon(Icons.flashlight_on_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
            ),
        ],
      );

  // ── Calculate view ────────────────────────────────────────────────────────

  Widget _buildCalculate(PosState pos, double platformFeeRate) {
    final qr = pos.validatedQr;

    // Still loading the QR validation
    if (qr == null) {
      return Container(
        color: AppColors.surface900,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.success),
              SizedBox(height: 16),
              Text('Validating QR code…',
                  style: TextStyle(color: AppColors.surface400)),
            ],
          ),
        ),
      );
    }

    return Container(
      color: AppColors.surface900,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _amountFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer badge
              _CustomerBadge(name: qr.customerName, rate: qr.discountRate),
              const SizedBox(height: 20),

              // Amount input
              const Text('Bill Amount (€)',
                  style: TextStyle(
                      color: AppColors.surface400,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  prefixText: '€ ',
                  prefixStyle: const TextStyle(
                      color: AppColors.surface400,
                      fontSize: 32,
                      fontWeight: FontWeight.w700),
                  filled: true,
                  fillColor: AppColors.surface800,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.surface700),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.surface700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppColors.success, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 18),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter the bill amount';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  if (double.parse(v) <= 0) return 'Amount must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Split breakdown (live-computed)
              _buildBreakdown(qr.discountRate, platformFeeRate),
              const SizedBox(height: 24),

              // Action buttons
              ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: const Text('Process Payment'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () =>
                    ref.read(posProvider.notifier).cancelToScan(),
                child: const Text('Cancel',
                    style: TextStyle(color: AppColors.surface400)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdown(double discountRate, double platformFeeRate) {
    final raw = double.tryParse(_amountCtrl.text);
    if (raw == null || raw <= 0) {
      return const SizedBox.shrink();
    }
    final discount = raw * discountRate / 100;
    final finalAmt = raw - discount;
    final fee = finalAmt * platformFeeRate / 100;
    final payout = finalAmt - fee;
    final fmt = NumberFormat.currency(symbol: '€', decimalDigits: 2);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface800,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surface700),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _breakdownRow('Original', fmt.format(raw), AppColors.surface300),
          const SizedBox(height: 10),
          _breakdownRow(
              'Discount (${discountRate.toInt()}%)',
              '- ${fmt.format(discount)}',
              AppColors.primary),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.surface700, height: 1),
          ),
          _breakdownRow('Customer pays', fmt.format(finalAmt), Colors.white,
              large: true),
          const SizedBox(height: 10),
          _breakdownRow(
              'Platform fee (${platformFeeRate.toInt()}%)',
              '- ${fmt.format(fee)}',
              AppColors.surface500),
          const SizedBox(height: 10),
          _breakdownRow(
              'Your payout', fmt.format(payout), AppColors.success,
              large: true),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, String value, Color valueColor,
      {bool large = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppColors.surface400,
                  fontSize: large ? 14 : 13,
                  fontWeight: large ? FontWeight.w600 : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: large ? 16 : 13,
                  fontWeight: large ? FontWeight.w700 : FontWeight.w500)),
        ],
      );

  // ── Processing view ───────────────────────────────────────────────────────

  Widget _buildProcessing() => Container(
        color: AppColors.surface900,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                  color: AppColors.success, strokeWidth: 3),
              SizedBox(height: 20),
              Text('Processing payment…',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 6),
              Text('Please wait',
                  style:
                      TextStyle(color: AppColors.surface400, fontSize: 13)),
            ],
          ),
        ),
      );

  // ── Result view ───────────────────────────────────────────────────────────

  Widget _buildResult(PosState pos) {
    final success = pos.isSuccess;
    final result = pos.result;
    final fmt = NumberFormat.currency(symbol: '€', decimalDigits: 2);

    return Container(
      color: AppColors.surface900,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: success
                      ? AppColors.success.withAlpha(30)
                      : AppColors.error.withAlpha(30),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: success ? AppColors.success : AppColors.error,
                    width: 2,
                  ),
                ),
                child: Icon(
                  success ? Icons.check_rounded : Icons.close_rounded,
                  color: success ? AppColors.success : AppColors.error,
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                success ? 'Payment Successful' : 'Payment Failed',
                style: TextStyle(
                  color: success ? AppColors.success : AppColors.error,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              if (!success && pos.error != null)
                Text(
                  pos.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.surface400, fontSize: 14),
                ),
              if (success && result != null) ...[
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface800,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surface700),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _resultRow('Customer paid',
                          fmt.format(result.finalAmount), Colors.white),
                      const SizedBox(height: 12),
                      _resultRow('Discount given',
                          fmt.format(result.discountAmount),
                          AppColors.primary),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: AppColors.surface700, height: 1),
                      ),
                      _resultRow('Your payout',
                          fmt.format(result.merchantPayout),
                          AppColors.success,
                          large: true),
                      const SizedBox(height: 12),
                      _resultRow('Tx #${result.transactionId}', 'COMPLETED',
                          AppColors.success),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      ref.read(posProvider.notifier).resetAfterResult(),
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text('Scan Next Customer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        success ? AppColors.success : AppColors.surface700,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value, Color valueColor,
      {bool large = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.surface400, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: large ? 18 : 14,
                  fontWeight: large ? FontWeight.w700 : FontWeight.w600)),
        ],
      );

  // ── Process ───────────────────────────────────────────────────────────────

  Future<void> _processPayment() async {
    if (!_amountFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final amount = double.parse(_amountCtrl.text);
    await ref.read(posProvider.notifier).processPayment(amount);
  }
}

// ─── Scan frame painter ───────────────────────────────────────────────────────

class _ScanFramePainter extends CustomPainter {
  const _ScanFramePainter({this.frameColor = AppColors.success});
  final Color frameColor;

  @override
  void paint(Canvas canvas, Size size) {
    const frameSize = 240.0;
    const cornerLen = 28.0;
    const strokeW = 4.0;
    const radius = 12.0;

    final cx = size.width / 2;
    final cy = size.height / 2 - 20; // slightly above center

    final left = cx - frameSize / 2;
    final top = cy - frameSize / 2;
    final right = cx + frameSize / 2;
    final bottom = cy + frameSize / 2;

    // Dark overlay with cutout
    final overlayPaint = Paint()..color = Colors.black.withAlpha(160);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(RRect.fromRectAndRadius(
              Rect.fromLTRB(left, top, right, bottom),
              const Radius.circular(radius))),
      ),
      overlayPaint,
    );

    // Corner brackets
    final paint = Paint()
      ..color = frameColor
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(Offset(left, top + cornerLen), Offset(left, top + radius), paint);
    canvas.drawArc(
        Rect.fromLTWH(left, top, radius * 2, radius * 2),
        3.14, 0.5 * 3.14, false, paint);
    canvas.drawLine(
        Offset(left + radius, top), Offset(left + cornerLen, top), paint);
    // Top-right
    canvas.drawLine(
        Offset(right - cornerLen, top), Offset(right - radius, top), paint);
    canvas.drawArc(
        Rect.fromLTWH(right - radius * 2, top, radius * 2, radius * 2),
        1.5 * 3.14, 0.5 * 3.14, false, paint);
    canvas.drawLine(
        Offset(right, top + radius), Offset(right, top + cornerLen), paint);
    // Bottom-right
    canvas.drawLine(
        Offset(right, bottom - cornerLen), Offset(right, bottom - radius), paint);
    canvas.drawArc(
        Rect.fromLTWH(right - radius * 2, bottom - radius * 2, radius * 2, radius * 2),
        0, 0.5 * 3.14, false, paint);
    canvas.drawLine(
        Offset(right - radius, bottom), Offset(right - cornerLen, bottom), paint);
    // Bottom-left
    canvas.drawLine(
        Offset(left + cornerLen, bottom), Offset(left + radius, bottom), paint);
    canvas.drawArc(
        Rect.fromLTWH(left, bottom - radius * 2, radius * 2, radius * 2),
        0.5 * 3.14, 0.5 * 3.14, false, paint);
    canvas.drawLine(
        Offset(left, bottom - radius), Offset(left, bottom - cornerLen), paint);
  }

  @override
  bool shouldRepaint(_ScanFramePainter old) => old.frameColor != frameColor;
}

// ─── Customer badge ───────────────────────────────────────────────────────────

class _CustomerBadge extends StatelessWidget {
  const _CustomerBadge({required this.name, required this.rate});
  final String name;
  final double rate;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.success.withAlpha(60)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded,
                  color: AppColors.success, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Verified Customer',
                      style: TextStyle(
                          color: AppColors.surface400,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(40),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${rate.toInt()}% OFF',
                style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 14),
              ),
            ),
          ],
        ),
      );
}

// ─── Error toast (non-blocking) ───────────────────────────────────────────────

class _ErrorToast extends StatefulWidget {
  const _ErrorToast({required this.message});
  final String message;

  @override
  State<_ErrorToast> createState() => _ErrorToastState();
}

class _ErrorToastState extends State<_ErrorToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300))
    ..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _ctrl,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: AppColors.error.withAlpha(80),
                  blurRadius: 16,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.error_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(widget.message,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      );
}
