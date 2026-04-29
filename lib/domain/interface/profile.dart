import 'package:auth_profile_example/domain/model/profile_update_request.dart';
import 'package:auth_profile_example/domain/model/user_profile.dart';

abstract class IProfileRepository {
  Future<UserProfile> getProfile();

  Future<UserProfile> updateProfile(ProfileUpdateRequest request);
}
