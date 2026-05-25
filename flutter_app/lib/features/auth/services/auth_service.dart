import 'package:dio/dio.dart' show Dio, DioException, Options;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(dioProvider));
});

class AuthResult {
  const AuthResult({required this.token, required this.user});
  final String token;
  final UserModel user;
}

class AuthService {
  const AuthService(this._dio);
  final Dio _dio;

  Future<AuthResult> login(String email, String password) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final token = res.data!['token'] as String;
      // Hydrate full user (contract, merchantProfile) via /auth/me.
      final user = await _getMe(token);
      return AuthResult(token: token, user: user);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<AuthResult> register(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiConstants.register,
        data: payload,
      );
      final token = res.data!['token'] as String;
      final user = await _getMe(token);
      return AuthResult(token: token, user: user);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<UserModel> getMe() async {
    try {
      return await _getMe(null);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<UserModel> _getMe(String? overrideToken) async {
    final options = overrideToken != null
        ? Options(headers: {'Authorization': 'Bearer $overrideToken'})
        : null;
    final res = await _dio.get<Map<String, dynamic>>(
      ApiConstants.me,
      options: options,
    );
    return UserModel.fromJson(res.data!);
  }
}
