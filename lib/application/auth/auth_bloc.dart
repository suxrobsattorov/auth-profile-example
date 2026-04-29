import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:auth_profile_example/domain/interface/auth.dart';
import 'package:auth_profile_example/infrastructure/local/token_storage.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _repository;
  final TokenStorage _storage;

  AuthBloc({required IAuthRepository repository, required TokenStorage storage})
      : _repository = repository,
        _storage = storage,
        super(const AuthInitial()) {
    on<AuthRequestOtp>(_onRequestOtp);
    on<AuthVerifyOtp>(_onVerifyOtp);
  }

  Future<void> _onRequestOtp(
    AuthRequestOtp event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('[AuthBloc] RequestOtp → phone: ${event.phone}');
    emit(const AuthLoading());
    try {
      await _repository.requestOtp(event.phone);
      debugPrint('[AuthBloc] OTP yuborildi ✓');
      emit(const AuthOtpSent());
    } on DioException catch (e) {
      final msg = _extractDioError(e);
      debugPrint('[AuthBloc] DioException: $msg | status: ${e.response?.statusCode}');
      emit(AuthFailure(msg));
    } catch (e, st) {
      debugPrint('[AuthBloc] RequestOtp unknown error: $e\n$st');
      emit(const AuthFailure('Xatolik yuz berdi. Qayta urinib ko\'ring.'));
    }
  }

  Future<void> _onVerifyOtp(
    AuthVerifyOtp event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('[AuthBloc] VerifyOtp → phone: ${event.phone}, code: ${event.code}');
    emit(const AuthLoading());
    try {
      final token = await _repository.verifyOtp(event.phone, event.code);
      await _storage.saveTokens(
        access: token.accessToken,
        refresh: token.refreshToken,
      );
      await _storage.saveUserInfo(
        phone: event.phone,
        countryName: event.countryName,
        flagEmoji: event.flagEmoji,
      );
      debugPrint('[AuthBloc] Auth muvaffaqiyatli ✓ isNewUser: ${token.isNewUser}');
      emit(AuthSuccess(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        isNewUser: token.isNewUser,
      ));
    } on DioException catch (e) {
      final msg = _extractDioError(e);
      debugPrint('[AuthBloc] DioException: $msg | status: ${e.response?.statusCode}');
      emit(AuthFailure(msg));
    } catch (e, st) {
      debugPrint('[AuthBloc] VerifyOtp unknown error: $e\n$st');
      emit(const AuthFailure('Xatolik yuz berdi. Qayta urinib ko\'ring.'));
    }
  }

  String _extractDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('detail')) {
      return data['detail'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Server bilan aloqa yo\'q. Internetni tekshiring.';
    }
    return 'Xatolik yuz berdi. Qayta urinib ko\'ring.';
  }
}
