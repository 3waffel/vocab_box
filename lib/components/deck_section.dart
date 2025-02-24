import 'package:flutter/material.dart';
import 'package:vocab_box/common/deck_metadata.dart';
import 'package:vocab_box/common/learning_arguments.dart';
import 'package:vocab_box/screens/learning_screen.dart';

class DeckSection extends StatelessWidget {
  final DeckMetadata _deckMetadata;

  DeckSection(this._deckMetadata);

  @override
  Widget build(BuildContext context) {
    final deckName = _deckMetadata.deckName;
    final deckCount = _deckMetadata.deckCount;
    final completeCount = _deckMetadata.completeCount;
    final learningCount = _deckMetadata.learningCount;

    final deckInfoRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${deckName}",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.inbox),
          label: Text("Start"),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LearningScreen(),
              settings: RouteSettings(
                arguments: LearningArguments(
                  deckMetadata: _deckMetadata,
                ),
              ),
            ),
          ),
        ),
      ],
    );
    final progressBarRow = LinearProgressIndicator(
      value: (completeCount / deckCount),
      minHeight: 6,
    );
    final learningInfoRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Learning ${learningCount.toString()}",
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Text(
          "${deckCount.toString()} in total",
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: Card.outlined(
        margin: EdgeInsets.all(16),
        clipBehavior: Clip.hardEdge,
        child: Container(
          padding: EdgeInsets.all(16),
          constraints: BoxConstraints(minWidth: 400, maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: deckInfoRow,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: progressBarRow,
              ),
              learningInfoRow
            ],
          ),
        ),
      ),
    );
  }
}
