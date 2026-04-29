import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:auth_profile_example/domain/interface/auth.dart';
import 'package:auth_profile_example/domain/interface/google_auth.dart';
import 'package:auth_profile_example/domain/interface/profile.dart';
import 'package:auth_profile_example/domain/model/google_auth_credential.dart';
import 'package:auth_profile_example/domain/model/user_profile.dart';
import 'package:auth_profile_example/infrastructure/auth/google_auth_service_impl.dart';
import 'package:auth_profile_example/infrastructure/local/token_storage.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const _refreshInterval = Duration(minutes: 30);
  static const _googleFallbackCountry = 'Google';
  static const _googleFallbackFlag = '🌐';

  final IAuthRepository _repository;
  final GoogleAuthService _googleAuthService;
  final IProfileRepository _profileRepository;
  final TokenStorage _storage;
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  AuthBloc({
    required IAuthRepository repository,
    required GoogleAuthService googleAuthService,
    required IProfileRepository profileRepository,
    required TokenStorage storage,
  })  : _repository = repository,
        _googleAuthService = googleAuthService,
        _profileRepository = profileRepository,
        _storage = storage,
        super(const AuthInitial()) {
    on<AuthRequestOtp>(_onRequestOtp);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthVerifyOtp>(_onVerifyOtp);
    on<AuthSessionMonitoringStarted>(_onSessionMonitoringStarted);
    on<AuthSessionRefreshRequested>(_onSessionRefreshRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onRequestOtp(
    AuthRequestOtp event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('[AuthBloc] RequestOtp -> phone: ${event.phone}');
    emit(const AuthLoading());
    try {
      await _repository.requestOtp(event.phone);
      debugPrint('[AuthBloc] OTP yuborildi ✓');
      emit(const AuthOtpSent());
    } on DioException catch (e) {
      final msg = _extractDioError(e);
      debugPrint(
        '[AuthBloc] DioException: $msg | status: ${e.response?.statusCode}',
      );
      emit(AuthFailure(msg));
    } catch (e, st) {
      debugPrint('[AuthBloc] RequestOtp unknown error: $e\n$st');
      emit(const AuthFailure('Xatolik yuz berdi. Qayta urinib ko\'ring.'));
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('[AuthBloc] Google sign-in requested');
    emit(const AuthGoogleLoading());

    try {
      final credential = await _googleAuthService.signIn();
      final idToken = credential.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const GoogleAuthException(
          'Google ID token olinmadi. Qayta urinib ko\'ring.',
        );
      }

      final token = await _repository.loginWithGoogle(idToken);
      await _storage.saveTokens(
        access: token.accessToken,
        refresh: token.refreshToken,
      );
      await _persistGoogleUserInfo(credential);
      _startRefreshTimer();
      debugPrint(
        '[AuthBloc] Google auth muvaffaqiyatli ✓ email: ${credential.email}',
      );
      emit(AuthSuccess(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        isNewUser: token.isNewUser,
      ));
    } on GoogleAuthException catch (e) {
      emit(AuthFailure(e.message));
    } on DioException catch (e) {
      final msg = _extractDioError(e);
      debugPrint(
        '[AuthBloc] Google auth DioException: $msg | status: ${e.response?.statusCode}',
      );
      emit(AuthFailure(msg));
    } catch (e, st) {
      debugPrint('[AuthBloc] Google sign-in unknown error: $e\n$st');
      emit(const AuthFailure(
        'Google orqali kirishda xatolik yuz berdi. Qayta urinib ko\'ring.',
      ));
    }
  }

  Future<void> _persistGoogleUserInfo(GoogleAuthCredential credential) async {
    await _storage.saveUserInfo(
      phone: credential.email,
      countryName: _googleFallbackCountry,
      flagEmoji: _googleFallbackFlag,
    );

    try {
      final profile = await _profileRepository.getProfile();
      await _storage.saveUserInfo(
        phone: _resolveSessionIdentity(profile, credential),
        countryName: _resolveCountryName(profile),
        flagEmoji: _googleFallbackFlag,
      );
    } on DioException catch (e, st) {
      debugPrint(
        '[AuthBloc] Google profile load skipped after login: ${e.response?.statusCode}\n$st',
      );
    } catch (e, st) {
      debugPrint('[AuthBloc] Google profile sync skipped: $e\n$st');
    }
  }

  String _resolveSessionIdentity(
    UserProfile profile,
    GoogleAuthCredential credential,
  ) {
    final phone = profile.phone.trim();
    if (phone.isNotEmpty) return phone;

    final email = (profile.email ?? credential.email).trim();
    if (email.isNotEmpty) return email;

    final fullName = profile.resolvedFullName.trim();
    if (fullName.isNotEmpty) return fullName;

    final displayName = credential.displayName?.trim() ?? '';
    if (displayName.isNotEmpty) return displayName;

    return 'Google foydalanuvchi';
  }

  String _resolveCountryName(UserProfile profile) {
    final country = profile.country.trim();
    if (country.isNotEmpty) return country;
    return _googleFallbackCountry;
  }

  Future<void> _onVerifyOtp(
    AuthVerifyOtp event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint(
      '[AuthBloc] VerifyOtp -> phone: ${event.phone}, code: ${event.code}',
    );
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
      _startRefreshTimer();
      debugPrint(
        '[AuthBloc] Auth muvaffaqiyatli ✓ isNewUser: ${token.isNewUser}',
      );
      emit(AuthSuccess(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        isNewUser: token.isNewUser,
      ));
    } on DioException catch (e) {
      final msg = _extractDioError(e);
      debugPrint(
        '[AuthBloc] DioException: $msg | status: ${e.response?.statusCode}',
      );
      emit(AuthFailure(msg));
    } catch (e, st) {
      debugPrint('[AuthBloc] VerifyOtp unknown error: $e\n$st');
      emit(const AuthFailure('Xatolik yuz berdi. Qayta urinib ko\'ring.'));
    }
  }

  Future<void> _onSessionMonitoringStarted(
    AuthSessionMonitoringStarted event,
    Emitter<AuthState> emit,
  ) async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return;
    }

    _startRefreshTimer();
    add(const AuthSessionRefreshRequested(onlyIfDue: true));
  }

  Future<void> _onSessionRefreshRequested(
    AuthSessionRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_isRefreshing) return;

    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      _stopRefreshTimer();
      return;
    }

    if (event.onlyIfDue) {
      final updatedAt = await _storage.getTokensUpdatedAt();
      final now = DateTime.now().toUtc();
      if (updatedAt != null &&
          now.difference(updatedAt.toUtc()) < _refreshInterval) {
        return;
      }
    }

    _isRefreshing = true;
    try {
      final token = await _repository.refreshSession(refreshToken);
      await _storage.saveTokens(
        access: token.accessToken,
        refresh: token.refreshToken,
      );
      debugPrint('[AuthBloc] Session refreshed ✓');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final msg = _extractDioError(e);
      debugPrint(
        '[AuthBloc] Refresh DioException: $msg | status: $statusCode',
      );

      if (statusCode == 400 || statusCode == 401) {
        _stopRefreshTimer();
        await _storage.clearAll();
        emit(const AuthLoggedOut());
      }
    } catch (e, st) {
      debugPrint('[AuthBloc] Refresh unknown error: $e\n$st');
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('[AuthBloc] Logout requested');
    emit(const AuthLogoutInProgress());

    final refreshToken = await _storage.getRefreshToken();
    try {
      try {
        await _googleAuthService.signOut();
      } catch (e, st) {
        debugPrint(
          '[AuthBloc] Google local signOut ignored during logout: $e\n$st',
        );
      }

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          await _repository.logout(refreshToken);
        } on DioException catch (e) {
          final msg = _extractDioError(e);
          debugPrint(
            '[AuthBloc] Remote logout failed, local logout continues: $msg | status: ${e.response?.statusCode}',
          );
        } catch (e, st) {
          debugPrint(
            '[AuthBloc] Remote logout unknown error, local logout continues: $e\n$st',
          );
        }
      }

      _stopRefreshTimer();
      await _storage.clearAll();
      emit(const AuthLoggedOut());
    } catch (e, st) {
      debugPrint('[AuthBloc] Local logout cleanup failed: $e\n$st');
      emit(const AuthFailure(
        'Lokal logoutni yakunlab bo\'lmadi. Qayta urinib ko\'ring.',
      ));
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      add(const AuthSessionRefreshRequested());
    });
  }

  void _stopRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  String _extractDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('detail')) {
      return data['detail'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Server bilan aloqa yo\'q. Internetni tekshiring.';
    }
    return 'Xatolik yuz berdi. Qayta urinib ko\'ring.';
  }

  @override
  Future<void> close() {
    _stopRefreshTimer();
    return super.close();
  }
}
