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
    await _initialize();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw const GoogleAuthException(
        'Joriy platformada Google kirish qo\'llab-quvvatlanmaydi.',
      );
    }

    try {
      final user = await _googleSignIn.authenticate();

      final idToken = user.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw const GoogleAuthException(
          'Google ID token olinmadi. '
          'google-services.json da client_type:3 bo\'lishi va '
          'serverClientId to\'g\'ri sozlanishi kerak.',
        );
      }

      String? serverAuthCode;
      if (GoogleAuthConfig.hasServerClientId) {
        try {
          final serverAuth = await user.authorizationClient
              .authorizeServer(GoogleAuthConfig.serverScopes);
          serverAuthCode = serverAuth?.serverAuthCode;
        } catch (_) {}
      }

      return GoogleAuthCredential(
        googleUserId: user.id,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        idToken: idToken,
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
    if (_initializeFuture == null) return;
    try {
      await _initializeFuture;
      await _googleSignIn.signOut();
    } on GoogleSignInException {
    } on PlatformException catch (e, st) {
      debugPrint('[GoogleAuth] signOut platform error ignored: $e\n$st');
    } catch (e, st) {
      debugPrint('[GoogleAuth] signOut unknown error ignored: $e\n$st');
    }
  }

  Future<void> _initialize() async {
    if (_initializeFuture != null) return _initializeFuture!;
    _initializeFuture = _googleSignIn.initialize(
      clientId: GoogleAuthConfig.clientId,
      serverClientId: GoogleAuthConfig.serverClientId,
    );
    return _initializeFuture!;
  }

  String _mapGoogleError(GoogleSignInException exception) {
    switch (exception.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Google kirish bekor qilindi.';
      case GoogleSignInExceptionCode.interrupted:
        return 'Google kirish uzilib qoldi.';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Google konfiguratsiya xatosi. SHA-1 va package name tekshiring.';
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Google provider xatosi.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google kirish oynasi ochilmadi.';
      case GoogleSignInExceptionCode.userMismatch:
        return 'Google akkaunt mos kelmadi.';
      case GoogleSignInExceptionCode.unknownError:
        return 'Google noma\'lum xatolik.';
    }
  }
}

class GoogleAuthException implements Exception {
  final String message;

  const GoogleAuthException(this.message);

  @override
  String toString() => message;
}
