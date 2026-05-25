import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

@immutable
class Transaction {
  const Transaction({
    required this.id,
    required this.merchantName,
    required this.customerName,
    required this.originalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.discountRate,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String merchantName;
  final String customerName;
  final double originalAmount;
  final double discountAmount;
  final double finalAmount;
  final double discountRate;
  final String status;
  final DateTime createdAt;

  Color get statusColor => switch (status) {
        'COMPLETED' => AppColors.success,
        'PENDING' => AppColors.warning,
        'FAILED' || 'CANCELLED' => AppColors.error,
        _ => AppColors.surface500,
      };

  Color get statusBg => switch (status) {
        'COMPLETED' => AppColors.successLight,
        'PENDING' => AppColors.warningLight,
        'FAILED' || 'CANCELLED' => AppColors.errorLight,
        _ => AppColors.surface100,
      };

  factory Transaction.fromJson(Map<String, dynamic> j) => Transaction(
        id: j['id'] as int,
        merchantName: j['merchantName'] as String? ?? '',
        customerName: j['customerName'] as String? ?? '',
        originalAmount: (j['originalAmount'] as num).toDouble(),
        discountAmount: (j['discountAmount'] as num).toDouble(),
        finalAmount: (j['finalAmount'] as num).toDouble(),
        discountRate: (j['discountRate'] as num).toDouble(),
        status: j['status'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}
