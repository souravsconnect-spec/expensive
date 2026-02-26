import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expensive.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE categories ADD COLUMN user_id TEXT DEFAULT 'system'",
      );
      await db.execute(
        "ALTER TABLE transactions ADD COLUMN user_id TEXT DEFAULT 'system'",
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        user_id TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        note TEXT,
        type TEXT NOT NULL,
        category_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Insert default categories for 'system' or default user
    final List<Map<String, String>> defaultCategories = [
      {'id': 'cat_food', 'name': 'Food'},
      {'id': 'cat_bills', 'name': 'Bills'},
      {'id': 'cat_transport', 'name': 'Transport'},
      {'id': 'cat_others', 'name': 'Others'},
    ];

    for (var cat in defaultCategories) {
      await db.insert('categories', {
        'id': cat['id'],
        'name': cat['name'],
        'user_id':
            'system', // System categories available to all? Or just seed for first user.
        'is_synced': 0,
        'is_deleted': 0,
      });
    }
  }

  // Wipes all user data on logout
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('categories');
    await db.delete('transactions');
    print("Local Database: All transactions and categories have been cleared.");
  }
}
