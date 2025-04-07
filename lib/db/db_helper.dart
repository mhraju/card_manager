import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const _databaseName = "sku_database.db";
  static const _databaseVersion = 1;
  static const table = 'sku_table';

  static const columnId = '_id';
  static const columnName = 'name';
  static const columnBName = 'b_name';
  static const columnType = 'type';
  static const columnCard_num = 'card_num';
  static const columnCode = 'code';
  static const columnValid_till = 'valid_till';
  static const columnWaive = 'waive';
  static const columnCount = 'count';

  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion,
        onCreate: (db, version) async {
      await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnBName TEXT NOT NULL,
        $columnType TEXT NOT NULL,
        $columnCard_num TEXT NOT NULL,
        $columnCode INTEGER,
        $columnValid_till TEXT NOT NULL,
        $columnWaive INTEGER,
        $columnCount INTEGER
      )
    ''');
    });
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await database;
    return await db.query(table);
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await database;
    if (!row.containsKey(columnId) || row[columnId] == null) {
      throw Exception('Invalid ID for update operation');
    }
    return await db
        .update(table, row, where: '$columnId = ?', whereArgs: [row[columnId]]);
  }

  Future<int> delete(int id) async {
    Database db = await database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> getWaiverCount(int skuId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'sku_table',
      columns: ['count'],
      where: '_id = ?',
      whereArgs: [skuId],
    );
    return result.isNotEmpty ? result.first['count'] as int : 0;
  }
}
