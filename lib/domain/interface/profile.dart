import 'package:auth_profile_example/domain/model/profile_update_request.dart';
import 'package:auth_profile_example/domain/model/user_profile.dart';

abstract class IProfileRepository {
  Future<UserProfile> getProfile();

  Future<UserProfile> updateProfile(ProfileUpdateRequest request);

  Future<void> requestEmailChangeCode(String email);

  Future<UserProfile> verifyEmailChange({
    required String email,
    required String code,
  });
}
