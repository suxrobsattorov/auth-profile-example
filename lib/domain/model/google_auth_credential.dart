import 'package:equatable/equatable.dart';

class GoogleAuthCredential extends Equatable {
  final String googleUserId;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? idToken;
  final String? serverAuthCode;

  const GoogleAuthCredential({
    required this.googleUserId,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.idToken,
    this.serverAuthCode,
  });

  bool get hasIdToken => idToken != null && idToken!.isNotEmpty;

  bool get hasServerAuthCode =>
      serverAuthCode != null && serverAuthCode!.isNotEmpty;

  @override
  List<Object?> get props => [
        googleUserId,
        email,
        displayName,
        photoUrl,
        idToken,
        serverAuthCode,
      ];
}
