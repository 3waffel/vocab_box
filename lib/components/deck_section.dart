import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

    final topRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${deckName}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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
    final bottomRowTextStyle = GoogleFonts.notoSansMono(
      fontSize: 12,
    );
    final bottomRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${learningCount.toString()} in progress",
          style: bottomRowTextStyle,
        ),
        Text(
          "${deckCount.toString()} in total",
          style: bottomRowTextStyle,
        ),
      ],
    );

    return Align(
      alignment: Alignment.center,
      child: Container(
        color: ColorScheme.of(context).surfaceContainer,
        padding: EdgeInsets.all(16),
        constraints: BoxConstraints(minWidth: 400, maxWidth: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: topRow,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: progressBarRow,
            ),
            bottomRow
          ],
        ),
      ),
    );
  }
}
