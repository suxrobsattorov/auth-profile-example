import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:auth_profile_example/domain/interface/auth.dart';
import 'package:auth_profile_example/domain/model/auth_token.dart';
import 'package:auth_profile_example/infrastructure/network/dio_client.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final DioClient _dioClient;

  AuthRepositoryImpl(this._dioClient);

  @override
  Future<void> requestOtp(String phone) async {
    await _dioClient.client().post(
      '/api/auth/phone/request/',
      data: {'phone': phone},
    );
  }

  @override
  Future<AuthToken> verifyOtp(String phone, String code) async {
    final response = await _dioClient.client().post(
      '/api/auth/phone/verify/',
      data: {'phone': phone, 'code': code},
    );

    final data = _parseJson(response.data);
    debugPrint('[Repo] verifyOtp parsed data: $data');

    return AuthToken(
      accessToken: data['access'] as String,
      refreshToken: data['refresh'] as String,
      isNewUser: (data['is_new_user'] as bool?) ?? false,
    );
  }

  @override
  Future<AuthToken> refreshSession(String refreshToken) async {
    final response = await _dioClient.client().post(
      '/api/auth/token/refresh/',
      data: {'refresh': refreshToken},
    );

    final data = _parseJson(response.data);

    return AuthToken(
      accessToken: data['access'] as String,
      refreshToken: (data['refresh'] as String?) ?? refreshToken,
      isNewUser: false,
    );
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _dioClient.client(requireAuth: true).post(
      '/api/auth/logout/',
      data: {'refresh': refreshToken},
    );
  }

  Map<String, dynamic> _parseJson(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String) return jsonDecode(raw) as Map<String, dynamic>;
    throw FormatException('Unexpected response type: ${raw.runtimeType}');
  }
}
