import 'package:expensive/core/utils/app_colors.dart';
import 'package:expensive/core/utils/app_images.dart';
import 'package:expensive/features/home/presentation/bloc/home_bloc.dart';
import 'package:expensive/features/home/presentation/bloc/home_event.dart';
import 'package:expensive/features/home/presentation/view/home_view.dart';
import 'package:expensive/features/profile/profile_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive/features/transactions/presentation/view/transactions_view.dart';
import 'package:expensive/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:expensive/features/transactions/presentation/bloc/transactions_event.dart';
import 'package:expensive/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expensive/features/auth/presentation/bloc/auth_state.dart';
import 'package:expensive/features/auth/presentation/views/login_view.dart';
import 'package:expensive/core/utils/responsive_helper.dart';
import 'package:expensive/core/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MainNavView extends StatefulWidget {
  const MainNavView({super.key});

  @override
  State<MainNavView> createState() => _MainNavViewState();
}

class _MainNavViewState extends State<MainNavView> {
  int _selectedIndex = 0;
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionsBloc>().add(LoadAllTransactionsEvent());
      context.read<HomeBloc>().add(LoadHomeDataEvent());
    });
  }

  final List<Widget> _pages = [
    const HomeView(),
    const TransactionsView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
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
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoggedOut) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false,
              );
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  _pages[_selectedIndex],
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: ResponsiveHelper.getResponsiveHeight(
                      constraints,
                      16,
                    ),
                    child:
                        Center(
                              child: Container(
                                padding:
                                    ResponsiveHelper.getResponsivePaddingHV(
                                      constraints,
                                      16,
                                      8,
                                    ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildNavIcon(
                                      0,
                                      AppImages.bottomBarHome,
                                      constraints,
                                    ),
                                    SizedBox(
                                      width:
                                          ResponsiveHelper.getResponsiveWidth(
                                            constraints,
                                            8,
                                          ),
                                    ),
                                    _buildNavIcon(
                                      1,
                                      AppImages.bottomBarTransactions,
                                      constraints,
                                    ),
                                    SizedBox(
                                      width:
                                          ResponsiveHelper.getResponsiveWidth(
                                            constraints,
                                            8,
                                          ),
                                    ),
                                    _buildNavIcon(
                                      2,
                                      AppImages.bottomBarProfile,
                                      constraints,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 500.ms)
                            .moveY(
                              begin: 50,
                              end: 0,
                              duration: 800.ms,
                              curve: Curves.easeOutBack,
                            ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(
    int index,
    String imagePath,
    BoxConstraints constraints,
  ) {
    bool isActive = _selectedIndex == index;
    final iconSize = ResponsiveHelper.getResponsiveIconSize(constraints, 24);
    final padding = ResponsiveHelper.getResponsiveHeight(constraints, 12);

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          context.read<HomeBloc>().add(LoadHomeDataEvent());
        } else if (index == 1) {
          context.read<TransactionsBloc>().add(LoadAllTransactionsEvent());
        }
        setState(() => _selectedIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          imagePath,
          width: iconSize,
          height: iconSize,
          color: Colors.white,
        ),
      ),
    );
  }
}
