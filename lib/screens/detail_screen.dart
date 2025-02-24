import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:vocab_box/common/deck_metadata.dart';
import 'package:vocab_box/data/models/card_model.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.card,
    required this.deckMetadata,
  });

  final CardModel card;
  final DeckMetadata deckMetadata;

  @override
  Widget build(BuildContext context) {
    var layout = deckMetadata.frontFields.mapIndexed(
      (idx, elem) {
        var style = switch (idx) {
          0 => Theme.of(context).textTheme.headlineSmall,
          _ => Theme.of(context).textTheme.bodyLarge,
        };

        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          title: Text(
            card.data[elem] as String,
            style: style,
          ),
        );
      },
    ).toList();

    layout.addAll(deckMetadata.backFields.mapIndexed(
      (idx, elem) {
        var style = switch (idx) {
          0 => Theme.of(context).textTheme.bodyMedium,
          _ => Theme.of(context).textTheme.labelMedium,
        };
        return ListTile(
          title: Text(
            card.data[elem] as String,
            style: style,
          ),
        );
      },
    ));

    layout.add(ListTile(
      title: Text(
        "Learning Progress: ${card.learningProgress}",
        style: Theme.of(context).textTheme.labelMedium,
      ),
    ));

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: layout,
      ),
    );
  }
}
