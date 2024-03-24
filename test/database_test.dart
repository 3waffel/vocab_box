import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

import 'package:vocab_box/word_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  deleteDatabase(join(await getDatabasesPath(), 'words.db'));

  final database = openDatabase(
    join(await getDatabasesPath(), 'words.db'),
    onCreate: (db, version) async {
      db.execute(
        'CREATE TABLE words(word TEXT, example TEXT, meaning TEXT, correctTimes INTEGER)',
      );

      final wordList = await WordLoader.loadDefaultDeck();
      for (var word in wordList) {
        db.insert(
          'words',
          word.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    },
    version: 1,
  );

  final db = await database;
  final wordsMap = await db.query('words');
  print(wordsMap.length);
  deleteDatabase(join(await getDatabasesPath(), 'words.db'));
}
