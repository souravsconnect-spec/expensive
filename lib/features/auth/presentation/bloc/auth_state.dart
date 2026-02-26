import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSentState extends AuthState {
  final String otp;
  final bool userExists;
  final String phone;
  final int secondsRemaining;
  final bool canResend;

  const OtpSentState({
    required this.otp,
    required this.userExists,
    required this.phone,
    this.secondsRemaining = 60,
    this.canResend = false,
  });

  @override
  List<Object?> get props => [
    otp,
    userExists,
    phone,
    secondsRemaining,
    canResend,
  ];

  OtpSentState copyWith({
    String? otp,
    bool? userExists,
    String? phone,
    int? secondsRemaining,
    bool? canResend,
  }) {
    return OtpSentState(
      otp: otp ?? this.otp,
      userExists: userExists ?? this.userExists,
      phone: phone ?? this.phone,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      canResend: canResend ?? this.canResend,
    );
  }
}

class UserNewState extends AuthState {
  final String phone;
  const UserNewState(this.phone);

  @override
  List<Object?> get props => [phone];
}

class AuthSuccess extends AuthState {
  final String token;
  final String nickname;

  const AuthSuccess(this.token, this.nickname);

  @override
  List<Object?> get props => [token, nickname];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthLoggedOut extends AuthState {}
