import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocab_box/models/card.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LearningScreenState();
}

class LearningScreenArguments {
  List<CardModel> cardList = [];
  final int maxCorrectTimes;

  LearningScreenArguments({
    required this.cardList,
    this.maxCorrectTimes = 3,
  });
}

class _LearningScreenState extends State<LearningScreen> {
  int cardIndex = 0;
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
  }

  void _updateCardIndex({required List cardList, int maxCorrectTimes = 3}) {
    setState(() {
      int newCardIndex = Random().nextInt(cardList.length);
      if (newCardIndex == cardIndex ||
          cardList[newCardIndex].correctTimes >= maxCorrectTimes) {
        newCardIndex = cardList
            .indexWhere((element) => element.correctTimes < maxCorrectTimes);
      }
      cardIndex = newCardIndex;
      isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as LearningScreenArguments;
    final card = args.cardList.elementAtOrNull(cardIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text("Learning"),
      ),
      body: card == null
          ? Center(
              child: Text("Finished"),
            )
          : InkWell(
              child: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Text(
                        card.word,
                        style: TextStyle(
                          fontSize: 32,
                          color: card.color,
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: Text(card.example)),
                    Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: Visibility(
                          child: Text(card.meaning),
                          maintainAnimation: true,
                          maintainSize: true,
                          maintainState: true,
                          visible: isVisible,
                        ))
                  ],
                ),
              ),
              onTap: () => setState(() => isVisible = !isVisible),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              enableFeedback: false,
            ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        MaterialButton(
          child: Column(children: [Icon(Icons.close), Text("Don't Know")]),
          onPressed: () {
            card?.correctTimes = 0;
            _updateCardIndex(
              cardList: args.cardList,
              maxCorrectTimes: args.maxCorrectTimes,
            );
          },
        ),
        MaterialButton(
          child: Column(children: [Icon(Icons.done), Text("Know")]),
          onPressed: () {
            card?.correctTimes += 1;
            _updateCardIndex(
              cardList: args.cardList,
              maxCorrectTimes: args.maxCorrectTimes,
            );
          },
        ),
        MaterialButton(
          child: Column(children: [Icon(Icons.skip_next), Text("Next")]),
          onPressed: () {
            _updateCardIndex(
              cardList: args.cardList,
              maxCorrectTimes: args.maxCorrectTimes,
            );
          },
        ),
      ],
    );
  }
}
