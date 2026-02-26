import 'package:equatable/equatable.dart';
import '../../../transactions/data/models/transaction_model.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {}

class DeleteHomeTransactionEvent extends HomeEvent {
  final String id;
  const DeleteHomeTransactionEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class AddHomeTransactionEvent extends HomeEvent {
  final TransactionModel transaction;
  const AddHomeTransactionEvent(this.transaction);
  @override
  List<Object?> get props => [transaction];
}
