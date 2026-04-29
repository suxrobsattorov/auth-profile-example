import 'package:auth_profile_example/domain/model/google_auth_credential.dart';

abstract class IGoogleAuthService {
  Future<GoogleAuthCredential> signIn();

  Future<void> signOut();
}
