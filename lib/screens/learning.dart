import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocab_box/models/card.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LearningScreenState();
}

class LearningScreenArguments {
  Queue<CardModel> learningList;
  final int maxCorrectTimes;

  LearningScreenArguments({
    Iterable<CardModel>? learningList,
    this.maxCorrectTimes = 3,
  }) : learningList = Queue.from(learningList ?? const <CardModel>[]);
}

class _LearningScreenState extends State<LearningScreen> {
  bool isVisible = false;
  CardModel? card = null;

  @override
  void initState() {
    super.initState();
  }

  /// Move the first card to the end of the list and reset visibility
  void _updateCard(LearningScreenArguments args) {
    if (args.learningList.length == 0) {
      return;
    }
    final first = args.learningList.removeFirst();
    if (first.correctTimes <= args.maxCorrectTimes) {
      args.learningList.addLast(first);
    }
    setState(() {
      isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as LearningScreenArguments;
    card = args.learningList.firstOrNull;

    return Scaffold(
      appBar: AppBar(
          title: Text("Learning"),
          leading: BackButton(onPressed: () => Navigator.pop(context, args))),
      body: switch (card) {
        null => Center(child: Text("Finished", style: TextStyle(fontSize: 32))),
        CardModel card => InkWell(
            child: Center(
              child: Column(
                children: [
                  Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(
                          value: card.correctTimes / args.maxCorrectTimes,
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
            _updateCard(args);
          },
        ),
        MaterialButton(
          child: Column(children: [Icon(Icons.done), Text("Know")]),
          onPressed: () {
            card?.correctTimes += 1;
            _updateCard(args);
          },
        ),
        MaterialButton(
          child: Column(children: [Icon(Icons.skip_next), Text("Next")]),
          onPressed: () {
            _updateCard(args);
          },
        ),
      ],
    );
  }
}
