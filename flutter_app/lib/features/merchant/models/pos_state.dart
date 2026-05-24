import 'package:flutter/foundation.dart';

import 'payment_result_model.dart';
import 'validated_qr_model.dart';

enum PosView { scan, calculate, processing, result }

@immutable
class PosState {
  const PosState({
    this.view = PosView.scan,
    this.validatedQr,
    this.result,
    this.error,
    this.lastScanTime,
  });

  final PosView view;
  final ValidatedQr? validatedQr;
  final PaymentResult? result;
  final String? error;

  /// Timestamp of the last accepted scan — guards against duplicate reads.
  final DateTime? lastScanTime;

  bool get isScanning => view == PosView.scan;
  bool get isSuccess => result?.isSuccess == true;

  PosState copyWith({
    PosView? view,
    ValidatedQr? validatedQr,
    PaymentResult? result,
    String? error,
    DateTime? lastScanTime,
    bool clearResult = false,
    bool clearError = false,
    bool clearQr = false,
  }) =>
      PosState(
        view: view ?? this.view,
        validatedQr: clearQr ? null : validatedQr ?? this.validatedQr,
        result: clearResult ? null : result ?? this.result,
        error: clearError ? null : error ?? this.error,
        lastScanTime: lastScanTime ?? this.lastScanTime,
      );
}
