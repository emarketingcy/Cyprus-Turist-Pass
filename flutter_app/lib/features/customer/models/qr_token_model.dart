import 'package:flutter/foundation.dart';

@immutable
class QrToken {
  const QrToken({
    required this.qrToken,
    required this.merchantId,
    required this.merchantName,
    required this.discountRate,
    required this.expiresAt,
  });

  final String qrToken;
  final int merchantId;
  final String merchantName;
  final double discountRate;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get remaining {
    final d = expiresAt.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  factory QrToken.fromJson(Map<String, dynamic> j) => QrToken(
        qrToken: j['qrToken'] as String,
        merchantId: j['merchantId'] as int? ?? 0,
        merchantName: j['merchantName'] as String,
        discountRate: (j['discountRate'] as num).toDouble(),
        expiresAt: DateTime.parse(j['expiresAt'] as String),
      );
}
