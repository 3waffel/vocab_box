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

    assert(_columns.toSet().containsAll({
      CardField.frontTitle,
      CardField.frontSubtitle,
      CardField.backTitle,
    }));

    return List.generate(
      fields.length,
      (index) {
        var _id = _columns.contains(CardField.id)
            ? fields[index][_columns.indexOf(CardField.id)]
            : index + 1;
        return CardModel(
          id: _id is int ? _id : index + 1,
          frontTitle:
              fields[index][_columns.indexOf(CardField.frontTitle)].toString(),
          frontSubtitle: fields[index]
                  [_columns.indexOf(CardField.frontSubtitle)]
              .toString(),
          backTitle:
              fields[index][_columns.indexOf(CardField.backTitle)].toString(),
        );
      },
    );
  }
}

class LoadingTemplate {}
