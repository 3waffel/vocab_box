enum CardField {
  id(sqlType: "INTEGER PRIMARY KEY"),
  frontTitle(sqlType: "TEXT"),
  frontSubtitle(sqlType: "TEXT"),
  backTitle(sqlType: "TEXT"),
  correctTimes(sqlType: "INTEGER"),
  isLearning(sqlType: "INTEGER");

  final String sqlType;

  const CardField({
    required this.sqlType,
  });

  static String get fields =>
      CardField.values.map((e) => "${e.name} ${e.sqlType}").join(", ");
}

class CardModel {
  Map<CardField, Object?> fields = {
    CardField.id: 0,
    CardField.frontTitle: "",
    CardField.frontSubtitle: "",
    CardField.backTitle: "",
    CardField.correctTimes: 0,
    CardField.isLearning: 0,
  };

  CardModel();

  @override
  String toString() {
    return fields.entries.fold(
        "",
        (prev, curr) =>
            prev + curr.key.name + ": " + curr.value.toString() + "\n");
  }

  Map<String, Object?> toMap() {
    return fields.map((key, value) => MapEntry(key.name, value));
  }

  CardModel.fromMap(Map<String, Object?> map)
      : fields = map.map((key, value) {
          var newKey =
              CardField.values.firstWhere((element) => element.name == key);
          if (newKey.sqlType.startsWith("INTEGER")) {
            int? parsed = int.tryParse(value.toString());
            if (parsed != null) {
              return MapEntry(newKey, parsed);
            } else {
              return MapEntry(newKey, 0);
            }
          }
          return MapEntry(newKey, value.toString());
        });

  static List<CardModel> fromMapList(List<Map<String, Object?>> maps) {
    return [for (final map in maps) CardModel.fromMap(map)];
  }
}
