import 'package:expensive/core/services/prefs_service.dart';
import 'package:expensive/core/utils/app_colors.dart';
import 'package:expensive/core/utils/app_fonts.dart';
import 'package:expensive/core/utils/app_images.dart';
import 'package:expensive/core/utils/app_space.dart';
import 'package:expensive/core/utils/responsive_helper.dart';
import 'package:expensive/features/auth/presentation/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  int _currentIndex = 0;

  final List<Map<String, String>> _welcomeContent = [
    {
      "title": "Privacy by Default, With Zero Ads or Hidden Tracking",
      "subtitle": "No ads. No trackers. No third-party analytics.",
    },
    {
      "title": "Insights That Help You Spend Better Without Complexity",
      "subtitle": "See category-wise spending, recent activity.",
    },
    {
      "title": "Local-First Tracking That Stays Fully On Your Device",
      "subtitle": "Your finances stay on your phone.",
    },
  ];

  Future<void> _completeWelcome() async {
    await PrefsService().setWelcomeSeen(true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  void _nextStep() {
    if (_currentIndex < _welcomeContent.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _completeWelcome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(AppImages.background, fit: BoxFit.cover),
              ),

              // Gradient Overlay for readability at the bottom
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),

              // SKIP Button (Top Right)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 20,
                child: TextButton(
                  onPressed: _completeWelcome,
                  child: Text(
                    "SKIP",
                    style: AppFontStyle.medium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 800.ms),

              // Content Area
              SafeArea(
                child: Padding(
                  padding: ResponsiveHelper.getResponsivePaddingHV(
                    constraints,
                    24,
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),

                      // Progress Bars
                      Row(
                        children: List.generate(
                          _welcomeContent.length,
                          (index) => _buildProgressBar(
                            index <= _currentIndex,
                            constraints,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Animated title and subtitle
                      _buildTextWidget(
                        constraints,
                        _welcomeContent[_currentIndex]["title"]!,
                        _welcomeContent[_currentIndex]["subtitle"]!,
                      ),
                      const SizedBox(height: 40),

                      // Action Button (Next / Get Started)
                      SizedBox(
                            width: double.infinity,
                            height: ResponsiveHelper.getResponsiveHeight(
                              constraints,
                              55,
                            ),
                            child: ElevatedButton(
                              onPressed: _nextStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _currentIndex == _welcomeContent.length - 1
                                    ? "Get Started"
                                    : "Next",
                                style: AppFontStyle.medium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                          .animate(key: ValueKey('btn_$_currentIndex'))
                          .fadeIn(duration: 400.ms)
                          .scale(
                            begin: const Offset(0.95, 0.95),
                            end: const Offset(1, 1),
                            curve: Curves.easeOutBack,
                          ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(bool active, BoxConstraints constraints) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 4,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  Widget _buildTextWidget(
    BoxConstraints constraints,
    String title,
    String subtitle,
  ) {
    return Column(
      key: ValueKey<int>(_currentIndex),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
              title,
              style: AppFontStyle.large.copyWith(
                color: Colors.white,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  constraints,
                  20,
                ),
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            )
            .animate()
            .fadeIn(duration: 600.ms)
            .moveX(begin: 20, end: 0, curve: Curves.easeOutQuad),
        AppSpacing.h(12),
        Text(
              subtitle,
              style: AppFontStyle.medium.copyWith(
                color: Colors.white70,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  constraints,
                  15,
                ),
              ),
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .moveX(begin: 10, end: 0, curve: Curves.easeOutQuad),
      ],
    );
  }
}
