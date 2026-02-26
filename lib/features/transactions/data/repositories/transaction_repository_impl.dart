import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:expensive/core/database/db_helper.dart';
import 'package:expensive/core/services/prefs_service.dart';
import 'package:expensive/features/profile/data/datasources/sync_remote_data_source.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';
import '../models/home_stats_model.dart';
import '../models/category_model.dart';

import 'package:expensive/features/profile/data/models/remote_sync_models.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final DbHelper _dbHelper = DbHelper();
  final PrefsService _prefsService = PrefsService();
  final SyncRemoteDataSource _syncRemoteDataSource;
  Future<void>? _syncFuture;

  TransactionRepositoryImpl(this._syncRemoteDataSource);

  @override
  Future<HomeStatsModel> getHomeStats() async {
    final db = await _dbHelper.database;
    final userId = await _prefsService.getUserId() ?? "system";

    final incomeResult = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type='credit' AND is_deleted=0 AND user_id=?",
      [userId],
    );
    final totalIncome =
        (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final expenseResult = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type='debit' AND is_deleted=0 AND user_id=?",
      [userId],
    );
    final totalExpense =
        (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final now = DateTime.now();
    final month = DateFormat('MM').format(now);
    final year = DateFormat('yyyy').format(now);

    final monthlyResult = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type='debit' AND is_deleted=0 AND strftime('%m', timestamp)=? AND strftime('%Y', timestamp)=? AND user_id=?",
      [month, year, userId],
    );
    final monthlyExpense =
        (monthlyResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return HomeStatsModel(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      monthlyExpense: monthlyExpense,
    );
  }

  @override
  Future<List<TransactionModel>> getRecentTransactions() async {
    final db = await _dbHelper.database;
    final userId = await _prefsService.getUserId() ?? "system";
    final results = await db.rawQuery(
      '''
      SELECT t.*, c.name as category_name
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE t.is_deleted = 0 AND t.user_id = ?
      ORDER BY t.timestamp DESC
      LIMIT 10
    ''',
      [userId],
    );
    return results.map((map) => TransactionModel.fromMap(map)).toList();
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await _dbHelper.database;
    final userId = await _prefsService.getUserId() ?? "system";
    final results = await db.rawQuery(
      '''
      SELECT t.*, c.name as category_name
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE t.is_deleted = 0 AND t.user_id = ?
      ORDER BY t.timestamp DESC
    ''',
      [userId],
    );
    return results.map((map) => TransactionModel.fromMap(map)).toList();
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    print("Local DB: Adding transaction with ID: ${transaction.id}");
    final db = await _dbHelper.database;
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    print("Local DB: Requesting delete for transaction ID: $id");
    final db = await _dbHelper.database;

    // 1. ALWAYS perform a soft-delete locally first to ensure immediate UI update
    await db.update(
      'transactions',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    print("Local DB: Soft-deleted ID: $id");

    // 2. Attempt immediate remote delete in the background
    try {
      final deletedIds = await _syncRemoteDataSource.deleteTransactions([id]);
      if (deletedIds.contains(id)) {
        // If server confirms, we can eventually hard-delete locally during the next full sync purge.
        // For now, keeping it as is_deleted=1 is safe and prevents UI issues.
        print("Remote delete successful for ID: $id");
      }
    } catch (e) {
      print(
        "Immediate remote delete failed (offline?), will retry during next sync: $e",
      );
    }
  }

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    final db = await _dbHelper.database;
    final userId = await _prefsService.getUserId() ?? "system";
    final results = await db.query(
      'categories',
      where: 'is_deleted = 0 AND (user_id = ? OR user_id = "system")',
      whereArgs: [userId],
    );
    return results.map((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    final db = await _dbHelper.database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    print("Local DB: Requesting delete for category ID: $id");
    final db = await _dbHelper.database;

    // 1. Local Soft Delete (Immediate UI update)
    await db.update(
      'categories',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    await db.update(
      'transactions',
      {'is_deleted': 1},
      where: 'category_id = ?',
      whereArgs: [id],
    );
    print("Local DB: Soft-deleted category and its transactions: $id");

    // 2. Remote Cloud delete (Try immediate, fallback to sync)
    try {
      final deletedIds = await _syncRemoteDataSource.deleteCategories([id]);
      if (deletedIds.contains(id)) {
        print("Remote delete successful for category: $id");
      }
    } catch (e) {
      print("Remote category delete failed, will retry during next sync: $e");
    }
  }

  @override
  Future<void> setBudgetLimit(double limit) async {
    await _prefsService.saveBudgetLimit(limit);
  }

  @override
  Future<double> getBudgetLimit() async {
    return await _prefsService.getBudgetLimit();
  }

  @override
  Future<void> syncToCloud() async {
    if (_syncFuture != null) {
      return _syncFuture;
    }
    _syncFuture = _performSync();
    try {
      await _syncFuture;
    } finally {
      _syncFuture = null;
    }
  }

  Future<void> _performSync() async {
    final token = await _prefsService.getToken();
    if (token == null) {
      print("No token found, skipping sync.");
      return;
    }

    final db = await _dbHelper.database;
    final userId = await _prefsService.getUserId() ?? "system";
    print("----- SYNC START (USER: $userId) -----");

    // 1. Handle Deletions (Cloud Purge)
    final deletedTransactions = await db.query(
      'transactions',
      columns: ['id'],
      where: 'is_deleted = 1 AND user_id = ?',
      whereArgs: [userId],
    );
    print("Found ${deletedTransactions.length} deleted transactions to purge");
    if (deletedTransactions.isNotEmpty) {
      final ids = deletedTransactions.map((e) => e['id'] as String).toList();
      final deletedIds = await _syncRemoteDataSource.deleteTransactions(ids);
      print("Remote delete confirmed for transactions: $deletedIds");

      if (deletedIds.isNotEmpty) {
        // Permanently delete only the IDs confirmed by the API
        final placeholders = List.filled(deletedIds.length, '?').join(',');
        await db.delete(
          'transactions',
          where: 'id IN ($placeholders) AND user_id = ?',
          whereArgs: [...deletedIds, userId],
        );
        print(
          "Permanently deleted ${deletedIds.length} transactions from local DB",
        );
      }
    }

    final deletedCategories = await db.query(
      'categories',
      columns: ['id'],
      where: 'is_deleted = 1 AND user_id = ?',
      whereArgs: [userId],
    );
    print("Found ${deletedCategories.length} deleted categories to purge");
    if (deletedCategories.isNotEmpty) {
      final ids = deletedCategories.map((e) => e['id'] as String).toList();
      final deletedIds = await _syncRemoteDataSource.deleteCategories(ids);
      print("Remote delete confirmed for categories: $deletedIds");

      if (deletedIds.isNotEmpty) {
        final placeholders = List.filled(deletedIds.length, '?').join(',');
        await db.delete(
          'categories',
          where: 'id IN ($placeholders) AND user_id = ?',
          whereArgs: [...deletedIds, userId],
        );
        print(
          "Permanently deleted ${deletedIds.length} categories from local DB",
        );
      }
    }

    // 2. Upload New Data (Cloud Backup)
    // Step A: Sync Categories First
    final unsyncedCategories = await db.query(
      'categories',
      where: 'is_synced = 0 AND is_deleted = 0 AND user_id = ?',
      whereArgs: [userId],
    );
    print("Found ${unsyncedCategories.length} unsynced categories to upload");
    if (unsyncedCategories.isNotEmpty) {
      final categories = unsyncedCategories
          .map((e) => CategoryModel.fromMap(e))
          .toList();
      final syncedIds = await _syncRemoteDataSource.addCategories(
        categories.map((e) => e.toJsonSync()).toList(),
      );
      print("Remote sync confirmed for categories: $syncedIds");

      if (syncedIds.isNotEmpty) {
        // Update local is_synced = 1 only for confirmed IDs
        final placeholders = List.filled(syncedIds.length, '?').join(',');
        await db.update(
          'categories',
          {'is_synced': 1},
          where: 'id IN ($placeholders) AND user_id = ?',
          whereArgs: [...syncedIds, userId],
        );
        print("Marked ${syncedIds.length} categories as synced in local DB");
      }
    }

    // Step B: Sync Transactions Next
    final unsyncedTransactions = await db.rawQuery(
      '''
      SELECT t.*, c.name as category_name
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE t.is_synced = 0 AND t.is_deleted = 0 AND t.user_id = ?
      ''',
      [userId],
    );
    print(
      "Found ${unsyncedTransactions.length} unsynced transactions to upload",
    );
    if (unsyncedTransactions.isNotEmpty) {
      final transactions = unsyncedTransactions
          .map((e) => TransactionModel.fromMap(e))
          .toList();
      print(
        "Uploading transaction IDs: ${transactions.map((t) => t.id).toList()}",
      );
      final syncedIds = await _syncRemoteDataSource.addTransactions(
        transactions.map((e) => e.toJsonSync()).toList(),
      );
      print("Remote sync confirmed for transactions: $syncedIds");

      if (syncedIds.isNotEmpty) {
        final placeholders = List.filled(syncedIds.length, '?').join(',');
        await db.update(
          'transactions',
          {'is_synced': 1},
          where: 'id IN ($placeholders) AND user_id = ?',
          whereArgs: [...syncedIds, userId],
        );
        print("Marked ${syncedIds.length} transactions as synced in local DB");
      }
    }
    // 3. PULL AND MERGE FROM CLOUD (Only once after login/install)
    try {
      final isRestored = await _prefsService.isDataRestored();
      if (!isRestored) {
        print("Initial Sync: Restoring data from cloud...");

        // Step A: Pull Categories
        print("Pulling remote categories for user $userId...");
        final List<RemoteCategory> remoteCategories =
            await _syncRemoteDataSource.getCategories(userId);
        for (var remote in remoteCategories) {
          // Find if category already exists locally by name
          final existing = await db.query(
            'categories',
            where: 'name = ? AND user_id = ?',
            whereArgs: [remote.name, userId],
          );

          if (existing.isEmpty) {
            final newCategory = CategoryModel(
              id:
                  remote.categoryId ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              name: remote.name,
              userId: userId,
              isSynced: 1,
              isDeleted: 0,
            );
            await db.insert('categories', newCategory.toMap());
            print("Downloaded new category: ${remote.name}");
          }
        }

        // Step B: Pull Transactions
        print("Pulling remote transactions for user $userId...");
        final List<RemoteTransaction> remoteTransactions =
            await _syncRemoteDataSource.getTransactions(userId);
        for (var remote in remoteTransactions) {
          // Check 1: Exists by ID?
          final existingById = await db.query(
            'transactions',
            where: 'id = ?',
            whereArgs: [remote.id],
          );

          if (existingById.isNotEmpty) {
            print(
              "Sync: Transaction ${remote.id} already exists locally. Skipping.",
            );
            continue;
          }

          // Check 2: Exists by content? (De-duplication)
          // Look for local un-synced transactions that have identical info but different ID
          final existingByContent = await db.query(
            'transactions',
            where: 'amount = ? AND note = ? AND type = ? AND user_id = ?',
            whereArgs: [remote.amount, remote.note, remote.type, userId],
          );

          if (existingByContent.isNotEmpty) {
            // Found a match! Update local one with the server ID to "link" them
            final localId = existingByContent.first['id'] as String;
            await db.update(
              'transactions',
              {'id': remote.id, 'is_synced': 1},
              where: 'id = ?',
              whereArgs: [localId],
            );
            print(
              "Sync: Merged local transaction $localId with remote ${remote.id} by content.",
            );
            continue;
          }

          // No match, so insert as new
          // Find matching local category ID by name
          final catResult = await db.query(
            'categories',
            where: 'LOWER(name) = LOWER(?) AND user_id = ?',
            whereArgs: [(remote.category ?? 'Others').trim(), userId],
          );

          String catId;
          if (catResult.isNotEmpty) {
            catId = catResult.first['id'] as String;
          } else {
            catId = DateTime.now().millisecondsSinceEpoch.toString();
            await db.insert('categories', {
              'id': catId,
              'name': remote.category ?? 'Others',
              'user_id': userId,
              'is_synced': 1,
              'is_deleted': 0,
            });
          }

          final newTx = TransactionModel(
            id: remote.id,
            amount: remote.amount,
            note: remote.note,
            type: remote.type,
            categoryId: catId,
            userId: userId,
            timestamp: remote.timestamp,
            isSynced: 1,
            isDeleted: 0,
          );
          await db.insert('transactions', newTx.toMap());
          print(
            "Downloaded and merged new transaction. ID: ${remote.id}, Note: ${remote.note}",
          );
        }

        // Mark restore as completed
        await _prefsService.setDataRestored(true);
        print("Initial data restore completed successfully.");
      } else {
        print(
          "Data already restored once. Skipping cloud pull to avoid duplicates.",
        );
      }
    } catch (e) {
      print("Error during cloud pull/restore: $e");
    }

    print("----- SYNC END -----");
  }
}
