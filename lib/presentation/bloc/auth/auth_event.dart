import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;

  const RegisterRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class PhoneVerificationRequested extends AuthEvent {
  final String phoneNumber;

  const PhoneVerificationRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class OtpVerificationRequested extends AuthEvent {
  final String verificationId;
  final String smsCode;

  const OtpVerificationRequested({
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object?> get props => [verificationId, smsCode];
}

class LogoutRequested extends AuthEvent {}

class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}
