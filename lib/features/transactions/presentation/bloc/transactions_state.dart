import 'package:equatable/equatable.dart';
import '../../data/models/transaction_model.dart';

abstract class TransactionsState extends Equatable {
  const TransactionsState();
  @override
  List<Object?> get props => [];
}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<TransactionModel> transactions;
  const TransactionsLoaded(this.transactions);
  @override
  List<Object?> get props => [transactions];

  TransactionsLoaded copyWith({List<TransactionModel>? transactions}) {
    return TransactionsLoaded(transactions ?? this.transactions);
  }
}

class TransactionsError extends TransactionsState {
  final String message;
  const TransactionsError(this.message);
  @override
  List<Object?> get props => [message];
}
