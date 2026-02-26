import 'package:equatable/equatable.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/data/models/home_stats_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String userName;
  final HomeStatsModel stats;
  final List<TransactionModel> transactions;
  final double budgetLimit;

  const HomeLoaded({
    required this.userName,
    required this.stats,
    required this.transactions,
    required this.budgetLimit,
  });

  @override
  List<Object?> get props => [userName, stats, transactions, budgetLimit];

  HomeLoaded copyWith({
    String? userName,
    HomeStatsModel? stats,
    List<TransactionModel>? transactions,
    double? budgetLimit,
  }) {
    return HomeLoaded(
      userName: userName ?? this.userName,
      stats: stats ?? this.stats,
      transactions: transactions ?? this.transactions,
      budgetLimit: budgetLimit ?? this.budgetLimit,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
