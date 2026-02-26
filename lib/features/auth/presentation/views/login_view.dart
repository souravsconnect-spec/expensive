import 'package:expensive/core/utils/app_fonts.dart';
import 'package:expensive/core/utils/app_toast.dart';
import 'package:expensive/core/utils/app_space.dart';
import 'package:expensive/core/utils/responsive_helper.dart';
import 'package:expensive/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expensive/features/auth/presentation/bloc/auth_event.dart';
import 'package:expensive/features/auth/presentation/bloc/auth_state.dart';
import 'package:expensive/features/auth/presentation/views/otp_view.dart';
import 'package:expensive/features/widgets/custom_button.dart';
import 'package:expensive/features/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;

          final now = DateTime.now();
          if (_lastPressedAt == null ||
              now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
            _lastPressedAt = now;
            ShowToast.showCustomToast(context, "Swipe back again to exit");
            return;
          }
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        },
        child: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listenWhen: (previous, current) =>
                (previous is AuthLoading && current is OtpSentState) ||
                current is AuthFailure,
            listener: (context, state) {
              if (state is OtpSentState) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OtpView()),
                );
              } else if (state is AuthFailure) {
                ShowToast.showCustomToast(
                  context,
                  state.message,
                  isError: true,
                );
              }
            },
            builder: (context, state) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: ResponsiveHelper.getResponsivePaddingHV(
                      constraints,
                      12,
                      12,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Get Started", style: AppFontStyle.xl)
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .moveY(
                                begin: 20,
                                end: 0,
                                curve: Curves.easeOutQuad,
                              ),
                          AppSpacing.h(20),
                          Text(
                                "Login In Using Phone & OTP",
                                style: AppFontStyle.medium,
                              )
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 600.ms)
                              .moveY(
                                begin: 10,
                                end: 0,
                                curve: Curves.easeOutQuad,
                              ),
                          AppSpacing.h(20),
                          CustomTextField(
                                hintText: "Phone Number",
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                prefixIcon: const Icon(Icons.phone),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your phone number";
                                  }
                                  if (value.length != 10) {
                                    return "Phone number must be 10 digits";
                                  }
                                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                    return "Enter a valid phone number";
                                  }
                                  return null;
                                },
                                onChanged: (val) {
                                  context.read<AuthBloc>().add(
                                    UpdatePhoneEvent(val),
                                  );
                                },
                              )
                              .animate()
                              .fadeIn(delay: 400.ms, duration: 600.ms)
                              .scale(
                                begin: const Offset(0.9, 0.9),
                                end: const Offset(1, 1),
                                curve: Curves.easeOutBack,
                              ),
                          AppSpacing.h(20),
                          if (state is AuthLoading)
                            const Center(
                              child: CircularProgressIndicator(),
                            ).animate().fadeIn()
                          else
                            CustomButton(
                                  text: "Login",
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(
                                        SendOtpEvent(
                                          context.read<AuthBloc>().phoneNumber,
                                        ),
                                      );
                                    }
                                  },
                                )
                                .animate()
                                .fadeIn(delay: 600.ms, duration: 600.ms)
                                .moveY(
                                  begin: 20,
                                  end: 0,
                                  curve: Curves.easeOutQuad,
                                ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
