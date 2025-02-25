import 'dart:convert';

import 'package:vocab_box/data/models/base_model.dart';

class CardModel extends BaseModel {
  double learningProgress;
  DateTime updatedAt;

  @override
  String toString() {
    return data.entries
        .fold<Map<String, int>>({}, (prev, curr) {
          prev[curr.key] = curr.key.length > curr.value.toString().length
              ? curr.key.length
              : curr.value.toString().length;
          return prev;
        })
        .entries
        .fold<List<String>>(["", ""], (prev, curr) {
          final key = curr.key.padRight(curr.value);
          final value = data[curr.key].toString().padRight(curr.value);
          prev[0] += key + " | ";
          prev[1] += value + " | ";
          return prev;
        })
        .map((line) => line.substring(0, line.length - 3) + "\n")
        .join();
  }

  CardModel({
    required super.id,
    required super.data,
    required this.learningProgress,
    required this.updatedAt,
  });

  @override
  Map<String, dynamic> toMap() {
    data.update(
      'learningProgress',
      (_) => learningProgress,
      ifAbsent: () => learningProgress,
    );
    data.update(
      'updatedAt',
      (_) => updatedAt.toString(),
      ifAbsent: () => updatedAt.toString(),
    );
    return {'id': id, 'data': jsonEncode(data)};
  }

  @override
  factory CardModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> data = {};
    if (map.containsKey('data')) {
      data = jsonDecode(map['data']);
    }

    double? learningProgress = data.containsKey('learningProgress')
        ? double.tryParse(data['learningProgress'].toString())
        : 0;
    learningProgress ??= 0;

    DateTime? updatedAt = data.containsKey('updatedAt')
        ? DateTime.tryParse(data['updatedAt'].toString())
        : DateTime.now();
    updatedAt ??= DateTime.now();

    return CardModel(
      id: map["id"],
      data: data,
      learningProgress: learningProgress,
      updatedAt: updatedAt,
    );
  }

  static List<CardModel> fromMapList(List<Map<String, Object?>> maps) {
    return [for (final map in maps) CardModel.fromMap(map)];
  }
}
