import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      icon TEXT NOT NULL,
      color TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      amount REAL NOT NULL,
      date INTEGER NOT NULL,
      categoryId INTEGER,
      bankName TEXT,
      notificationContent TEXT,
      FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE SET NULL
    )
    ''');

    await db.insert('categories', {'name': 'Ăn uống', 'icon': 'fastfood', 'color': '#FF5722'});
    await db.insert('categories', {'name': 'Di chuyển', 'icon': 'directions_car', 'color': '#2196F3'});
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}