import 'package:flutter/foundation.dart';
import 'package:vocab_box/data/database/firebase_database.dart';
import 'package:vocab_box/data/database/local_database.dart';
import 'package:vocab_box/data/models/card_model.dart';

import 'data_retrieval.dart';

enum CardRepository implements DataRetrieval<CardModel> {
  local(_LocalDB),
  firebase(_FBDB);

  static const _LocalDB = const LocalDatabase<CardModel>();
  static const _FBDB = const FireBaseDatabase<CardModel>();

  final DataRetrieval<CardModel> dataRetrieval;
  const CardRepository(this.dataRetrieval);

  Future<void> createTable(String table) => dataRetrieval.createTable(table);
  Future<void> deleteTable(String table) => dataRetrieval.deleteTable(table);

  @override
  Future<List<Map<String, dynamic>>> getTable(String table) async =>
      await dataRetrieval.getTable(table);

  @override
  Future<List<String>> getTableNames() => dataRetrieval.getTableNames();

  @override
  Future<void> insertMany({
    required Iterable<CardModel> items,
    required String table,
  }) =>
      dataRetrieval.insertMany(items: items, table: table);

  @override
  Future<void> updateMany({
    required Iterable<CardModel> items,
    required String table,
  }) =>
      dataRetrieval.updateMany(items: items, table: table);
}

CardRepository cardRepository =
    kIsWeb ? CardRepository.firebase : CardRepository.local;
