import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class UpdatePhoneEvent extends AuthEvent {
  final String phone;
  const UpdatePhoneEvent(this.phone);

  @override
  List<Object?> get props => [phone];
}

class UpdateOtpEvent extends AuthEvent {
  final String otp;
  const UpdateOtpEvent(this.otp);

  @override
  List<Object?> get props => [otp];
}

class UpdateNameEvent extends AuthEvent {
  final String nickname;
  const UpdateNameEvent(this.nickname);

  @override
  List<Object?> get props => [nickname];
}

class SendOtpEvent extends AuthEvent {
  final String phone;

  const SendOtpEvent(this.phone);

  @override
  List<Object?> get props => [phone];
}

class VerifyOtpEvent extends AuthEvent {
  final String otp;

  const VerifyOtpEvent(this.otp);

  @override
  List<Object?> get props => [otp];
}

class CreateAccountEvent extends AuthEvent {
  final String nickname;

  const CreateAccountEvent(this.nickname);

  @override
  List<Object?> get props => [nickname];
}

class LogoutEvent extends AuthEvent {}

class TimerTickedEvent extends AuthEvent {
  final int seconds;
  const TimerTickedEvent(this.seconds);

  @override
  List<Object?> get props => [seconds];
}
