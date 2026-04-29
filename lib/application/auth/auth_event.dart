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
