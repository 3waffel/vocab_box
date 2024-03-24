import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class WordModel {
  final String word;
  final String example;
  final String meaning;
  int correctTimes = 0;

  WordModel({
    required this.word,
    required this.example,
    required this.meaning,
  });

  Map<String, Object?> toMap() {
    return {
      'word': word,
      'example': example,
      'meaning': meaning,
      'correctTimes': correctTimes,
    };
  }

  @override
  String toString() {
    return '$word|$example|$meaning|$correctTimes';
  }
}

class WordLoader {
  static Future<List<WordModel>> loadDefaultDeck() async {
    final rawString = await rootBundle.loadString('assets/word_list_a1.txt');
    final fields = CsvToListConverter(
      fieldDelimiter: '\t',
      eol: '\n',
      convertEmptyTo: '',
    ).convert(rawString);

    List<WordModel> wordList = [];
    for (var field in fields) {
      wordList.add(WordModel(
        word: field[1],
        example: field[2],
        meaning: field[3],
      ));
    }
    return wordList;
  }
}
