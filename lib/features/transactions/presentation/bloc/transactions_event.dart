import 'package:equatable/equatable.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAllTransactionsEvent extends TransactionsEvent {}

class DeleteTransactionEvent extends TransactionsEvent {
  final String id;
  const DeleteTransactionEvent(this.id);
  @override
  List<Object?> get props => [id];
}
