import 'package:vocab_box/common/deck_metadata.dart';

class LearningArguments {
  final DeckMetadata deckMetadata;
  final int learningLimit;
  final int learningGroupCount;
  final bool isRandom;

  LearningArguments({
    required this.deckMetadata,
    this.learningLimit = 3,
    this.learningGroupCount = 20,
    this.isRandom = true,
  });
}
