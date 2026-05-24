import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../customer/models/transaction_model.dart';
import '../models/payment_result_model.dart';
import '../models/validated_qr_model.dart';

final merchantServiceProvider = Provider<MerchantService>((ref) {
  return MerchantService(ref.watch(dioProvider));
});

class MerchantService {
  const MerchantService(this._dio);
  final Dio _dio;

  Future<ValidatedQr> validateQr(String qrToken) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiConstants.validateQr,
        data: {'qrToken': qrToken},
      );
      return ValidatedQr.fromJson(res.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<PaymentResult> processPayment({
    required String qrToken,
    required double originalAmount,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiConstants.processPayment,
        data: {
          'qrToken': qrToken,
          'originalAmount': originalAmount,
        },
      );
      return PaymentResult.fromJson(res.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

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

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await _dio.put<dynamic>(ApiConstants.merchantProfile, data: data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
