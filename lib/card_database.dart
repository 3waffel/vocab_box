import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vocab_box/models/card.dart';

class CardDatabase {
  static final CardDatabase _instance = CardDatabase._internal();
  static Database? _database;

  /// private constructor
  CardDatabase._internal();

  factory CardDatabase() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<String> get databasePath async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, 'records.db');
  }

  Future<Database> _initDatabase() async {
    final path = await databasePath;
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      final databaseFactory = databaseFactoryFfi;
      final database = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDatabase,
        ),
      );
      return database;
    } else if (Platform.isAndroid || Platform.isIOS) {
      final database = await openDatabase(
        path,
        version: 1,
        onCreate: _createDatabase,
      );
      return database;
    }
    throw Exception("Unsupported platform");
  }

  Future<void> _createDatabase(Database db, int version) async {
    return await db.execute('''
      CREATE TABLE IF NOT EXISTS cards (
        ${CardModel.fields}
      )
    ''');
  }
}
