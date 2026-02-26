import 'package:expensive/core/utils/app_colors.dart';
import 'package:expensive/core/utils/app_fonts.dart';
import 'package:expensive/core/utils/app_toast.dart';
import 'package:expensive/core/utils/app_space.dart';
import 'package:expensive/core/utils/responsive_helper.dart';
import 'package:expensive/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expensive/features/auth/presentation/bloc/auth_event.dart';
import 'package:expensive/features/auth/presentation/bloc/auth_state.dart';
import 'package:expensive/features/auth/presentation/views/user_name_view.dart';
import 'package:expensive/features/home/presentation/bloc/home_bloc.dart';
import 'package:expensive/features/home/presentation/bloc/home_event.dart';
import 'package:expensive/features/home/presentation/view/main_nav_view.dart';
import 'package:expensive/features/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pinput/pinput.dart';

class OtpView extends StatefulWidget {
  const OtpView({super.key});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 60,
        leading: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 16),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(""),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              ShowToast.showCustomToast(context, "Login Successful!");
              context.read<HomeBloc>().add(LoadHomeDataEvent());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainNavView()),
                (route) => false,
              );
            } else if (state is UserNewState) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserNameView()),
              );
            } else if (state is AuthFailure) {
              ShowToast.showCustomToast(context, state.message, isError: true);
            }
          },
          builder: (context, state) {
            String displayedOtp = "";
            String phoneNumber = context.read<AuthBloc>().phoneNumber;
            int secondsRemaining = 60;
            bool canResend = false;

            if (state is OtpSentState) {
              displayedOtp = state.otp;
              phoneNumber = state.phone;
              secondsRemaining = state.secondsRemaining;
              canResend = state.canResend;
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: ResponsiveHelper.getResponsivePaddingHV(
                      constraints,
                      20,
                      20,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Verify OTP", style: AppFontStyle.xl)
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .moveX(
                                begin: -20,
                                end: 0,
                                curve: Curves.easeOutQuad,
                              ),
                          AppSpacing.h(10),
                          Text(
                                "Enter the 6 digit code sent to $phoneNumber",
                                textAlign: TextAlign.start,
                                style: AppFontStyle.medium,
                              )
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 600.ms)
                              .moveX(
                                begin: -10,
                                end: 0,
                                curve: Curves.easeOutQuad,
                              ),
                          AppSpacing.h(30),

                          if (displayedOtp.isNotEmpty)
                            Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue),
                                  ),
                                  child: Text(
                                    "Test OTP: $displayedOtp",
                                    style: AppFontStyle.medium.copyWith(
                                      color: Colors.blue,
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .scale(
                                  begin: const Offset(0.8, 0.8),
                                  end: const Offset(1, 1),
                                ),

                          AppSpacing.h(30),

                          Center(
                                child: Pinput(
                                  length: 6,
                                  controller: context
                                      .read<AuthBloc>()
                                      .otpController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  defaultPinTheme: PinTheme(
                                    width: ResponsiveHelper.getResponsiveWidth(
                                      constraints,
                                      50,
                                    ),
                                    height: 56,
                                    textStyle: AppFontStyle.large.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white.withOpacity(0.05),
                                    ),
                                  ),
                                  focusedPinTheme: PinTheme(
                                    width: ResponsiveHelper.getResponsiveWidth(
                                      constraints,
                                      52,
                                    ),
                                    height: 60,
                                    textStyle: AppFontStyle.large.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.primary,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      color: AppColors.primary.withOpacity(0.1),
                                    ),
                                  ),
                                  errorPinTheme: PinTheme(
                                    width: ResponsiveHelper.getResponsiveWidth(
                                      constraints,
                                      50,
                                    ),
                                    height: 56,
                                    textStyle: AppFontStyle.large.copyWith(
                                      color: AppColors.kRed,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.kRed),
                                      borderRadius: BorderRadius.circular(12),
                                      color: AppColors.kRed.withOpacity(0.05),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "OTP is required";
                                    }
                                    if (value.length < 6) {
                                      return "Enter all 6 digits";
                                    }
                                    return null;
                                  },
                                  errorTextStyle: const TextStyle(
                                    color: AppColors.kRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  preFilledWidget: Text(
                                    "-",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  onCompleted: (pin) {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(
                                        VerifyOtpEvent(pin),
                                      );
                                    }
                                  },
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 500.ms)
                              .scale(
                                begin: const Offset(0.9, 0.9),
                                end: const Offset(1, 1),
                                curve: Curves.easeOutBack,
                              ),

                          AppSpacing.h(30),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                canResend
                                    ? "Didn't receive code? "
                                    : "Resend code in ",
                                style: AppFontStyle.medium,
                              ),
                              if (!canResend)
                                Text(
                                  "${secondsRemaining}s",
                                  style: AppFontStyle.medium.copyWith(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (canResend)
                                GestureDetector(
                                  onTap: () {
                                    if (phoneNumber.isNotEmpty) {
                                      context.read<AuthBloc>().add(
                                        SendOtpEvent(phoneNumber),
                                      );
                                    }
                                  },
                                  child: Text(
                                    "Resend OTP",
                                    style: AppFontStyle.medium.copyWith(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                            ],
                          ).animate().fadeIn(delay: 700.ms),

                          AppSpacing.h(50),

                          if (state is AuthLoading)
                            const Center(
                              child: CircularProgressIndicator(),
                            ).animate().fadeIn()
                          else
                            CustomButton(
                                  text: "Verify OTP",
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      final code = context
                                          .read<AuthBloc>()
                                          .otpController
                                          .text;
                                      context.read<AuthBloc>().add(
                                        VerifyOtpEvent(code),
                                      );
                                    }
                                  },
                                )
                                .animate()
                                .fadeIn(delay: 800.ms)
                                .moveY(
                                  begin: 20,
                                  end: 0,
                                  curve: Curves.easeOutQuad,
                                ),
                          AppSpacing.h(20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
