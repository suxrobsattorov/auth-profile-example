import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:auth_profile_example/core/config/google_auth_config.dart';
import 'package:auth_profile_example/domain/interface/google_auth.dart';
import 'package:auth_profile_example/domain/model/google_auth_credential.dart';

class GoogleAuthServiceImpl implements IGoogleAuthService {
  final GoogleSignIn _googleSignIn;
  Future<void>? _initializeFuture;

  GoogleAuthServiceImpl({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  @override
  Future<GoogleAuthCredential> signIn() async {
    await _initialize();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw const GoogleAuthException(
        'Joriy platformada Google kirish qo\'llab-quvvatlanmaydi.',
      );
    }

    try {
      final user = await _googleSignIn.authenticate();
      final authentication = user.authentication;

      String? serverAuthCode;
      if (GoogleAuthConfig.hasServerClientId) {
        final serverAuthorization = await user.authorizationClient
            .authorizeServer(GoogleAuthConfig.serverScopes);
        serverAuthCode = serverAuthorization?.serverAuthCode;
      }

      if (authentication.idToken == null || authentication.idToken!.isEmpty) {
        throw const GoogleAuthException(
          'Google ID token olinmadi. Android uchun web/server client ID kerak bo\'lishi mumkin.',
        );
      }

      return GoogleAuthCredential(
        googleUserId: user.id,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        idToken: authentication.idToken,
        serverAuthCode: serverAuthCode,
      );
    } on GoogleSignInException catch (e) {
      throw GoogleAuthException(_mapGoogleError(e));
    } catch (e) {
      if (e is GoogleAuthException) rethrow;
      throw const GoogleAuthException(
        'Google orqali kirishda noma\'lum xatolik yuz berdi.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    if (_initializeFuture == null) {
      return;
    }

    try {
      await _initializeFuture;
      await _googleSignIn.signOut();
    } on GoogleSignInException {
      // Local Google session cleanup should not block normal logout.
    } on PlatformException catch (e, st) {
      debugPrint('[GoogleAuth] signOut platform error ignored: $e\n$st');
    } catch (e, st) {
      debugPrint('[GoogleAuth] signOut unknown error ignored: $e\n$st');
    }
  }

  Future<void> _initialize() {
    return _initializeFuture ??= _googleSignIn.initialize(
      clientId: GoogleAuthConfig.clientId,
      serverClientId: GoogleAuthConfig.serverClientId,
    );
  }

  String _mapGoogleError(GoogleSignInException exception) {
    switch (exception.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Google kirish jarayoni bekor qilindi.';
      case GoogleSignInExceptionCode.interrupted:
        return 'Google kirish jarayoni uzilib qoldi. Qayta urinib ko\'ring.';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Google client konfiguratsiyasi noto\'g\'ri. Package/bundle ID va OAuth sozlamalarini tekshiring.';
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Google provider konfiguratsiyasi tayyor emas.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google kirish oynasini ochib bo\'lmadi.';
      case GoogleSignInExceptionCode.userMismatch:
        return 'Tanlangan Google akkaunt kutilgan foydalanuvchiga mos kelmadi.';
      case GoogleSignInExceptionCode.unknownError:
        return 'Google tomonidan noma\'lum xatolik qaytdi.';
    }
  }
}

class GoogleAuthException implements Exception {
  final String message;

  const GoogleAuthException(this.message);

  @override
  String toString() => message;
}
