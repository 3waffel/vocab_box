import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:vocab_box/card_database.dart';
import 'package:vocab_box/models/card.dart';
import 'package:vocab_box/common/snackbar.dart';
import 'package:collection/collection.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LearningScreenState();
}

class LearningScreenArguments {
  final String deckName;
  final int learningLimit;
  final int learningGroupCount;
  final bool isRandom;

  LearningScreenArguments({
    this.deckName = CardDatabase.table,
    this.learningLimit = 3,
    this.learningGroupCount = 20,
    this.isRandom = true,
  });
}

enum _Choice {
  Forget,
  Know,
  Skip,
}

class _LearningScreenState extends State<LearningScreen> {
  Queue<CardModel> learningQueue = Queue();
  LearningScreenArguments args = LearningScreenArguments();
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    _loadLearning();
  }

  Future<void> _loadLearning() async {
    final maps = await CardDatabase().getLearningFromTable(args.deckName);
    final learningGroup = CardModel.fromMapList(maps);
    if (args.isRandom) learningGroup.shuffle();
    setState(() => learningQueue = Queue.from(learningGroup));
  }

  /// Move the first card to the end of the queue and reset visibility
  void _updateCard(_Choice choice) {
    if (learningQueue.length != 0) {
      final first = learningQueue.removeFirst();
      switch (choice) {
        case _Choice.Forget:
          first.correctTimes = 0;
        case _Choice.Know:
          first.correctTimes += 1;
        case _Choice.Skip:
      }
      learningQueue.addLast(first);
    }
    setState(() => isVisible = false);
  }

  Future<void> _startNewGroup() async {
    final maps = await CardDatabase().getTable(args.deckName);
    final cardList = CardModel.fromMapList(maps);
    final available =
        cardList.where((item) => item.correctTimes <= args.learningLimit);

    final learningGroup = args.isRandom
        ? available.sample(args.learningGroupCount)
        : available.take(args.learningGroupCount);
    learningGroup.forEach((item) => item.isLearning = true);

    setState(() => learningQueue = Queue.from(learningGroup));
  }

  /// update deck when exiting learning screen
  Future<void> _updateDeck() async {
    await CardDatabase().updateMany(
      cardList: learningQueue,
      table: args.deckName,
    );
    SnackBarExt(context).fluidSnackBar("Deck Updated");
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
      appBar: AppBar(
        title: Text("Learning"),
        leading: BackButton(onPressed: () async {
          await _updateDeck();
          Navigator.pop(context);
        }),
      ),
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
                ),
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
                        card.frontTitle,
                        style: TextStyle(fontSize: 32, color: card.color),
                      )),
                  Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Text(card.frontSubtitle)),
                  Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Visibility(
                        child: Text(card.backTitle),
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
                onPressed: () => _updateCard(_Choice.Forget),
                icon: Icon(Icons.close),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: IconButton.filledTonal(
                onPressed: () => _updateCard(_Choice.Know),
                icon: Icon(Icons.done),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: IconButton.filledTonal(
                onPressed: () => _updateCard(_Choice.Skip),
                icon: Icon(Icons.skip_next),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
