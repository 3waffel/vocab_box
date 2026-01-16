import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pretty_diff_text/pretty_diff_text.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:vocab_box/common/learning_arguments.dart';
import 'package:vocab_box/data/database/card_repository.dart';
import 'package:vocab_box/data/models/card_model.dart';

class LearningScreen extends StatefulWidget {
  static const String id = "/learning";
  const LearningScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LearningScreenState();
}

enum _Choice {
  Forget,
  Know,
  Skip,
}

class _LearningScreenState extends State<LearningScreen> {
  static List<CardModel> learningList = [];
  List<CardModel> learningSublist = List.from(learningList);
  late LearningArguments args;
  bool isVisible = false;
  final TextEditingController _inputController = TextEditingController();

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
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ctxArgs = ModalRoute.of(context)!.settings.arguments;
    if (ctxArgs != null && ctxArgs is LearningArguments) {
      args = ctxArgs;
    }
    if (learningSublist.isEmpty) {
      _initializeLearning();
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    learningSublist.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _buildFinished() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Finished",
            style: TextTheme.of(context).headlineLarge,
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
    final frontFields = args.deckMetadata.frontFields;
    final backFields = args.deckMetadata.backFields;

    List<Widget> layout = [
      Padding(
        padding: EdgeInsets.only(top: 32),
        child: SizedBox(
          width: min(100, args.learningLimit * 20),
          child: StepProgressIndicator(
            currentStep: card.learningProgress.toInt(),
            totalSteps: args.learningLimit,
            selectedColor: ColorScheme.of(context).primary,
            unselectedColor: ColorScheme.of(context).inversePrimary,
          ),
        ),
      )
    ];

    layout.addAll(frontFields.mapIndexed(
      (idx, elem) {
        var padding = switch (idx) {
          0 => EdgeInsets.only(top: 32, left: 16, right: 16),
          _ => EdgeInsets.only(top: 16, left: 16, right: 16),
        };

        var widget = switch (idx) {
          0 => Text(
              card.data[elem] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                color: ColorScheme.of(context).primary,
              ),
            ),
          _ => Text(
              card.data[elem] as String,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16,
                color: ColorScheme.of(context).secondary,
              ),
            )
        };

        return Padding(padding: padding, child: widget);
      },
    ));

    layout.add(Spacer(flex: 2));

    if (backFields.isNotEmpty) {
      // Display an input box for the first field.
      layout.add(Padding(
        padding: EdgeInsets.all(16),
        child: isVisible && backFields.isNotEmpty
            ? PrettyDiffText(
                oldText: _inputController.text,
                newText: card.data[backFields.first] as String,
                defaultTextStyle: TextStyle(
                  fontSize: 16,
                  color: ColorScheme.of(context).primary,
                ),
                addedTextStyle: TextStyle(
                  color: ColorScheme.of(context).primary,
                  backgroundColor: ColorScheme.of(context).primaryContainer,
                ),
                deletedTextStyle: TextStyle(
                  color: ColorScheme.of(context).error,
                  backgroundColor: ColorScheme.of(context).errorContainer,
                ),
              )
            : IntrinsicWidth(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 250),
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    onSubmitted: (_) => setState(() => isVisible = true),
                  ),
                ),
              ),
      ));

      // Display remaining fields.
      layout.add(AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isVisible ? null : 0,
          child: Visibility(
            visible: isVisible,
            maintainAnimation: true,
            maintainSize: false,
            maintainState: true,
            child: Column(children: [
              ...backFields.skip(1).mapIndexed(
                (idx, elem) {
                  var padding = EdgeInsets.only(top: 32, left: 16, right: 16);
                  var style = TextStyle(
                    fontSize: 14,
                    color: ColorScheme.of(context).tertiary,
                  );
                  return Padding(
                    padding: padding,
                    child: Text(
                      card.data[elem] as String,
                      textAlign: TextAlign.center,
                      style: style,
                    ),
                  );
                },
              ),
            ]),
          )));

      layout.add(Spacer(flex: 1));
    }

    return InkWell(
      onTap: () => setState(() => isVisible = false),
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Center(
        child: Column(
          children: layout,
        ),
      ),
    );
  }

  Future<void> _initializeLearning() async {
    final maps = await cardRepository.getTable(args.deckMetadata.deckName);
    final cardList = CardModel.fromMapList(maps);
    final available = cardList.where((item) =>
        item.learningProgress > 0 &&
        item.learningProgress < args.learningLimit);

    final learningGroup = args.isRandom
        ? available.sample(args.learningGroupCount)
        : available.take(args.learningGroupCount);

    learningList = List.from(learningGroup);
    if (args.isRandom) {
      learningList.shuffle();
    }
    setState(() => learningSublist = List.from(learningList));
  }

  Future<void> _startNewGroup() async {
    if (learningList.isNotEmpty) {
      await _updateDeck();
    }
    final maps = await cardRepository.getTable(args.deckMetadata.deckName);
    final cardList = CardModel.fromMapList(maps);
    final available =
        cardList.where((item) => item.learningProgress <= args.learningLimit);

    final learningGroup = args.isRandom
        ? available.sample(args.learningGroupCount)
        : available.take(args.learningGroupCount);
    learningGroup.forEach((item) => item.learningProgress += 0.1);

    learningList = List.from(learningGroup);
    if (args.isRandom) {
      learningList.shuffle();
    }
    setState(() => learningSublist = List.from(learningList));
  }

  /// update deck when exiting learning screen
  Future<void> _updateDeck() async {
    await cardRepository.updateMany(
      items: learningList,
      table: args.deckMetadata.deckName,
    );
    learningList = learningSublist;
  }

  /// Move the first card to the end of the queue and reset visibility
  void _updateLearning(_Choice choice) {
    _inputController.clear();
    final first = learningSublist.firstOrNull;
    if (first != null) {
      learningSublist.remove(first);
      final end = max(0, learningSublist.length - 1);
      final newIndex;
      switch (choice) {
        case _Choice.Forget:
          first.learningProgress = 0.1;
          newIndex = min(5, end);
        case _Choice.Know:
          first.learningProgress += 1;
          if (first.learningProgress > args.learningLimit) {
            // first.learningProgress = args.learningLimit;
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
}
