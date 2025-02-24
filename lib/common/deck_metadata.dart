import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab_box/components/deck_fields_setting.dart';
import 'package:vocab_box/data/database/card_repository.dart';
import 'package:vocab_box/data/models/card_model.dart';

class DeckMetadata {
  final String deckName;
  final int deckCount;
  final int completeCount;
  final int learningCount;
  final List<String> frontFields;
  final List<String> backFields;

  DeckMetadata({
    required this.deckName,
    required this.deckCount,
    required this.completeCount,
    required this.learningCount,
    required this.frontFields,
    required this.backFields,
  });

  static Future<DeckMetadata> syncDeckMetadata(
    String deckName, [
    BuildContext? context,
  ]) async {
    final maps = await cardRepository.getTable(deckName);
    final cardList = CardModel.fromMapList(maps);
    final deckCount = cardList.length;
    final completeCount =
        cardList.where((item) => item.learningProgress > 3).length;
    final learningCount =
        cardList.where((item) => item.learningProgress > 0).length;
    final deckFields = await getDeckFields(deckName, context);
    return DeckMetadata(
      deckName: deckName,
      deckCount: deckCount,
      completeCount: completeCount,
      learningCount: learningCount,
      frontFields: deckFields.$1,
      backFields: deckFields.$2,
    );
  }

  static Future<(List<String>, List<String>)> getDeckFields(
    String deckName, [
    BuildContext? context,
  ]) async {
    final prefs = await SharedPreferences.getInstance();
    (List<String>, List<String>) fields = ([], []);
    if (prefs.containsKey('${deckName}_frontFields')) {
      var frontfields = prefs.get('${deckName}_frontFields') as List;
      fields.$1.addAll(List<String>.from(frontfields));
    }
    if (prefs.containsKey('${deckName}_backFields')) {
      var backFields = prefs.get('${deckName}_backFields') as List;
      fields.$2.addAll(List.from(backFields));
    }

    if ((fields.$1.isEmpty || fields.$2.isEmpty) && context != null) {
      bool setup = await showAdaptiveDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Invalid Layout: ${deckName}"),
          content: Text(
              "Invalid card layout detected, do you want to set up layout now?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Continue"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel"),
            ),
          ],
        ),
      );

      if (setup) {
        var result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DeckFieldsSetting(deckName: deckName),
          ),
        );
        if (result != null) {
          fields = result;
        }
      }
    }
    return fields;
  }
}
