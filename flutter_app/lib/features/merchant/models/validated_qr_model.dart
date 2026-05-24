import 'package:flutter/foundation.dart';

@immutable
class ValidatedQr {
  const ValidatedQr({
    required this.qrToken,
    required this.customerName,
    required this.discountRate,
    required this.merchantName,
    this.customerId,
  });

  final String qrToken;
  final String customerName;
  final double discountRate;
  final String merchantName;
  final int? customerId;

  double discountAmount(double original) => original * discountRate / 100;
  double finalAmount(double original) => original - discountAmount(original);

  factory ValidatedQr.fromJson(Map<String, dynamic> j) => ValidatedQr(
        qrToken: j['qrToken'] as String,
        customerName: j['customerName'] as String? ?? 'Customer',
        discountRate: ((j['discountRate'] ?? 0) as num).toDouble(),
        merchantName: j['merchantName'] as String? ?? '',
        customerId: j['customerId'] as int?,
      );
}
