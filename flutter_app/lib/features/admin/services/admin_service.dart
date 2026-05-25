import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

final adminServiceProvider = Provider<AdminService>(
  (ref) => AdminService(ref.watch(dioProvider)),
);

// ── Models ────────────────────────────────────────────────────────────────────

@immutable
class AdminStats {
  const AdminStats({
    required this.totalVolume,
    required this.platformRevenue,
    required this.activeMerchants,
    required this.totalTourists,
    required this.recentTransactions,
  });

  final double totalVolume;
  final double platformRevenue;
  final int activeMerchants;
  final int totalTourists;
  final List<AdminTransaction> recentTransactions;

  factory AdminStats.fromJson(Map<String, dynamic> j) => AdminStats(
        totalVolume: (j['totalVolume'] as num).toDouble(),
        platformRevenue: (j['platformRevenue'] as num).toDouble(),
        activeMerchants: j['activeMerchants'] as int,
        totalTourists: j['totalTourists'] as int,
        recentTransactions: (j['recentTransactions'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(AdminTransaction.fromJson)
            .toList(),
      );
}

@immutable
class AdminTransaction {
  const AdminTransaction({
    required this.id,
    required this.merchantName,
    required this.customerName,
    required this.finalAmount,
    required this.platformFee,
    required this.status,
    required this.createdAt,
    this.originalAmount = 0,
    this.discountAmount = 0,
    this.merchantPayout = 0,
  });

  final int id;
  final String merchantName;
  final String customerName;
  final double finalAmount;
  final double platformFee;
  final String status;
  final DateTime createdAt;
  final double originalAmount;
  final double discountAmount;
  final double merchantPayout;

  factory AdminTransaction.fromJson(Map<String, dynamic> j) => AdminTransaction(
        id: j['id'] as int,
        merchantName: j['merchantName'] as String? ?? '',
        customerName: j['customerName'] as String? ?? '',
        finalAmount: (j['finalAmount'] as num).toDouble(),
        platformFee: (j['platformFee'] as num? ?? 0).toDouble(),
        status: j['status'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        originalAmount: (j['originalAmount'] as num? ?? 0).toDouble(),
        discountAmount: (j['discountAmount'] as num? ?? 0).toDouble(),
        merchantPayout: (j['merchantPayout'] as num? ?? 0).toDouble(),
      );
}

@immutable
class AdminMerchant {
  const AdminMerchant({
    required this.id,
    required this.businessName,
    required this.businessType,
    required this.discountRate,
    required this.status,
    required this.ownerName,
    required this.ownerEmail,
    required this.transactionCount,
    this.city,
    this.platformFeeRate = 10.0,
  });

  final int id;
  final String businessName;
  final String businessType;
  final double discountRate;
  final String status;
  final String ownerName;
  final String ownerEmail;
  final int transactionCount;
  final String? city;
  final double platformFeeRate;

  factory AdminMerchant.fromJson(Map<String, dynamic> j) => AdminMerchant(
        id: j['id'] as int,
        businessName: j['businessName'] as String,
        businessType: j['businessType'] as String,
        discountRate: (j['discountRate'] as num).toDouble(),
        status: j['status'] as String? ?? 'PENDING',
        ownerName: j['ownerName'] as String? ?? '',
        ownerEmail: j['ownerEmail'] as String? ?? '',
        transactionCount: j['transactionCount'] as int? ?? 0,
        city: j['city'] as String?,
        platformFeeRate: (j['platformFeeRate'] as num?)?.toDouble() ?? 10.0,
      );
}

@immutable
class AdminTransactionsPage {
  const AdminTransactionsPage({
    required this.transactions,
    required this.total,
    required this.page,
    required this.perPage,
  });

  final List<AdminTransaction> transactions;
  final int total;
  final int page;
  final int perPage;

  bool get hasMore => page * perPage < total;

  factory AdminTransactionsPage.fromJson(Map<String, dynamic> j) =>
      AdminTransactionsPage(
        transactions: (j['transactions'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(AdminTransaction.fromJson)
            .toList(),
        total: j['total'] as int,
        page: j['page'] as int,
        perPage: j['perPage'] as int,
      );
}

// ── Service ───────────────────────────────────────────────────────────────────

class AdminService {
  const AdminService(this._dio);
  final Dio _dio;

  Future<AdminStats> getStats() async {
    try {
      final res =
          await _dio.get<Map<String, dynamic>>(ApiConstants.adminStats);
      return AdminStats.fromJson(res.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<AdminMerchant>> getMerchants() async {
    try {
      final res = await _dio.get<List<dynamic>>(ApiConstants.adminMerchants);
      return (res.data ?? [])
          .cast<Map<String, dynamic>>()
          .map(AdminMerchant.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<AdminTransactionsPage> getTransactions({int page = 1}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        ApiConstants.adminTransactions,
        queryParameters: {'page': page},
      );
      return AdminTransactionsPage.fromJson(res.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> updateMerchantStatus(int id, String status) async {
    try {
      await _dio.put<void>(
        '${ApiConstants.adminMerchants}/$id/status',
        data: {'status': status},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
