import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:vocab_box/deck_loader.dart';
import 'package:vocab_box/models/card.dart';
import 'package:collection/collection.dart';

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
      learningQueue.addLast(first);
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
    final card = learningQueue
        .firstWhereOrNull((item) => item.correctTimes <= args.learningLimit);

    return Scaffold(
      appBar: AppBar(title: Text("Learning")),
      body: switch (card) {
        null => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Finished",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text("Start a new group"),
                    onPressed: _startNewGroup,
                  ),
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
                        width: min(100, args.learningLimit * 20),
                        child: StepProgressIndicator(
                          currentStep: card.correctTimes,
                          totalSteps: args.learningLimit,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          unselectedColor:
                              Theme.of(context).colorScheme.inversePrimary,
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
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: IconButton.filledTonal(
                onPressed: () {
                  card?.correctTimes = 0;
                  _updateCard();
                },
                icon: Icon(Icons.close),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: IconButton.filledTonal(
                onPressed: () {
                  card?.correctTimes += 1;
                  _updateCard();
                },
                icon: Icon(Icons.done),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: IconButton.filledTonal(
                onPressed: () {
                  _updateCard();
                },
                icon: Icon(Icons.skip_next),
              ),
            ),
          ],
        ),
      ),
      // persistentFooterAlignment: AlignmentDirectional.center,
      // persistentFooterButtons:
    );
  }
}
