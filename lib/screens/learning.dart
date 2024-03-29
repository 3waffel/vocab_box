import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocab_box/deck_loader.dart';
import 'package:vocab_box/models/card.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LearningScreenState();
}

class LearningScreenArguments {
  final int learningLimit;
  final int learningGroupCount;

  LearningScreenArguments({
    this.learningLimit = 3,
    this.learningGroupCount = 20,
  });
}

class _LearningScreenState extends State<LearningScreen> {
  Queue<CardModel> learningQueue = Queue.from(DeckLoader().learningGroup);
  LearningScreenArguments args = LearningScreenArguments();
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
  }

  /// Move the first card to the end of the list and reset visibility
  void _updateCard() {
    if (learningQueue.length != 0) {
      final first = learningQueue.removeFirst();
      if (first.correctTimes <= args.learningLimit) {
        learningQueue.addLast(first);
      }
      DeckLoader().learningGroup = learningQueue;
    }
    setState(() => isVisible = false);
  }

  void _startNewGroup() {
    DeckLoader().learningGroup = DeckLoader()
        .cardList
        .where((item) => item.correctTimes <= args.learningLimit)
        .take(args.learningGroupCount);
    setState(() => learningQueue = Queue.from(DeckLoader().learningGroup));
  }

  @override
  Widget build(BuildContext context) {
    final ctxArgs = ModalRoute.of(context)!.settings.arguments;
    if (ctxArgs != null && ctxArgs is LearningScreenArguments) {
      args = ctxArgs;
    }
    final card = learningQueue.firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text("Learning")),
      body: switch (card) {
        null => Center(
            child: Column(
              children: [
                Text("Finished", style: TextStyle(fontSize: 32)),
                ElevatedButton.icon(
                  icon: Icon(Icons.abc),
                  label: Text("Start a new group"),
                  onPressed: _startNewGroup,
                )
              ],
            ),
          ),
        CardModel card => InkWell(
            child: Center(
              child: Column(
                children: [
                  Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(
                          value: card.correctTimes / args.learningLimit,
                        ),
                      )),
                  Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Text(
                        card.word,
                        style: TextStyle(fontSize: 32, color: card.color),
                      )),
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
      },
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        MaterialButton(
          child: Column(children: [Icon(Icons.close), Text("Don't Know")]),
          onPressed: () {
            card?.correctTimes = 0;
            _updateCard();
          },
        ),
        MaterialButton(
          child: Column(children: [Icon(Icons.done), Text("Know")]),
          onPressed: () {
            card?.correctTimes += 1;
            _updateCard();
          },
        ),
        MaterialButton(
          child: Column(children: [Icon(Icons.skip_next), Text("Next")]),
          onPressed: () {
            _updateCard();
          },
        ),
      ],
    );
  }
}
