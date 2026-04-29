import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthOtpSent extends AuthState {
  const AuthOtpSent();
}

class AuthSuccess extends AuthState {
  final String accessToken;
  final String refreshToken;
  final bool isNewUser;

  const AuthSuccess({
    required this.accessToken,
    required this.refreshToken,
    required this.isNewUser,
  });

  @override
  List<Object> get props => [accessToken, refreshToken, isNewUser];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

class AuthLogoutInProgress extends AuthState {
  const AuthLogoutInProgress();
}

class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}
