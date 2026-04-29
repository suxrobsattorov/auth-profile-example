import 'package:auth_profile_example/domain/model/auth_token.dart';

abstract class IAuthRepository {
  Future<void> requestOtp(String phone);

  Future<AuthToken> verifyOtp(String phone, String code);

  Future<void> logout(String refreshToken);
}
