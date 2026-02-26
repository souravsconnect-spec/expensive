import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final TransactionRepository _repository;

  TransactionsBloc(this._repository) : super(TransactionsInitial()) {
    on<LoadAllTransactionsEvent>(_onLoadAllTransactions);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  Future<void> _onLoadAllTransactions(
    LoadAllTransactionsEvent event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(TransactionsLoading());
    try {
      // 1. Always attempt cloud pull first if this user is newly logged in
      await _repository.syncToCloud();

      // 2. Fetch from updated local DB
      final transactions = await _repository.getAllTransactions();
      emit(TransactionsLoaded(transactions));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionsState> emit,
  ) async {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      final updatedList = currentState.transactions
          .where((t) => t.id != event.id)
          .toList();
      emit(currentState.copyWith(transactions: updatedList));
    }
    try {
      await _repository.deleteTransaction(event.id);
      add(LoadAllTransactionsEvent());
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }
}
