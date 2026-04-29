class AuthToken {
  final String accessToken;
  final String refreshToken;
  final bool isNewUser;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.isNewUser,
  });
}
