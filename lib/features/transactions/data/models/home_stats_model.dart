import 'package:equatable/equatable.dart';

class HomeStatsModel extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double monthlyExpense;

  const HomeStatsModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.monthlyExpense,
  });

  @override
  List<Object?> get props => [totalIncome, totalExpense, monthlyExpense];
}
