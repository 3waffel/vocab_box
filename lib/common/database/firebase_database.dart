import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vocab_box/common/deck_loader.dart';
import 'package:vocab_box/models/card.dart';

import 'card_database.dart';

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

    final dbRef = users.doc(uid);
    final tableRef = dbRef.collection(table);

    final tableSnapshot = await tableRef.get();
    if (tableSnapshot.docs.length == 0) {
      await dbRef.set(
        {table: tableRef.path},
        SetOptions(merge: true),
      );
      final cardList = await DeckLoader().loadFromAsset();
      for (var card in cardList) {
        await tableRef
            .doc(card.fields[CardField.id].toString())
            .set(card.toMap());
      }
    }
    return dbRef;
  }

  Future<List<Map<String, Object?>>> getLearningFromTable(String table) async {
    final dbRef = await database;
    final tableRef = dbRef.collection(table);
    final tableSnapshot =
        await tableRef.where("isLearning", isEqualTo: 1).get();
    return List.generate(
      tableSnapshot.docs.length,
      (index) => tableSnapshot.docs[index].data(),
    );
  }

  Future<void> createTable(String table) async {
    final tables = await getTableNameList();
    if (tables.contains(table)) {
      return;
    }

    final dbRef = await database;
    final tableRef = dbRef.collection(table);
    await dbRef.set(
      {table: tableRef.path},
      SetOptions(merge: true),
    );
  }

  Future<void> deleteTable(String table) async {
    final dbRef = await database;
    final tableRef = dbRef.collection(table);
    final tableSnapshot = await tableRef.get();

    for (var doc in tableSnapshot.docs) {
      await doc.reference.delete();
    }
    dbRef.update({table: null});
  }

  Future<List<Map<String, Object?>>> getTable(String table) async {
    final dbRef = await database;
    final tableSnapshot = await dbRef.collection(table).get();
    return List.generate(
      tableSnapshot.docs.length,
      (index) => tableSnapshot.docs[index].data(),
    );
  }

  Future<List<String>> getTableNameList() async {
    final dbRef = await database;
    final dbSnapshot = await dbRef.get();
    final data = dbSnapshot.data()!;
    data.removeWhere((key, value) => value == null);
    return List.from(data.keys);
  }

  Future<void> insertMany({
    required Iterable<CardModel> cardList,
    required String table,
  }) async {
    final dbRef = await database;
    final tableRef = dbRef.collection(table);
    for (var card in cardList) {
      await tableRef
          .doc(card.fields[CardField.id].toString())
          .set(card.toMap());
    }
  }

  Future<void> updateMany({
    required Iterable<CardModel> cardList,
    required String table,
  }) async {
    final dbRef = await database;
    final tableRef = dbRef.collection(table);
    for (var card in cardList) {
      await tableRef
          .doc(card.fields[CardField.id].toString())
          .set(card.toMap());
    }
  }
}
