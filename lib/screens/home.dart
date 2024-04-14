import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vocab_box/common/snackbar.dart';
import 'package:vocab_box/screens/learning.dart';
import 'package:vocab_box/models/card.dart';
import 'package:vocab_box/card_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String id = "/home";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _DeckStatus {
  final String deckName;
  final int deckCount;
  final int completeCount;
  final int learningCount;

  _DeckStatus({
    required this.deckName,
    required this.deckCount,
    required this.completeCount,
    required this.learningCount,
  });
}

class _HomeScreenState extends State<HomeScreen> {
  static List<_DeckStatus> deckStatusList = [];

  @override
  void initState() {
    super.initState();
    if (deckStatusList.isEmpty) {
      _initDeckStatusList();
    }
  }

  /// Sync all tables
  Future<void> _initDeckStatusList() async {
    List<_DeckStatus> newDeckStatusList = [];
    final tables = await CardDatabase().getTableNameList();
    for (final deckName in tables) {
      final maps = await CardDatabase().getTable(deckName);
      final cardList = CardModel.fromMapList(maps);
      final deckCount = cardList.length;
      final completeCount =
          cardList.where((item) => item.correctTimes > 3).length;
      final learningCount = cardList.where((item) => item.isLearning).length;
      newDeckStatusList.add(_DeckStatus(
          deckName: deckName,
          deckCount: deckCount,
          completeCount: completeCount,
          learningCount: learningCount));
    }
    setState(() => deckStatusList = newDeckStatusList);
    SnackBarExt(context).fluidSnackBar("Sync Done");
  }

  /// Sync single deck
  Future<void> _syncStatus(int index) async {
    final deckName = deckStatusList[index].deckName;
    final maps = await CardDatabase().getTable(deckName);
    final cardList = CardModel.fromMapList(maps);
    final deckCount = cardList.length;
    final completeCount =
        cardList.where((item) => item.correctTimes > 3).length;
    final learningCount = cardList.where((item) => item.isLearning).length;
    setState(() {
      deckStatusList[index] = _DeckStatus(
          deckName: deckName,
          deckCount: deckCount,
          completeCount: completeCount,
          learningCount: learningCount);
    });
    SnackBarExt(context).fluidSnackBar("Sync Done: ${deckName}");
  }

  Widget _buildDeckSection({child}) {
    return Container(
      width: 400,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).hoverColor,
        border: Border.all(color: Theme.of(context).highlightColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      floatingActionButton: IconButton.filledTonal(
        icon: Icon(Icons.sync),
        onPressed: _initDeckStatusList,
      ),
      body: ListView.builder(
        itemCount: deckStatusList.length,
        itemBuilder: (context, index) {
          final deckName = deckStatusList[index].deckName;
          final deckCount = deckStatusList[index].deckCount;
          final completeCount = deckStatusList[index].completeCount;
          final learningCount = deckStatusList[index].learningCount;
          return _buildDeckSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${deckName}",
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          "${deckCount.toString()} in total",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.sync),
                          label: Text("Sync"),
                          onPressed: () => _syncStatus(index),
                        ),
                      ]),
                ),
                LinearProgressIndicator(
                  value: (completeCount / deckCount),
                  minHeight: 6,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "Learning ${learningCount.toString()}",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.inbox),
                        label: Text("Start"),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LearningScreen(),
                            settings: RouteSettings(
                              arguments:
                                  LearningScreenArguments(deckName: deckName),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
