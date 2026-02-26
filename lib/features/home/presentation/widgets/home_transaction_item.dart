import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/app_fonts.dart';
import '../../../../core/utils/app_space.dart';
import '../../../transactions/data/models/transaction_model.dart';

class HomeTransactionItem extends StatelessWidget {
  final TransactionModel tx;
  const HomeTransactionItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final bool isDebit = tx.type == 'debit';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconForCategory(tx.categoryName),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.note,
                  style: AppFontStyle.medium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tx.categoryName ?? 'Others',
                  style: AppFontStyle.medium.copyWith(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTimestamp(tx.timestamp),
                style: AppFontStyle.medium.copyWith(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
              AppSpacing.h(4),
              Row(
                children: [
                  Text(
                    "${isDebit ? '-' : '+'}₹${tx.amount.toStringAsFixed(0)}",
                    style: AppFontStyle.medium.copyWith(
                      color: isDebit
                          ? Colors.red.shade400
                          : Colors.green.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.delete, color: Colors.red, size: 20),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String? name) {
    switch (name) {
      case 'Food':
        return Icons.shopping_cart;
      case 'Bills':
        return Icons.lightbulb;
      case 'Transport':
        return Icons.directions_car;
      default:
        return Icons.category;
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      return DateFormat('dth MMM yyyy').format(dt);
    } catch (e) {
      return timestamp;
    }
  }
}
