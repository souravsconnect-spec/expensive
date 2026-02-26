import 'package:expensive/core/utils/app_fonts.dart';
import 'package:expensive/core/utils/app_space.dart';
import 'package:expensive/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

class HomeMonthlyLimit extends StatelessWidget {
  final double current;
  final double limit;

  const HomeMonthlyLimit({
    super.key,
    required this.current,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint("HomeMonthlyLimit: current=$current, limit=$limit");

    // Bar progress capped at 1.0 (full)
    double barProgress = limit > 0 ? (current / limit) : 0.0;
    if (barProgress > 1.0) barProgress = 1.0;
    if (barProgress < 0) barProgress = 0;

    // Actual usage percentage capped at 100%
    double spentPercentage = limit > 0 ? (current / limit) * 100 : 0;
    if (spentPercentage > 100) spentPercentage = 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "MONTHLY LIMIT",
            style: AppFontStyle.medium.copyWith(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          AppSpacing.h(10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: CurrencyFormatter.format(current),
                  style: AppFontStyle.medium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: " / ${CurrencyFormatter.format(limit)}",
                  style: AppFontStyle.medium.copyWith(
                    color: Colors.white54,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.h(15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: barProgress,
              backgroundColor: Colors.grey.shade800,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 8,
            ),
          ),
          AppSpacing.h(10),
          Text(
            "${spentPercentage.toStringAsFixed(0)}% Used",
            style: AppFontStyle.medium.copyWith(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
