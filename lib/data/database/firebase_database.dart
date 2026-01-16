import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vocab_box/data/database/data_retrieval.dart';
import 'package:vocab_box/data/models/base_model.dart';

typedef FBDatabase = DocumentReference<Map<String, dynamic>>;

class FirebaseDatabase<T extends BaseModel> implements DataRetrieval<T> {
  // static const table = 'default_deck';

  /// private constructor
  // FireBaseDatabase._internal();
  // static final FireBaseDatabase<Never> _instance = FireBaseDatabase._internal();
  // factory FireBaseDatabase() => _instance;
  const FirebaseDatabase();

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
    // final tableRef = dbRef.collection(table);

    // final tableSnapshot = await tableRef.get();
    // if (tableSnapshot.docs.length == 0) {
    //   await dbRef.set(
    //     {table: tableRef.path},
    //     SetOptions(merge: true),
    //   );
    //   final items = await DeckLoader().loadFromAsset();
    //   for (var item in items) {
    //     await tableRef.doc(item.id.toString()).set(item.toMap());
    //   }
    // }
    return dbRef;
  }

  @override
  Future<void> createTable(String table) async {
    final tables = await getTableNames();
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

  @override
  Future<void> deleteTable(String table) async {
    final dbRef = await database;
    final tableRef = dbRef.collection(table);
    final tableSnapshot = await tableRef.get();

    for (var doc in tableSnapshot.docs) {
      await doc.reference.delete();
    }
    dbRef.update({table: null});
  }

  @override
  Future<List<Map<String, Object?>>> getTable(String table) async {
    final dbRef = await database;
    final tableSnapshot = await dbRef.collection(table).get();
    return List.generate(
      tableSnapshot.docs.length,
      (index) => tableSnapshot.docs[index].data(),
    );
  }

  @override
  Future<List<String>> getTableNames() async {
    final dbRef = await database;
    final dbSnapshot = await dbRef.get();
    final data = dbSnapshot.data()!;
    data.removeWhere((key, value) => value == null);
    return List.from(data.keys);
  }

  @override
  Future<void> insertMany({
    required Iterable<T> items,
    required String table,
  }) async {
    final dbRef = await database;
    final tableRef = dbRef.collection(table);
    for (var item in items) {
      await tableRef.doc(item.id.toString()).set(item.toMap());
    }
  }

  @override
  Future<void> updateMany({
    required Iterable<T> items,
    required String table,
  }) async {
    final dbRef = await database;
    final tableRef = dbRef.collection(table);
    for (var item in items) {
      await tableRef.doc(item.id.toString()).set(item.toMap());
    }
  }
}
