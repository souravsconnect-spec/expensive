import 'package:expensive/features/transactions/presentation/widgets/transactions_shimmer.dart';
import 'package:expensive/features/home/presentation/widgets/home/home_transaction_item.dart';
import 'package:expensive/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/app_fonts.dart';
import '../../../../core/utils/app_space.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';
import '../bloc/transactions_state.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initial fetch if state is initial
    if (context.read<TransactionsBloc>().state is TransactionsInitial) {
      context.read<TransactionsBloc>().add(LoadAllTransactionsEvent());
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Transactions",
          style: AppFontStyle.large.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<TransactionsBloc, TransactionsState>(
        builder: (context, state) {
          if (state is TransactionsLoading) {
            return const TransactionsShimmer();
          } else if (state is TransactionsLoaded) {
            return LayoutBuilder(
              builder: (context, constraints) {
                if (state.transactions.isEmpty) {
                  return Center(
                    child: Text(
                      "No transactions yet",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          constraints,
                          14,
                        ),
                      ),
                    ),
                  ).animate().fadeIn();
                }
                return ListView.separated(
                  padding: ResponsiveHelper.getResponsivePaddingHV(
                    constraints,
                    20,
                    20,
                  ),
                  itemCount: state.transactions.length,
                  separatorBuilder: (context, index) => AppSpacing.h(
                    ResponsiveHelper.getResponsiveHeight(constraints, 12),
                  ),
                  itemBuilder: (context, index) {
                    final tx = state.transactions[index];
                    return HomeTransactionItem(
                          tx: tx,
                          onDelete: () {
                            context.read<TransactionsBloc>().add(
                              DeleteTransactionEvent(tx.id),
                            );
                          },
                        )
                        .animate()
                        .fadeIn(delay: (index * 50).ms)
                        .moveX(begin: 20, end: 0, curve: Curves.easeOutQuad);
                  },
                );
              },
            );
          } else if (state is TransactionsError) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: Text(
                    state.message,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        constraints,
                        14,
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
