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

  List<CardModel> loadFromString(String content) {
    final fields = CsvToListConverter(
      fieldDelimiter: '\t',
      eol: '\n',
      convertEmptyTo: '',
    ).convert(content);

    return List.generate(
      fields.length,
      (index) => CardModel(
        id: index + 1,
        frontTitle: fields[index][1],
        frontSubtitle: fields[index][2],
        backTitle: fields[index][3],
      ),
    );
  }
}

class LoadingTemplate {}
