import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pos_state.dart';
import '../services/merchant_service.dart';

class PosNotifier extends AutoDisposeNotifier<PosState> {
  /// Minimum ms between accepted scans — prevents double-reads on same code.
  static const _scanDebounceMs = 1500;

  @override
  PosState build() => const PosState();

  // ── Scan → Validate ──────────────────────────────────────────────────────

  Future<void> onQrDetected(String rawValue) async {
    final now = DateTime.now();

    // Debounce: ignore rapid re-reads of the same frame.
    if (state.lastScanTime != null &&
        now.difference(state.lastScanTime!).inMilliseconds < _scanDebounceMs) {
      return;
    }
    // Only accept new scans from the scan view.
    if (!state.isScanning) return;

    state = state.copyWith(
      view: PosView.calculate,
      lastScanTime: now,
      clearResult: true,
      clearError: true,
      clearQr: true,
    );

    try {
      final qr =
          await ref.read(merchantServiceProvider).validateQr(rawValue);
      state = state.copyWith(validatedQr: qr);
    } on Exception catch (e) {
      state = state.copyWith(
        view: PosView.scan,
        error: e.toString().replaceAll('Exception: ', ''),
        clearQr: true,
      );
    }
  }

  // ── Calculate → Process → Result ────────────────────────────────────────

  Future<void> processPayment(double amount) async {
    final qr = state.validatedQr;
    if (qr == null) return;

    state = state.copyWith(view: PosView.processing);

    try {
      final result = await ref.read(merchantServiceProvider).processPayment(
            qrToken: qr.qrToken,
            originalAmount: amount,
          );
      state = state.copyWith(view: PosView.result, result: result);
    } on Exception catch (e) {
      state = state.copyWith(
        view: PosView.result,
        error: e.toString().replaceAll('Exception: ', ''),
        clearResult: true,
      );
    }
  }

  // ── Navigation ───────────────────────────────────────────────────────────

  void cancelToScan() => state = const PosState();

  void resetAfterResult() => state = const PosState();
}

final posProvider =
    AutoDisposeNotifierProvider<PosNotifier, PosState>(PosNotifier.new);
