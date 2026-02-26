import 'package:expensive/core/utils/app_fonts.dart';
import 'package:expensive/core/utils/app_toast.dart';
import 'package:expensive/core/utils/app_space.dart';
import 'package:expensive/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expensive/features/auth/presentation/bloc/auth_event.dart';
import 'package:expensive/features/auth/presentation/bloc/auth_state.dart';
import 'package:expensive/features/home/presentation/bloc/home_bloc.dart';
import 'package:expensive/features/home/presentation/bloc/home_event.dart';
import 'package:expensive/features/home/presentation/view/main_nav_view.dart';
import 'package:expensive/features/widgets/custom_button.dart';
import 'package:expensive/features/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UserNameView extends StatelessWidget {
  const UserNameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              ShowToast.showCustomToast(
                context,
                "Account created successfully!",
              );
              // Ensure Home Data is reloaded for the new account
              context.read<HomeBloc>().add(LoadHomeDataEvent());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainNavView()),
                (route) => false,
              );
            } else if (state is AuthFailure) {
              ShowToast.showCustomToast(context, state.message, isError: true);
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Enter your name", style: AppFontStyle.xl)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .moveX(begin: -20, end: 0, curve: Curves.easeOutQuad),
                  AppSpacing.h(10),
                  Text(
                        "Enter your name to continue",
                        style: AppFontStyle.medium,
                      )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .moveX(begin: -10, end: 0, curve: Curves.easeOutQuad),
                  AppSpacing.h(30),
                  CustomTextField(
                        hintText: "Name",
                        prefixIcon: const Icon(Icons.person),
                        onChanged: (val) {
                          context.read<AuthBloc>().add(UpdateNameEvent(val));
                        },
                      )
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1, 1),
                      ),
                  AppSpacing.h(20),
                  if (state is AuthLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ).animate().fadeIn()
                  else
                    CustomButton(
                          text: "Continue",
                          onPressed: () {
                            final nickname = context.read<AuthBloc>().nickname;
                            if (nickname.isNotEmpty) {
                              context.read<AuthBloc>().add(
                                CreateAccountEvent(nickname),
                              );
                            } else {
                              ShowToast.showCustomToast(
                                context,
                                "Please enter your name",
                                isError: true,
                              );
                            }
                          },
                        )
                        .animate()
                        .fadeIn(delay: 600.ms)
                        .moveY(begin: 20, end: 0, curve: Curves.easeOutQuad),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
