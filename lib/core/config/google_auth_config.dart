import 'package:flutter/foundation.dart';

class GoogleAuthConfig {
  static const String iosClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID_IOS',
    defaultValue:
        '913143229825-6t2ku4uup4ur3iv7u5lfsamdjtva27qe.apps.googleusercontent.com',
  );

  // Web OAuth 2.0 Client ID — Google Cloud Console > APIs & Services > Credentials
  // !! Android uchun MAJBURIY !! google_sign_in v7+ idToken qaytarishi uchun kerak.
  // Yoki android/app/google-services.json ichida client_type:3 bo'lishi kifoya.
  static const String _serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '913143229825-3jiikdmdukrehocm3ueq5qg53ht2dpqj.apps.googleusercontent.com',
  );

  static const List<String> serverScopes = <String>[
    'openid',
    'email',
    'profile',
  ];

  // Android clientId ni google_sign_in v7 butunlay e'tiborsiz qoldiradi.
  // Android faqat serverClientId yoki google-services.json ni ishlatadi.
  static String? get clientId {
    if (kIsWeb) return null;

    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => iosClientId,
      _ => null,
    };
  }

  static String? get serverClientId =>
      _serverClientId.isEmpty ? null : _serverClientId;

  static bool get hasServerClientId => serverClientId != null;
}
