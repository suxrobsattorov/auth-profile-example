import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:auth_profile_example/core/config/google_auth_config.dart';
import 'package:auth_profile_example/domain/interface/google_auth.dart';
import 'package:auth_profile_example/domain/model/google_auth_credential.dart';

class GoogleAuthServiceImpl implements GoogleAuthService {
  final GoogleSignIn _googleSignIn;
  Future<void>? _initializeFuture;

  GoogleAuthServiceImpl({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  @override
  Future<GoogleAuthCredential> signIn() async {
    debugPrint('=== [GoogleAuth] signIn() boshlandi ===');
    debugPrint('[GoogleAuth] clientId: ${GoogleAuthConfig.clientId}');
    debugPrint('[GoogleAuth] serverClientId: ${GoogleAuthConfig.serverClientId}');

    debugPrint('[GoogleAuth] _initialize() chaqirilmoqda...');
    await _initialize();
    debugPrint('[GoogleAuth] _initialize() tugadi');

    final supports = _googleSignIn.supportsAuthenticate();
    debugPrint('[GoogleAuth] supportsAuthenticate: $supports');

    if (!supports) {
      throw const GoogleAuthException(
        'Joriy platformada Google kirish qo\'llab-quvvatlanmaydi.',
      );
    }

    try {
      debugPrint('[GoogleAuth] authenticate() chaqirilmoqda...');
      final user = await _googleSignIn.authenticate();
      debugPrint('[GoogleAuth] authenticate() tugadi');
      debugPrint('[GoogleAuth] user.id: ${user.id}');
      debugPrint('[GoogleAuth] user.email: ${user.email}');
      debugPrint('[GoogleAuth] user.displayName: ${user.displayName}');

      final idToken = user.authentication.idToken;
      debugPrint('[GoogleAuth] idToken: ${idToken == null ? "NULL !!!" : "mavjud (${idToken.length} belgi)"}');

      if (idToken == null || idToken.isEmpty) {
        throw const GoogleAuthException(
          'Google ID token olinmadi. '
          'google-services.json da client_type:3 bo\'lishi va '
          'serverClientId to\'g\'ri sozlanishi kerak.',
        );
      }

      String? serverAuthCode;
      if (GoogleAuthConfig.hasServerClientId) {
        debugPrint('[GoogleAuth] authorizeServer() chaqirilmoqda...');
        try {
          final serverAuth = await user.authorizationClient
              .authorizeServer(GoogleAuthConfig.serverScopes);
          serverAuthCode = serverAuth?.serverAuthCode;
          debugPrint('[GoogleAuth] serverAuthCode: ${serverAuthCode ?? "null"}');
        } catch (e) {
          debugPrint('[GoogleAuth] authorizeServer skipped: $e');
        }
      }

      debugPrint('[GoogleAuth] GoogleAuthCredential yaratilmoqda...');
      return GoogleAuthCredential(
        googleUserId: user.id,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        idToken: idToken,
        serverAuthCode: serverAuthCode,
      );
    } on GoogleSignInException catch (e) {
      debugPrint('=== [GoogleAuth] GoogleSignInException ===');
      debugPrint('[GoogleAuth] code: ${e.code}');
      debugPrint('[GoogleAuth] description: ${e.description}');
      debugPrint('[GoogleAuth] details: ${e.details}');
      throw GoogleAuthException(_mapGoogleError(e));
    } catch (e, st) {
      debugPrint('=== [GoogleAuth] Unknown error ===');
      debugPrint('[GoogleAuth] error: $e');
      debugPrint('[GoogleAuth] stacktrace: $st');
      if (e is GoogleAuthException) rethrow;
      throw const GoogleAuthException(
        'Google orqali kirishda noma\'lum xatolik yuz berdi.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    if (_initializeFuture == null) return;
    try {
      await _initializeFuture;
      await _googleSignIn.signOut();
      debugPrint('[GoogleAuth] signOut() bajarildi');
    } on GoogleSignInException {
    } on PlatformException catch (e, st) {
      debugPrint('[GoogleAuth] signOut platform error ignored: $e\n$st');
    } catch (e, st) {
      debugPrint('[GoogleAuth] signOut unknown error ignored: $e\n$st');
    }
  }

  Future<void> _initialize() async {
    if (_initializeFuture != null) {
      debugPrint('[GoogleAuth] allaqachon initialized, skip');
      return _initializeFuture!;
    }
    debugPrint('[GoogleAuth] initialize() params:');
    debugPrint('[GoogleAuth]   clientId=${GoogleAuthConfig.clientId}');
    debugPrint('[GoogleAuth]   serverClientId=${GoogleAuthConfig.serverClientId}');
    _initializeFuture = _googleSignIn.initialize(
      clientId: GoogleAuthConfig.clientId,
      serverClientId: GoogleAuthConfig.serverClientId,
    );
    return _initializeFuture!;
  }

  String _mapGoogleError(GoogleSignInException exception) {
    switch (exception.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Google kirish bekor qilindi. (canceled)';
      case GoogleSignInExceptionCode.interrupted:
        return 'Google kirish uzilib qoldi. (interrupted)';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Google konfiguratsiya xatosi. SHA-1/SHA256 va package name tekshiring. (clientConfigurationError)';
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Google provider xatosi. (providerConfigurationError)';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google kirish oynasi ochilmadi. (uiUnavailable)';
      case GoogleSignInExceptionCode.userMismatch:
        return 'Google akkaunt mos kelmadi. (userMismatch)';
      case GoogleSignInExceptionCode.unknownError:
        return 'Google noma\'lum xatolik. (unknownError)';
    }
  }
}

class GoogleAuthException implements Exception {
  final String message;

  const GoogleAuthException(this.message);

  @override
  String toString() => message;
}
