import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class BaseModel {
  final int id;
  final Map<String, dynamic> data;

  BaseModel({required this.id, required this.data});

  factory BaseModel.fromMap(Map<String, dynamic> map) {
    return BaseModel(
      id: map["id"],
      data: map["data"] == null ? {} : jsonDecode(map['data']),
    );
  }

  Map<String, dynamic> toMap() => {'id': id, 'data': jsonEncode(data)};
}
