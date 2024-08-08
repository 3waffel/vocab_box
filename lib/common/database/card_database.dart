import 'package:flutter/foundation.dart';
import 'package:vocab_box/common/database/firebase_database.dart';
import 'package:vocab_box/common/database/local_database.dart';
import 'package:vocab_box/models/card.dart';

abstract class CardDatabase {
  static const table = 'default_deck';

  Future<void> createTable(String table);
  Future<void> deleteTable(String table);
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

CardDatabase cardDatabase = kIsWeb ? FireBaseDatabase() : LocalDatabase();
