import 'package:expensive/core/utils/responsive_helper.dart';
import 'package:expensive/core/utils/app_colors.dart';
import 'package:expensive/core/utils/app_images.dart';
import 'package:expensive/core/services/prefs_service.dart';
import 'package:expensive/features/auth/presentation/views/login_view.dart';
import 'package:expensive/features/home/presentation/view/main_nav_view.dart';
import 'package:expensive/features/welcome/welcome_view.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Show splash for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final prefs = PrefsService();

    // 1. Check if first time
    final bool welcomeSeen = await prefs.isWelcomeSeen();
    if (!welcomeSeen) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeView()),
        );
      }
      return;
    }

    // 2. Check if logged in
    final token = await prefs.getToken();
    final nickname = await prefs.getNickname();

    if (token != null && nickname != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavView()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kSplash,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final logoSize = ResponsiveHelper.getResponsiveWidth(
            constraints,
            250,
          );

          return Center(
            child: TweenAnimationBuilder(
              duration: const Duration(seconds: 1),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                AppImages.logo,
                width: logoSize,
                height: logoSize,
              ),
            ),
          );
        },
      ),
    );
  }
}
