import 'package:equatable/equatable.dart';
import '../../transactions/data/models/category_model.dart';
import '../../transactions/data/models/transaction_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String nickname;
  final double budgetLimit;
  final List<CategoryModel> categories;
  final List<TransactionModel> transactions;
  final String? message;
  final bool isSyncing;

  const ProfileLoaded({
    required this.nickname,
    required this.budgetLimit,
    required this.categories,
    this.transactions = const [],
    this.message,
    this.isSyncing = false,
  });

  @override
  List<Object?> get props => [
    nickname,
    budgetLimit,
    categories,
    transactions,
    message,
    isSyncing,
  ];

  ProfileLoaded copyWith({
    String? nickname,
    double? budgetLimit,
    List<CategoryModel>? categories,
    List<TransactionModel>? transactions,
    String? message,
    bool? isSyncing,
  }) {
    return ProfileLoaded(
      nickname: nickname ?? this.nickname,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      categories: categories ?? this.categories,
      transactions: transactions ?? this.transactions,
      message: message, // Allow setting message to null
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
