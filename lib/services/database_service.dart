import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pocket_hisab.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE hisab_transactions ADD COLUMN is_old INTEGER NOT NULL DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE emis ADD COLUMN due_day_of_month INTEGER NOT NULL DEFAULT 1',
          );
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE emis ADD COLUMN last_paid_at TEXT');
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE expenses ADD COLUMN payment_type TEXT DEFAULT "Cash"');
          await db.execute('ALTER TABLE wallet_transactions ADD COLUMN payment_type TEXT DEFAULT "Cash"');
          await db.execute('ALTER TABLE hisab_transactions ADD COLUMN payment_type TEXT DEFAULT "Cash"');
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. expenses
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        payment_method TEXT NOT NULL DEFAULT 'Wallet',
        payment_type TEXT NOT NULL DEFAULT 'Cash'
      )
    ''');

    // 2. wallets
    await db.execute('''
      CREATE TABLE wallets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        wallet_name TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 3. wallet_transactions
    await db.execute('''
      CREATE TABLE wallet_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        wallet_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        source TEXT NOT NULL,
        note TEXT,
        payment_type TEXT NOT NULL DEFAULT 'Cash',
        created_at TEXT NOT NULL,
        FOREIGN KEY (wallet_id) REFERENCES wallets (id) ON DELETE CASCADE
      )
    ''');

    // 4. salaries
    await db.execute('''
      CREATE TABLE salaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        month TEXT NOT NULL,
        year INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 5. emis
    await db.execute('''
      CREATE TABLE emis (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        total_amount REAL NOT NULL,
        paid_amount REAL NOT NULL DEFAULT 0,
        remaining_amount REAL NOT NULL,
        monthly_amount REAL NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        due_day_of_month INTEGER NOT NULL DEFAULT 1,
        last_paid_at TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 6. hisab_transactions
    await db.execute('''
      CREATE TABLE hisab_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        person_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        amount_paid REAL NOT NULL DEFAULT 0,
        remaining_amount REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        is_old INTEGER NOT NULL DEFAULT 0,
        note TEXT,
        payment_type TEXT NOT NULL DEFAULT 'Cash',
        created_at TEXT NOT NULL,
        FOREIGN KEY (person_id) REFERENCES persons(id)
      )
    ''');

    // 7. persons
    await db.execute('''
    CREATE TABLE persons (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      person_name TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
    ''');

    // 8. savings
    await db.execute('''
      CREATE TABLE savings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        saving_name TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 9. saving_transactions
    await db.execute('''
      CREATE TABLE saving_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        saving_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        source TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (saving_id) REFERENCES savings (id) ON DELETE CASCADE
      )
    ''');

    // 10. monthly_archives
    await _createMonthlyArchivesTable(db);
  }

  Future<void> _createMonthlyArchivesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS monthly_archives (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month TEXT NOT NULL,
        year INTEGER NOT NULL,
        salary_amount REAL NOT NULL DEFAULT 0,
        total_expenses REAL NOT NULL DEFAULT 0,
        total_added_to_savings REAL NOT NULL DEFAULT 0,
        total_added_to_wallet REAL NOT NULL DEFAULT 0,
        wallet_balance_at_reset REAL NOT NULL DEFAULT 0,
        savings_balance_at_reset REAL NOT NULL DEFAULT 0,
        wallet_kept INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // ─────────────────────────── Generic helpers ───────────────────────────

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return db.query(table, orderBy: 'id DESC');
  }

  Future<Map<String, dynamic>?> getById(String table, int id) async {
    final db = await database;
    final rows = await db.query(table, where: 'id = ?', whereArgs: [id]);
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<int> update(String table, Map<String, dynamic> data, int id) async {
    final db = await database;
    return db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteWhere(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? args,
  ]) async {
    final db = await database;
    return db.rawQuery(sql, args);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _db = null;
  }
}
