import 'dart:async';
import 'package:expensive/features/auth/data/models/auth_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthResponseModel? _cachedResponse;
  String? _phoneNumber;
  String? _currentOtp;
  String? _nickname;
  Timer? _resendTimer;
  final TextEditingController otpController = TextEditingController();

  String get phoneNumber => _phoneNumber ?? '';
  String get currentOtp => _currentOtp ?? '';
  String get nickname => _nickname ?? '';

  AuthBloc(this._repository) : super(AuthInitial()) {
    on<UpdatePhoneEvent>((event, emit) => _phoneNumber = event.phone);
    on<UpdateOtpEvent>((event, emit) => _currentOtp = event.otp);
    on<UpdateNameEvent>((event, emit) => _nickname = event.nickname);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<CreateAccountEvent>(_onCreateAccount);
    on<LogoutEvent>(_onLogout);
    on<TimerTickedEvent>(_onTimerTicked);
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _repository.sendOtp(event.phone);

      _cachedResponse = response;
      _phoneNumber = event.phone;

      _startResendTimer();

      emit(
        OtpSentState(
          otp: response.otp ?? '',
          userExists: response.userExists ?? false,
          phone: event.phone,
          secondsRemaining: 60,
          canResend: false,
        ),
      );
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentSeconds = 60 - timer.tick;
      if (currentSeconds >= 0) {
        add(TimerTickedEvent(currentSeconds));
      } else {
        _resendTimer?.cancel();
      }
    });
  }

  void _onTimerTicked(TimerTickedEvent event, Emitter<AuthState> emit) {
    if (state is OtpSentState) {
      final otpState = state as OtpSentState;
      emit(
        otpState.copyWith(
          secondsRemaining: event.seconds,
          canResend: event.seconds == 0,
        ),
      );
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    final cached = _cachedResponse;
    if (cached == null) return;

    if (event.otp != cached.otp) {
      emit(const AuthFailure("Incorrect OTP. Please try again."));

      if (state is OtpSentState) {
        emit(state);
      } else {
        emit(
          OtpSentState(
            otp: cached.otp ?? '',
            userExists: cached.userExists ?? false,
            phone: _phoneNumber ?? '',
          ),
        );
      }
      return;
    }

    _resendTimer?.cancel();

    if (cached.userExists == true) {
      await _authenticateUser(
        cached.token ?? '',
        cached.nickname ?? '',
        cached.userId ?? _phoneNumber ?? 'unknown',
        emit,
      );
    } else {
      emit(UserNewState(_phoneNumber ?? ''));
    }
  }

  Future<void> _onCreateAccount(
    CreateAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (_phoneNumber == null) return;

    emit(AuthLoading());
    try {
      final response = await _repository.createAccount(
        _phoneNumber!,
        event.nickname,
      );
      await _authenticateUser(
        response.token,
        event.nickname,
        response.userId ?? _phoneNumber!,
        emit,
      );
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    _resendTimer?.cancel();
    await _repository.logout();
    _cachedResponse = null;
    _phoneNumber = null;
    emit(AuthLoggedOut());
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    otpController.dispose();
    return super.close();
  }

  Future<void> _authenticateUser(
    String token,
    String nickname,
    String userId,
    Emitter<AuthState> emit,
  ) async {
    await _repository.saveLocalData(token, nickname, userId);
    emit(AuthSuccess(token, nickname));
  }
}
