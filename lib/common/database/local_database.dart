import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vocab_box/common/deck_loader.dart';
import 'package:vocab_box/models/card.dart';

import 'card_database.dart';

class LocalDatabase implements CardDatabase {
  static final _databaseName = 'records.db';
  static final _databaseVersion = 1;
  static const table = 'default_deck';

  /// private constructor
  LocalDatabase._internal();
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _openDatabase(await databasePath);
    return _database!;
  }

  Future<String> get databasePath async {
    final prefs = await SharedPreferences.getInstance();
    final persistedDir = prefs.getString('persistedStoragePath')!;
    final path = join(persistedDir, _databaseName);
    return path;
  }

  Future<Database> _openDatabase(String path) async {
    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
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
    final cardList = await DeckLoader().loadFromAsset();
    for (final card in cardList) {
      await db.insert(
        table,
        card.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> createTable(String table) async {
    final db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        ${CardModel.fields}
      )
    ''');
  }

  Future<void> deleteTable(String table) async {
    final db = await database;
    await db.execute('''
      DROP TABLE IF EXISTS $table
    ''');
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
