import 'package:dio/dio.dart';
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
      return AuthResult(
        token: res.data!['token'] as String,
        user: UserModel.fromJson(res.data!['user'] as Map<String, dynamic>),
      );
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
      return AuthResult(
        token: res.data!['token'] as String,
        user: UserModel.fromJson(res.data!['user'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(ApiConstants.me);
      return UserModel.fromJson(res.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
