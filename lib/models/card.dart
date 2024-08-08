class CardModel {
  int id;
  final String frontTitle;
  final String frontSubtitle;
  final String backTitle;
  int correctTimes = 0;
  bool isLearning = false;

  static String get fields {
    return '''
      id INTEGER PRIMARY KEY,
      frontTitle TEXT,
      frontSubtitle TEXT,
      backTitle TEXT,
      correctTimes INTEGER,
      isLearning INTEGER
    ''';
  }

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
    return '$frontTitle | $frontSubtitle | $backTitle';
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
