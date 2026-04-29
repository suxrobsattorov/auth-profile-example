import 'package:flutter/foundation.dart';

class GoogleAuthConfig {
  static const String iosClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID_IOS',
    defaultValue:
        '913143229825-6t2ku4uup4ur3iv7u5lfsamdjtva27qe.apps.googleusercontent.com',
  );

  static const String androidClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID_ANDROID',
    defaultValue:
        '913143229825-4v21fk5cgponiurn4g99cn3t81ockli8.apps.googleusercontent.com',
  );

  static const String _serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  static const List<String> serverScopes = <String>[
    'openid',
    'email',
    'profile',
  ];

  static String? get clientId {
    if (kIsWeb) return null;

    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => iosClientId,
      TargetPlatform.macOS => iosClientId,
      _ => null,
    };
  }

  static String? get serverClientId =>
      _serverClientId.isEmpty ? null : _serverClientId;

  static bool get hasServerClientId => serverClientId != null;
}
