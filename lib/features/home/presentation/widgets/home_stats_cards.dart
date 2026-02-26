import 'package:flutter/material.dart';
import '../../../../core/utils/app_fonts.dart';
import '../../../../core/utils/app_space.dart';
import '../../../transactions/data/models/home_stats_model.dart';

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
            "₹${stats.totalIncome.toStringAsFixed(0)}",
            const Color(0xFF1B5E20), // Dark Green
            Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            "Total Expense",
            "₹${stats.totalExpense.toStringAsFixed(0)}",
            const Color(0xFFB71C1C),
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
        color: color,
        borderRadius: BorderRadius.circular(16),
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
