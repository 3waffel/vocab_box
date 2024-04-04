import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vocab_box/deck_loader.dart';
import 'package:vocab_box/models/card.dart';

class CardDatabase {
  static final _databaseName = 'records.db';
  static final _databaseVersion = 1;
  static const table = 'default_deck';

  /// private constructor
  CardDatabase._internal();
  static final CardDatabase _instance = CardDatabase._internal();
  factory CardDatabase() => _instance;

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<String> get databasePath async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, _databaseName);
  }

  Future<Database> _initDatabase() async {
    final path = await databasePath;
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      final databaseFactory = databaseFactoryFfi;
      final database = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: _databaseVersion,
          onCreate: _createDatabase,
        ),
      );
      return database;
    } else if (Platform.isAndroid || Platform.isIOS) {
      final database = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createDatabase,
      );
      return database;
    }
    throw Exception("Unsupported platform");
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        ${CardModel.fields}
      )
    ''');
    final cardList = await DeckLoader().loadFromFile();
    for (final card in cardList) {
      await db.insert(
        table,
        card.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Map<String, Object?>>> getTable(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<List<Map<String, Object?>>> getLearningFromTable(String table) async {
    final db = await database;
    return await db.query(table, where: 'isLearning = ?', whereArgs: [1]);
  }

  Future<List<String>> getTableNameList() async {
    final db = await database;
    final maps = await db.rawQuery('''
        SELECT name FROM sqlite_master
        WHERE type = 'table'
          AND name NOT IN ('sqlite_sequence', 'android_metadata')
        ORDER BY name
        ''');
    return List.generate(
        maps.length, (index) => maps[index]['name'].toString());
  }

  Future<void> insertMany({
    required Iterable<CardModel> cardList,
    required String table,
  }) async {
    final db = await database;
    for (final card in cardList) {
      await db.insert(
        table,
        card.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> updateMany({
    required Iterable<CardModel> cardList,
    required String table,
  }) async {
    final db = await database;
    for (final card in cardList) {
      await db.update(
        table,
        card.toMap(),
        where: 'id = ?',
        whereArgs: [card.id],
      );
    }
  }
}
