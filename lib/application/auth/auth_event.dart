import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthRequestOtp extends AuthEvent {
  final String phone;

  const AuthRequestOtp(this.phone);

  @override
  List<Object> get props => [phone];
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

class AuthVerifyOtp extends AuthEvent {
  final String phone;
  final String code;
  final String countryName;
  final String flagEmoji;

  const AuthVerifyOtp({
    required this.phone,
    required this.code,
    required this.countryName,
    required this.flagEmoji,
  });

  @override
  List<Object> get props => [phone, code, countryName, flagEmoji];
}

class AuthSessionMonitoringStarted extends AuthEvent {
  const AuthSessionMonitoringStarted();
}

class AuthSessionRefreshRequested extends AuthEvent {
  final bool onlyIfDue;

  const AuthSessionRefreshRequested({this.onlyIfDue = false});

  @override
  List<Object> get props => [onlyIfDue];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
