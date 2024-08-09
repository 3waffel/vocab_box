enum CardField {
  id(sqlType: "INTEGER PRIMARY KEY"),
  frontTitle(sqlType: "TEXT"),
  frontSubtitle(sqlType: "TEXT"),
  backTitle(sqlType: "TEXT"),
  correctTimes(sqlType: "INTEGER"),
  isLearning(sqlType: "INTEGER");

  final String sqlType;

  static String get fields =>
      CardField.values.map((e) => "${e.name} ${e.sqlType}").join(", ");

  const CardField({
    required this.sqlType,
  });
}

class CardModel {
  final int id;
  final String frontTitle;
  final String frontSubtitle;
  final String backTitle;
  int correctTimes = 0;
  bool isLearning = false;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'frontTitle': frontTitle,
      'frontSubtitle': frontSubtitle,
      'backTitle': backTitle,
      'correctTimes': correctTimes,
      'isLearning': isLearning ? 1 : 0,
    };
  }

  CardModel({
    required this.id,
    required this.frontTitle,
    required this.frontSubtitle,
    required this.backTitle,
    this.correctTimes = 0,
    this.isLearning = false,
  });

  @override
  String toString() {
    return '$id | $frontTitle | $frontSubtitle | $backTitle';
  }

  static List<CardModel> fromMapList(List<Map<String, Object?>> maps) {
    return [
      for (final {
            'id': id as int,
            'frontTitle': frontTitle as String,
            'frontSubtitle': frontSubtitle as String,
            'backTitle': backTitle as String,
            'correctTimes': correctTimes as int,
            'isLearning': isLearning as int,
          } in maps)
        CardModel(
          id: id,
          frontTitle: frontTitle,
          frontSubtitle: frontSubtitle,
          backTitle: backTitle,
          correctTimes: correctTimes,
          isLearning: isLearning.isOdd,
        )
    ];
  }
}
