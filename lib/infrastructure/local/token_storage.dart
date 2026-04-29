import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _tokensUpdatedAtKey = 'tokens_updated_at';
  static const _phoneKey = 'user_phone';
  static const _countryNameKey = 'user_country_name';
  static const _flagEmojiKey = 'user_flag_emoji';

  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, access);
    await prefs.setString(_refreshKey, refresh);
    await prefs.setString(
      _tokensUpdatedAtKey,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<void> saveUserInfo({
    required String phone,
    required String countryName,
    required String flagEmoji,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, phone);
    await prefs.setString(_countryNameKey, countryName);
    await prefs.setString(_flagEmojiKey, flagEmoji);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }

  Future<DateTime?> getTokensUpdatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tokensUpdatedAtKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw);
  }

  Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  Future<String?> getCountryName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_countryNameKey);
  }

  Future<String?> getFlagEmoji() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_flagEmojiKey);
  }

  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_accessKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_accessKey),
      prefs.remove(_refreshKey),
      prefs.remove(_tokensUpdatedAtKey),
      prefs.remove(_phoneKey),
      prefs.remove(_countryNameKey),
      prefs.remove(_flagEmojiKey),
    ]);
  }
}
