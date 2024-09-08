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

  @override
  void dispose() {
    learningSublist.clear();
    super.dispose();
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
          first.fields[CardField.correctTimes] = 0;
          newIndex = min(5, end);
        case _Choice.Know:
          first.fields.update(
            CardField.correctTimes,
            (value) => (value as int) + 1,
          );
          if (first.fields[CardField.correctTimes] as int >
              args.learningLimit) {
            first.fields[CardField.isLearning] = 0;
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
    final available = cardList.where((item) =>
        item.fields[CardField.correctTimes] as int <= args.learningLimit);

    final learningGroup = args.isRandom
        ? available.sample(args.learningGroupCount)
        : available.take(args.learningGroupCount);
    learningGroup.forEach((item) => item.fields[CardField.isLearning] = 1);

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
    switch (card.fields[CardField.frontTitle].toString().split(' ')[0]) {
      case 'der':
        cardColor = Colors.blueAccent;
      case 'das':
        cardColor = Colors.greenAccent;
      case 'die':
        cardColor = Colors.redAccent;
    }

    return InkWell(
      onTap: () => setState(() => isVisible = !isVisible),
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 32),
              child: SizedBox(
                width: min(100, args.learningLimit * 20),
                child: StepProgressIndicator(
                  currentStep: card.fields[CardField.correctTimes] as int,
                  totalSteps: args.learningLimit,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  unselectedColor: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 32),
              child: Text(
                card.fields[CardField.frontTitle] as String,
                style: TextStyle(fontSize: 32, color: cardColor),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Text(
                card.fields[CardField.frontSubtitle] as String,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Visibility(
                child: Text(
                  card.fields[CardField.backTitle] as String,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                maintainAnimation: true,
                maintainSize: true,
                maintainState: true,
                visible: isVisible,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = learningSublist.firstOrNull;

    return PopScope(
        onPopInvokedWithResult: (flag, value) => _updateDeck(),
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
