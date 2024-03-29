import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:vocab_box/models/card.dart';

class DeckLoader {
  DeckLoader._internal();
  static final DeckLoader _instance = DeckLoader._internal();
  factory DeckLoader() => _instance;

  static List<CardModel>? _cardList;
  List<CardModel> get cardList => _cardList ?? [];
  set cardList(List<CardModel> cardList) => _cardList = cardList;

  static Iterable<CardModel> _learningGroup = [];
  Iterable<CardModel> get learningGroup => _learningGroup;
  set learningGroup(Iterable<CardModel> learningGroup) =>
      _learningGroup = learningGroup;

  Future<List<CardModel>> loadDefaultDeck() async {
    final rawString = await rootBundle.loadString('assets/word_list_a1.txt');
    final fields = CsvToListConverter(
      fieldDelimiter: '\t',
      eol: '\n',
      convertEmptyTo: '',
    ).convert(rawString);

    _cardList = List.generate(
      fields.length,
      (index) => CardModel(
        id: index + 1,
        word: fields[index][1],
        example: fields[index][2],
        meaning: fields[index][3],
      ),
    );
    return _cardList!;
  }
}
