import 'package:flutter/foundation.dart';

@immutable
class PaymentResult {
  const PaymentResult({
    required this.transactionId,
    required this.originalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.platformFee,
    required this.merchantPayout,
    required this.status,
  });

  final int transactionId;
  final double originalAmount;
  final double discountAmount;
  final double finalAmount;
  final double platformFee;
  final double merchantPayout;
  final String status;

  bool get isSuccess => status == 'COMPLETED';

  factory PaymentResult.fromJson(Map<String, dynamic> j) => PaymentResult(
        transactionId: j['transactionId'] as int? ?? j['id'] as int? ?? 0,
        originalAmount: (j['originalAmount'] as num).toDouble(),
        discountAmount: (j['discountAmount'] as num).toDouble(),
        finalAmount: (j['finalAmount'] as num).toDouble(),
        platformFee: (j['platformFee'] as num? ?? 0).toDouble(),
        merchantPayout: (j['merchantPayout'] as num? ?? 0).toDouble(),
        status: j['status'] as String,
      );
}
