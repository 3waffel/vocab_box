import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vocab_box/common/deck_loader.dart';
import 'package:vocab_box/models/card.dart';

abstract class CardDatabase {
  static const table = 'default_deck';

  Future<List<Map<String, Object?>>> getTable(String table);
  Future<List<Map<String, Object?>>> getLearningFromTable(String table);
  Future<List<String>> getTableNameList();
  Future<void> insertMany({
    required Iterable<CardModel> cardList,
    required String table,
  });
  Future<void> updateMany({
    required Iterable<CardModel> cardList,
    required String table,
  });
}

CardDatabase cardDatabase = LocalDatabase();

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

typedef FBDatabase = DocumentReference<Map<String, dynamic>>;

class FireBaseDatabase implements CardDatabase {
  static const table = 'default_deck';

  /// private constructor
  FireBaseDatabase._internal();
  static final FireBaseDatabase _instance = FireBaseDatabase._internal();
  factory FireBaseDatabase() => _instance;

  static FBDatabase? _database = null;
  Future<FBDatabase> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _openDatabase();
    return _database!;
  }

  Future<FBDatabase> _openDatabase() async {
    final auth = FirebaseAuth.instance;
    final uid = auth.currentUser!.uid;
    final users = FirebaseFirestore.instance.collection("users");
    final db = await users.doc(uid);

    final tableRef = db.collection(table);
    final tableSnapshot = await tableRef.get();
    await db.set({table: tableRef.path});
    if (tableSnapshot.docs.length == 0) {
      final cardList = await DeckLoader().loadFromFile();
      for (var card in cardList) {
        await tableRef.doc(card.id.toString()).set(card.toMap());
      }
    }
    return db;
  }

  Future<List<Map<String, Object?>>> getLearningFromTable(String table) async {
    final db = await database;
    final snapshot =
        await db.collection(table).where("isLearning", isEqualTo: 1).get();
    return List.generate(
        snapshot.docs.length, (index) => snapshot.docs[index].data());
  }

  Future<List<Map<String, Object?>>> getTable(String table) async {
    final db = await database;
    final snapshot = await db.collection(table).get();
    return List.generate(
        snapshot.docs.length, (index) => snapshot.docs[index].data());
  }

  Future<List<String>> getTableNameList() async {
    final db = await database;
    final snapshot = await db.get();
    return List.from(snapshot.data()!.keys);
  }

  Future<void> insertMany({
    required Iterable<CardModel> cardList,
    required String table,
  }) async {
    final db = await database;
    for (var item in cardList) {
      await db.collection(table).doc(item.id.toString()).set(item.toMap());
    }
  }

  Future<void> updateMany({
    required Iterable<CardModel> cardList,
    required String table,
  }) async {
    final db = await database;
    for (var item in cardList) {
      await db.collection(table).doc(item.id.toString()).set(item.toMap());
    }
  }
}
