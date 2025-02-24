import 'dart:convert';

import 'package:vocab_box/data/models/base_model.dart';

class CardModel extends BaseModel {
  double learningProgress = 0;

  @override
  String toString() {
    return data.entries
        .fold("", (prev, curr) => prev + curr.key + " | " + curr.value + "\n");
  }

  CardModel({
    required super.id,
    required super.data,
    this.learningProgress = 0,
  });

  @override
  Map<String, dynamic> toMap() {
    data.update(
      'learningProgress',
      (_) => learningProgress,
      ifAbsent: () => learningProgress,
    );
    return {'id': id, 'data': jsonEncode(data)};
  }

  @override
  factory CardModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> data = {};
    if (map.containsKey('data')) {
      data = jsonDecode(map['data']);
    }
    double learningProgress = 0;
    if (data.containsKey('learningProgress')) {
      learningProgress =
          double.tryParse(data['learningProgress'].toString()) ?? 0;
    }

    return CardModel(
      id: map["id"],
      data: data,
      learningProgress: learningProgress,
    );
  }

  static List<CardModel> fromMapList(List<Map<String, Object?>> maps) {
    return [for (final map in maps) CardModel.fromMap(map)];
  }
}
