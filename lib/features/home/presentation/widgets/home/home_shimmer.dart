import 'package:expensive/features/transactions/data/models/home_stats_model.dart';
import 'package:expensive/features/transactions/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:expensive/core/utils/app_fonts.dart';
import 'package:expensive/core/utils/app_space.dart';
import 'home_monthly_limit.dart';
import 'home_stats_cards.dart';
import 'home_transaction_item.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for skeleton
    final dummyStats = const HomeStatsModel(
      totalIncome: 1000,
      totalExpense: 500,
      monthlyExpense: 300,
    );

    final dummyTransactions = List.generate(
      5,
      (index) => TransactionModel(
        id: 'skeleton_$index',
        amount: 200,
        note: 'Skeleton Transaction Note',
        type: 'debit',
        categoryId: 'skeleton',
        userId: 'skeleton',
        timestamp: '2026-02-26 20:00:00',
        isSynced: 1,
        isDeleted: 0,
      ),
    );

    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: Colors.grey[900]!,
        highlightColor: Colors.grey[800]!,
        duration: const Duration(seconds: 1),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.h(20),
            HomeStatsCards(stats: dummyStats),
            AppSpacing.h(20),
            HomeMonthlyLimit(current: 300, limit: 1000),
            AppSpacing.h(30),
            Text(
              "Recent Transactions",
              style: AppFontStyle.medium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.h(15),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => AppSpacing.h(12),
              itemBuilder: (context, index) => HomeTransactionItem(
                tx: dummyTransactions[index],
                onDelete: () {},
              ),
            ),
            AppSpacing.h(80),
          ],
        ),
      ),
    );
  }
}
