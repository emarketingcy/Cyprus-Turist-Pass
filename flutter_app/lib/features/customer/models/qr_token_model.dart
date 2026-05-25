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
        discountRate: ((j['discountRate'] ?? 0) as num).toDouble(),
        expiresAt: _parseExpiry(j['expiresAt'] as String),
      );

  // The WP server may return a bare 'Y-m-d H:i:s' string with no timezone
  // indicator. PHP's date() uses the server's local timezone (often UTC on
  // shared hosting). Treat any string that carries no offset/Z as UTC so
  // the expiry comparison is correct regardless of the device's timezone.
  static DateTime _parseExpiry(String s) {
    final hasOffset = s.endsWith('Z') ||
        RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(s);
    return DateTime.parse(hasOffset ? s : '${s}Z');
  }
}
