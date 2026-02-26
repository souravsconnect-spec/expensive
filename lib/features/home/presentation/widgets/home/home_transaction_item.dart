import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expensive/core/utils/app_fonts.dart';
import 'package:expensive/core/utils/app_space.dart';
import 'package:expensive/core/utils/currency_formatter.dart';
import 'package:expensive/features/transactions/data/models/transaction_model.dart';

class HomeTransactionItem extends StatelessWidget {
  final TransactionModel tx;
  final VoidCallback? onDelete;
  const HomeTransactionItem({super.key, required this.tx, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final bool isDebit = tx.type == 'debit';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              color: Colors.white.withOpacity(0.08),
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
              AppSpacing.h(4),
              Row(
                children: [
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
                      Text(
                        "${isDebit ? '-' : '+'}${CurrencyFormatter.format(tx.amount)}",
                        style: AppFontStyle.medium.copyWith(
                          color: isDebit
                              ? Colors.red.shade400
                              : Colors.green.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.w(8),
                  if (onDelete != null)
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                    )
                  else
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
