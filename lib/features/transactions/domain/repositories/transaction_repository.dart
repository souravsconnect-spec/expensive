import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/home_stats_model.dart';

abstract class TransactionRepository {
  Future<HomeStatsModel> getHomeStats();
  Future<List<TransactionModel>> getRecentTransactions();
  Future<List<TransactionModel>> getAllTransactions();
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);

  // Category Management
  Future<List<CategoryModel>> getAllCategories();
  Future<void> addCategory(CategoryModel category);
  Future<void> deleteCategory(String id);

  // Budget Limit
  Future<void> setBudgetLimit(double limit);
  Future<double> getBudgetLimit();

  // Sync
  Future<void> syncToCloud();
}
