import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:vocab_box/card_database.dart';

import 'package:vocab_box/models/card.dart';

void main() async {
  final path = await CardDatabase().databasePath;
  deleteDatabase(path);
  final db = await CardDatabase().database;

  final cardsMap = await db.query('cards');
  print(cardsMap.length);
  deleteDatabase(path);
}
