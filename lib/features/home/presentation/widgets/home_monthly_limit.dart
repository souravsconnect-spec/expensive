import 'package:flutter/material.dart';
import '../../../../core/utils/app_fonts.dart';
import '../../../../core/utils/app_space.dart';

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
    double progress = current / limit;
    if (progress > 1.0) progress = 1.0;
    int remainingPercent = ((1 - progress) * 100).toInt();

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
          Text(
            "₹${current.toInt()} / ₹${limit.toInt()}",
            style: AppFontStyle.medium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.h(15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade800,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 8,
            ),
          ),
          AppSpacing.h(10),
          Text(
            "$remainingPercent% Remaining",
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
