import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:vocab_box/models/card.dart';

class DeckLoader {
  DeckLoader._internal();
  static final DeckLoader _instance = DeckLoader._internal();
  factory DeckLoader() => _instance;

  static const String bundledDeckPath = 'assets/word_list_a1.txt';

  Future<List<CardModel>> loadFromAsset({
    String path = bundledDeckPath,
  }) async {
    final rawString = await rootBundle.loadString(path);
    return loadFromString(rawString);
  }

  List<CardModel> loadFromString(
    String content, [
    (String, String, String)? format,
    List<CardField>? columns,
  ]) {
    var _format = format ?? ('\t', '\n', '');
    final _converter = CsvToListConverter(
      fieldDelimiter: _format.$1,
      eol: _format.$2,
      convertEmptyTo: _format.$3,
    );
    final fields = _converter.convert(content);

    final List<CardField> _columns = columns ?? CardField.values;

    return List.generate(
      fields.length,
      (index) {
        Map<String, Object?> map = {};
        for (var field in CardField.values) {
          int fieldIndex = _columns.indexOf(field);
          if (fieldIndex != -1) {
            var fieldValue = fields[index][fieldIndex];
            map.putIfAbsent(field.name, () => fieldValue);
          }
        }
        return CardModel.fromMap(map);
      },
    );
  }
}

class LoadingTemplate {}
