import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../auth/models/user_model.dart';
import '../models/merchant_model.dart';
import '../models/qr_token_model.dart';
import '../models/transaction_model.dart';

final customerServiceProvider = Provider<CustomerService>((ref) {
  return CustomerService(ref.watch(dioProvider));
});

class CustomerService {
  const CustomerService(this._dio);
  final Dio _dio;

  // ── Contract ──────────────────────────────────────────────────────────────

  Future<ContractInfo> validateContract(String contractNumber) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiConstants.rentalValidate,
        data: {'contractNumber': contractNumber},
      );
      return ContractInfo.fromJson(res.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<ContractInfo?> getContractStatus() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        ApiConstants.rentalStatus,
      );
      return ContractInfo.fromJson(res.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw mapDioError(e);
    }
  }

  // ── Merchants ─────────────────────────────────────────────────────────────

  Future<List<Merchant>> getMerchants({
    String? search,
    String? type,
    String? city,
  }) async {
    try {
      final res = await _dio.get<List<dynamic>>(
        ApiConstants.merchants,
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (type != null) 'type': type,
          if (city != null) 'city': city,
        },
      );
      return (res.data ?? [])
          .cast<Map<String, dynamic>>()
          .map(Merchant.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // ── QR Token ──────────────────────────────────────────────────────────────

  Future<QrToken> createQrToken(int merchantId) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiConstants.createQr,
        data: {'merchantId': merchantId},
      );
      return QrToken.fromJson(res.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // ── Transactions ──────────────────────────────────────────────────────────

  Future<List<Transaction>> getTransactions() async {
    try {
      final res = await _dio.get<List<dynamic>>(ApiConstants.transactions);
      return (res.data ?? [])
          .cast<Map<String, dynamic>>()
          .map(Transaction.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
