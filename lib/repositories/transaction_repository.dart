import '../database/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await dbHelper.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactions({int? startTime, int? endTime}) async {
    final db = await dbHelper.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startTime != null && endTime != null) {
      whereClause = 'date >= ? AND date <= ?';
      whereArgs = [startTime, endTime];
    }

    final maps = await db.query(
      'transactions',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'date DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await dbHelper.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<TransactionModel>> getUnclassifiedTransactions() async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'categoryId IS NULL',
      orderBy: 'date DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<int> classifyTransaction(int transactionId, int categoryId) async {
    final db = await dbHelper.database;
    return await db.rawUpdate(
      'UPDATE transactions SET categoryId = ? WHERE id = ?',
      [categoryId, transactionId],
    );
  }

  Future<double> getTodayTotal() async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;

    var result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM transactions WHERE date >= ? AND date <= ?',
        [startOfDay, endOfDay]);

    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<double> getMonthlyTotal(int year, int month) async {
    final db = await dbHelper.database;
    final startOfMonth = DateTime(year, month, 1).millisecondsSinceEpoch;
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59).millisecondsSinceEpoch;

    var result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM transactions WHERE date >= ? AND date <= ?',
        [startOfMonth, endOfMonth]);

    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<List<Map<String, dynamic>>> getTotalByCategory(int year, int month) async {
    final db = await dbHelper.database;
    final startOfMonth = DateTime(year, month, 1).millisecondsSinceEpoch;
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59).millisecondsSinceEpoch;

    final result = await db.rawQuery('''
      SELECT c.name, c.color, SUM(t.amount) as totalAmount
      FROM transactions t
      JOIN categories c ON t.categoryId = c.id
      WHERE t.date >= ? AND t.date <= ?
      GROUP BY c.id
      ORDER BY totalAmount DESC
    ''', [startOfMonth, endOfMonth]);

    return result;
  }
}