import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return _buildDio(storage);
});

Dio _buildDio(SecureStorageService storage) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.apiBase,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(storage),
    LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (o) => dev.log(o.toString(), name: 'Dio'),
    ),
  ]);

  return dio;
}

/// Thrown when the WP API returns a non-2xx response.
class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Converts a [DioException] into a user-facing [ApiException].
ApiException mapDioError(DioException e) {
  final data = e.response?.data;
  final serverMsg = data is Map ? data['message'] as String? : null;
  return ApiException(
    message: serverMsg ?? e.message ?? 'An unexpected error occurred.',
    statusCode: e.response?.statusCode,
  );
}
