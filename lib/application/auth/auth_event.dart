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

  const AuthVerifyOtp({required this.phone, required this.code});

  @override
  List<Object> get props => [phone, code];
}
