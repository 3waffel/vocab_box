import 'package:vocab_box/data/models/base_model.dart';

abstract class DataRetrieval<T extends BaseModel> {
  Future<void> createTable(String table);
  Future<void> deleteTable(String table);
  Future<List<Map<String, dynamic>>> getTable(String table);
  Future<List<String>> getTableNames();
  Future<void> insertMany({
    required Iterable<T> items,
    required String table,
  });
  Future<void> updateMany({
    required Iterable<T> items,
    required String table,
  });
}
