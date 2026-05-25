import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

/// Attaches the stored JWT to every request and clears storage on 401.
class AuthInterceptor extends Interceptor {
  const AuthInterceptor(this._storage);

  final SecureStorageService _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Await so storage is fully cleared before the router redirect fires.
      await _storage.clearAll();
    }
    handler.next(err);
  }
}
