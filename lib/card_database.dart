import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vocab_box/models/card.dart';

class CardDatabase {
  static final _databaseName = 'records.db';
  static final _databaseVersion = 1;
  static final table = 'cards';

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
    return await db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        ${CardModel.fields}
      )
    ''');
  }
}
