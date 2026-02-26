import 'package:expensive/core/utils/app_colors.dart';
import 'package:expensive/features/home/presentation/view/widgets/add_transaction_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/utils/app_fonts.dart';
import '../../../../core/utils/app_space.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/views/login_view.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home/home_monthly_limit.dart';
import '../widgets/home/home_shimmer.dart';
import '../widgets/home/home_stats_cards.dart';
import '../widgets/home/home_transaction_item.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.read<HomeBloc>().state is HomeInitial) {
      context.read<HomeBloc>().add(LoadHomeDataEvent());
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(context),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthLoggedOut) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                  (route) => false,
                );
              }
            },
          ),
        ],
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const HomeShimmer();
            } else if (state is HomeLoaded) {
              return _buildHomeContent(state);
            } else if (state is HomeError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100, right: 16),
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const AddTransactionSheet(),
            );
          },
          shape: const CircleBorder(),

          elevation: 0,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomRight,
                colors: [AppColors.secondary, Colors.black],
              ),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          String name = "User";
          if (state is HomeLoaded) {
            name = state.userName;
          }
          return Text(
            "👋 Welcome, $name!",
            style: AppFontStyle.large.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
      // actions: [
      //   IconButton(
      //     onPressed: () => context.read<AuthBloc>().add(LogoutEvent()),
      //     icon: const Icon(Icons.logout, color: Colors.white),
      //   ),
      // ],
    );
  }

  Widget _buildHomeContent(HomeLoaded state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.h(20),
          HomeStatsCards(stats: state.stats)
              .animate()
              .fadeIn(duration: 600.ms)
              .moveY(begin: 30, end: 0, curve: Curves.easeOutQuad),
          AppSpacing.h(20),
          HomeMonthlyLimit(
                current: state.stats.monthlyExpense,
                limit: state.budgetLimit,
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .moveY(begin: 30, end: 0, curve: Curves.easeOutQuad),
          AppSpacing.h(30),
          Text(
            "Recent Transactions",
            style: AppFontStyle.medium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 400.ms),
          AppSpacing.h(15),
          if (state.transactions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  "No Recent Transactions",
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.transactions.length,
              separatorBuilder: (context, index) => AppSpacing.h(12),
              itemBuilder: (context, index) {
                final tx = state.transactions[index];
                return HomeTransactionItem(
                      tx: tx,
                      onDelete: () {
                        context.read<HomeBloc>().add(
                          DeleteHomeTransactionEvent(tx.id),
                        );
                      },
                    )
                    .animate()
                    .fadeIn(delay: (500 + index * 100).ms)
                    .moveX(begin: 30, end: 0, curve: Curves.easeOutQuad);
              },
            ),
          AppSpacing.h(80),
        ],
      ),
    );
  }
}
