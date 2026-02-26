import 'package:expensive/core/services/notification_service.dart';
import 'package:expensive/core/services/prefs_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/transactions/domain/repositories/transaction_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final TransactionRepository _repository;

  HomeBloc(this._repository) : super(HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<DeleteHomeTransactionEvent>(_onDeleteTransaction);
    on<AddHomeTransactionEvent>(_onAddTransaction);
  }

  Future<void> _onDeleteTransaction(
    DeleteHomeTransactionEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final updatedList = currentState.transactions
          .where((t) => t.id != event.id)
          .toList();
      emit(currentState.copyWith(transactions: updatedList));
    }
    try {
      await _repository.deleteTransaction(event.id);
      add(LoadHomeDataEvent());
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(
    AddHomeTransactionEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final updatedList = [event.transaction, ...currentState.transactions];
      emit(currentState.copyWith(transactions: updatedList));
    }
    try {
      await _repository.addTransaction(event.transaction);

      // Check budget limit after addition
      final stats = await _repository.getHomeStats();
      final limit = await _repository.getBudgetLimit();

      print(
        "SYNC_DEBUG (Home): Monthly Expense: ${stats.monthlyExpense}, Limit: $limit",
      );

      if (stats.monthlyExpense >= limit && limit > 0) {
        print("SYNC_DEBUG (Home): Limit EXCEEDED. Sending notification...");
        await NotificationService().showNotification(
          "Budget Limit Exceeded!",
          "Your monthly spending (₹${stats.monthlyExpense.toStringAsFixed(0)}) has crossed your limit of ₹${limit.toStringAsFixed(0)}",
        );
      }

      add(LoadHomeDataEvent());
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      await _repository.syncToCloud();

      final nickname = await PrefsService().getNickname();
      final stats = await _repository.getHomeStats();
      final transactions = await _repository.getRecentTransactions();
      final limit = await _repository.getBudgetLimit();
      emit(
        HomeLoaded(
          userName: nickname ?? 'User',
          stats: stats,
          transactions: transactions,
          budgetLimit: limit,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
