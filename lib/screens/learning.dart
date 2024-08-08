import 'dart:math';

import 'package:flutter/material.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:vocab_box/common/database/card_database.dart';
import 'package:vocab_box/models/card.dart';
import 'package:collection/collection.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});
  static const String id = "/learning";

  @override
  State<StatefulWidget> createState() => _LearningScreenState();
}

class LearningScreenArguments {
  final String deckName;
  final int learningLimit;
  final int learningGroupCount;
  final bool isRandom;

  LearningScreenArguments({
    required this.deckName,
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
  static List<CardModel> learningList = [];
  List<CardModel> learningSublist = List.from(learningList);
  late LearningScreenArguments args;
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ctxArgs = ModalRoute.of(context)!.settings.arguments;
    if (ctxArgs != null && ctxArgs is LearningScreenArguments) {
      args = ctxArgs;
    }
    if (learningSublist.isEmpty) {
      _initializeLearning();
    }
  }

  Future<void> _initializeLearning() async {
    final maps = await cardDatabase.getLearningFromTable(args.deckName);
    final learningGroup = CardModel.fromMapList(maps);
    if (args.isRandom) learningGroup.shuffle();

    learningList = List.from(learningGroup);
    setState(() => learningSublist = List.from(learningList));
  }

  /// Move the first card to the end of the queue and reset visibility
  void _updateLearning(_Choice choice) {
    final first = learningSublist.firstOrNull;
    if (first != null) {
      learningSublist.remove(first);
      final end = max(0, learningSublist.length - 1);
      final newIndex;
      switch (choice) {
        case _Choice.Forget:
          first.correctTimes = 0;
          newIndex = min(5, end);
        case _Choice.Know:
          first.correctTimes += 1;
          if (first.correctTimes > args.learningLimit) {
            first.isLearning = false;
            return setState(() => isVisible = false);
          } else {
            newIndex = min(10, end);
          }
        case _Choice.Skip:
          newIndex = end;
      }
      learningSublist.insert(newIndex, first);
    }
    setState(() => isVisible = false);
  }

  Future<void> _startNewGroup() async {
    final maps = await cardDatabase.getTable(args.deckName);
    final cardList = CardModel.fromMapList(maps);
    final available =
        cardList.where((item) => item.correctTimes <= args.learningLimit);

    final learningGroup = args.isRandom
        ? available.sample(args.learningGroupCount)
        : available.take(args.learningGroupCount);
    learningGroup.forEach((item) => item.isLearning = true);

    learningList = List.from(learningGroup);
    setState(() => learningSublist = List.from(learningList));
  }

  /// update deck when exiting learning screen
  Future<void> _updateDeck() async {
    await cardDatabase.updateMany(
      cardList: learningList,
      table: args.deckName,
    );
    learningList = learningSublist;
  }

  Widget _buildFinished() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Finished",
            style: Theme.of(context).textTheme.headlineLarge,
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
    );
  }

  Widget _buildLearning(CardModel card) {
    Color cardColor = Colors.white70;
    switch (card.frontTitle.split(' ')[0]) {
      case 'der':
        cardColor = Colors.blueAccent;
      case 'das':
        cardColor = Colors.greenAccent;
      case 'die':
        cardColor = Colors.redAccent;
    }

    return InkWell(
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
                  style: TextStyle(fontSize: 32, color: cardColor),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = learningSublist.firstOrNull;

    return PopScope(
        onPopInvoked: (value) => _updateDeck(),
        child: Scaffold(
          appBar: AppBar(title: Text("Learning")),
          body: switch (card) {
            null => _buildFinished(),
            CardModel card => _buildLearning(card),
          },
          bottomNavigationBar: BottomAppBar(
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: 20,
              children: [
                IconButton.filledTonal(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  onPressed: () => _updateLearning(_Choice.Forget),
                  icon: Icon(Icons.close),
                ),
                IconButton.filledTonal(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  onPressed: () => _updateLearning(_Choice.Know),
                  icon: Icon(Icons.done),
                ),
                IconButton.filledTonal(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  onPressed: () => _updateLearning(_Choice.Skip),
                  icon: Icon(Icons.skip_next),
                ),
              ],
            ),
          ),
        ));
  }
}
