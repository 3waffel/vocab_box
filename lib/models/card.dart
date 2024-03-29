import 'package:flutter/material.dart';

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
