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
    var frontFieldLayout = deckMetadata.frontFields.mapIndexed(
      (idx, elem) {
        var style = switch (idx) {
          0 => TextTheme.of(context).headlineSmall,
          _ => TextTheme.of(context).bodyLarge,
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

    var backFieldLayout = deckMetadata.backFields.mapIndexed(
      (idx, elem) {
        var style = switch (idx) {
          0 => TextTheme.of(context).bodyMedium,
          _ => TextTheme.of(context).labelMedium,
        };
        return ListTile(
          title: Text(
            card.data[elem] as String,
            style: style,
          ),
        );
      },
    ).toList();

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: [
          Column(children: frontFieldLayout),
          Divider(),
          Column(children: backFieldLayout),
          Divider(),
        ],
      ),
      bottomSheet: ListTile(
        title: Text("Learning Progress: ${card.learningProgress}"),
        titleTextStyle: TextTheme.of(context).labelSmall,
        subtitle: Text("Last Updated: ${card.updatedAt}"),
        subtitleTextStyle: TextTheme.of(context).labelSmall,
      ),
    );
  }
}
