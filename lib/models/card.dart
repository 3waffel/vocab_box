import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardModel {
  final int id;
  final String word;
  final String example;
  final String meaning;
  int correctTimes = 0;
  Color color = Colors.white70;

  static String get fields {
    return '''
      id INTEGER PRIMARY KEY,
      word TEXT,
      example TEXT,
      meaning TEXT,
      correctTimes INTEGER
    ''';
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'word': word,
      'example': example,
      'meaning': meaning,
      'correctTimes': correctTimes,
    };
  }

  CardModel({
    required this.id,
    required this.word,
    required this.example,
    required this.meaning,
    this.correctTimes = 0,
  }) {
    switch (word.split(' ')[0]) {
      case 'der':
        color = Colors.blueAccent;
      case 'das':
        color = Colors.greenAccent;
      case 'die':
        color = Colors.redAccent;
    }
  }

  @override
  String toString() {
    return '$word|$example|$meaning|$correctTimes';
  }
}

class DeckLoader {
  static Future<List<CardModel>> loadDefaultDeck() async {
    final rawString = await rootBundle.loadString('assets/word_list_a1.txt');
    final fields = CsvToListConverter(
      fieldDelimiter: '\t',
      eol: '\n',
      convertEmptyTo: '',
    ).convert(rawString);

    final List<CardModel> cardList = List.generate(
      fields.length,
      (index) => CardModel(
        id: index + 1,
        word: fields[index][1],
        example: fields[index][2],
        meaning: fields[index][3],
      ),
    );
    return cardList;
  }
}
