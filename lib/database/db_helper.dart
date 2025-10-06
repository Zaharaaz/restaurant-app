import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:restaurant_app/data/model/restaurant.dart';

class DbHelper {
  static Database? _database;
  static const String _tableName = 'favorites';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'restaurant.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            pictureId TEXT,
            city TEXT,
            address TEXT,
            rating REAL
          )
        ''');
      },
    );
  }

  /// Insert / update favorite
  Future<void> insertFavorite(Restaurant restaurant) async {
    final db = await database;
    await db.insert(
      _tableName,
      restaurant.toMap(), 
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Ambil semua favorit
  Future<List<Restaurant>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(_tableName);
    return results.map((e) => Restaurant.fromMap(e)).toList(); 
  }

  /// Cek favorit
  Future<bool> isFavorited(String id) async {
    final db = await database;
    final results = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty;
  }

  /// Hapus favorit
  Future<void> removeFavorite(String id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
