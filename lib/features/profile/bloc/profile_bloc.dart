import 'package:expensive/core/services/notification_service.dart';
import 'package:expensive/core/services/prefs_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../transactions/data/models/category_model.dart';
import '../../transactions/domain/repositories/transaction_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final TransactionRepository _repository;
  final PrefsService _prefsService = PrefsService();

  ProfileBloc(this._repository) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateNicknameEvent>(_onUpdateNickname);
    on<SetBudgetLimitEvent>(_onSetBudgetLimit);
    on<AddCategoryEvent>(_onAddCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<SyncToCloudEvent>(_onSyncToCloud);
  }

  Future<void> _onSyncToCloud(
    SyncToCloudEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;

    if (currentState.isSyncing) return;

    emit(currentState.copyWith(isSyncing: true, message: null));

    try {
      await _repository.syncToCloud();

      final categories = await _repository.getAllCategories();
      final transactions = await _repository.getAllTransactions();

      emit(
        currentState.copyWith(
          categories: categories,
          transactions: transactions,
          isSyncing: false,
          message: "Cloud synchronization successful!",
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          isSyncing: false,
          message: "Sync failed: ${e.toString()}",
        ),
      );
    }
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      // 1. Force sync to get latest categories and limit from cloud
      await _repository.syncToCloud();

      // 2. Load from local DB
      final nickname = await _prefsService.getNickname();
      final limit = await _repository.getBudgetLimit();
      final categories = await _repository.getAllCategories();
      final transactions = await _repository.getAllTransactions();
      emit(
        ProfileLoaded(
          nickname: nickname ?? "User",
          budgetLimit: limit,
          categories: categories,
          transactions: transactions,
        ),
      );
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateNickname(
    UpdateNicknameEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _prefsService.saveNickname(event.nickname);
      if (state is ProfileLoaded) {
        emit((state as ProfileLoaded).copyWith(nickname: event.nickname));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onSetBudgetLimit(
    SetBudgetLimitEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _repository.setBudgetLimit(event.limit);

      // Check if current spending already exceeds this new limit
      final stats = await _repository.getHomeStats();
      print(
        "SYNC_DEBUG: Monthly Expense: ${stats.monthlyExpense}, New Limit: ${event.limit}",
      );

      if (stats.monthlyExpense >= event.limit) {
        print("SYNC_DEBUG: Limit EXCEEDED. Sending notification...");
        await NotificationService().showNotification(
          "Budget Limit Exceeded!",
          "Your current monthly spending (₹${stats.monthlyExpense.toStringAsFixed(0)}) is already over the new limit of ₹${event.limit.toStringAsFixed(0)}",
        );
      }

      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        emit(
          currentState.copyWith(
            budgetLimit: event.limit,
            message: "Budget limit updated successfully!",
          ),
        );
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onAddCategory(
    AddCategoryEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final userId = await _prefsService.getUserId() ?? "system";
    final tempId = const Uuid().v4();
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      final tempCategory = CategoryModel(
        id: tempId,
        name: event.name,
        userId: userId,
        isSynced: 0,
        isDeleted: 0,
      );
      emit(
        currentState.copyWith(
          categories: [...currentState.categories, tempCategory],
        ),
      );
    }
    try {
      final newCategory = CategoryModel(
        id: tempId,
        name: event.name,
        userId: userId,
        isSynced: 0,
        isDeleted: 0,
      );
      await _repository.addCategory(newCategory);
      final categories = await _repository.getAllCategories();
      if (state is ProfileLoaded) {
        emit((state as ProfileLoaded).copyWith(categories: categories));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      final updatedList = currentState.categories
          .where((c) => c.id != event.id)
          .toList();
      emit(currentState.copyWith(categories: updatedList));
    }
    try {
      await _repository.deleteCategory(event.id);
      final categories = await _repository.getAllCategories();
      if (state is ProfileLoaded) {
        emit((state as ProfileLoaded).copyWith(categories: categories));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
