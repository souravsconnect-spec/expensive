import 'package:expensive/core/utils/app_colors.dart';
import 'package:expensive/core/utils/app_fonts.dart';
import 'package:expensive/core/utils/app_space.dart';
import 'package:expensive/core/utils/currency_formatter.dart';
import 'package:expensive/features/transactions/data/models/home_stats_model.dart';
import 'package:flutter/material.dart';

class HomeStatsCards extends StatelessWidget {
  final HomeStatsModel stats;
  const HomeStatsCards({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "Total Income",
            CurrencyFormatter.format(stats.totalIncome),
            AppColors.secondary, // Dark Green
            Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            "Total Expense",
            CurrencyFormatter.format(stats.totalExpense),
            AppColors.kRed, // Dark Red
            Icons.arrow_upward,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color,
            const Color.fromARGB(255, 65, 64, 64).withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFontStyle.medium.copyWith(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          AppSpacing.h(10),
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  amount,
                  style: AppFontStyle.xl.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
