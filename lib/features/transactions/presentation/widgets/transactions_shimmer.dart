import 'package:expensive/features/transactions/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:expensive/core/utils/app_space.dart';
import 'package:expensive/features/home/presentation/widgets/home/home_transaction_item.dart';

class TransactionsShimmer extends StatelessWidget {
  const TransactionsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyTransactions = List.generate(
      10,
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
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: 10,
        separatorBuilder: (context, index) => AppSpacing.h(12),
        itemBuilder: (context, index) =>
            HomeTransactionItem(tx: dummyTransactions[index], onDelete: () {}),
      ),
    );
  }
}
