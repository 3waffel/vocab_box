import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vocab_box/common/snackbar.dart';
import 'package:vocab_box/deck_loader.dart';

import 'package:vocab_box/screens/learning.dart';
import 'package:vocab_box/models/card.dart';
import 'package:vocab_box/card_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.getBool('testKey') ?? false;
    });
  }

  /// Sync deck_loader with database
  /// TODO switch between different decks
  Future<void> _syncRecords() async {
    final database = await CardDatabase().database;
    final records = await database.query(CardDatabase.table);

    if (records.length == 0) {
      final newCardList = await DeckLoader().loadDefaultDeck();
      for (final card in newCardList) {
        database.insert(
          CardDatabase.table,
          card.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } else {
      final newCardList = [
        for (final {
              'id': id as int,
              'word': word as String,
              'example': example as String,
              'meaning': meaning as String,
              'correctTimes': correctTimes as int,
            } in records)
          CardModel(
            id: id,
            word: word,
            example: example,
            meaning: meaning,
            correctTimes: correctTimes,
          ),
      ];
      DeckLoader().cardList = newCardList;
    }
    setState(() {});
    SnackBarExt(context).fluidSnackBar("Sync Done");
  }

  /// Update database when exiting `LearningScreen`
  Future<void> _getResultFromLearningScreen(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LearningScreen(),
        settings: RouteSettings(),
      ),
    );
    final database = await CardDatabase().database;
    for (final card in DeckLoader().learningGroup) {
      await database.update(
        CardDatabase.table,
        card.toMap(),
        where: 'id = ?',
        whereArgs: [card.id],
      );
    }
    if (mounted) setState(() {});
    SnackBarExt(context).fluidSnackBar("Deck Updated");
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
    final remainingCount =
        DeckLoader().cardList.where((item) => item.correctTimes > 3).length;
    final deckCount = DeckLoader().cardList.length;
    final learningCount = DeckLoader().learningGroup.length;

    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: ListView(
        children: <Widget>[
          DeckLoader().cardList.length == 0
              ? _buildDeckSection(
                  child: Text(
                  "No Selected Deck",
                  style: Theme.of(context).textTheme.titleMedium,
                ))
              : _buildDeckSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  "${CardDatabase.table} - ${deckCount.toString()} in total",
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              Text(
                                "",
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              ElevatedButton.icon(
                                icon: Icon(Icons.sync),
                                label: Text("Sync"),
                                onPressed: _syncRecords,
                              ),
                            ]),
                      ),
                      LinearProgressIndicator(
                        value: (remainingCount / deckCount),
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
                              onPressed: () async =>
                                  await _getResultFromLearningScreen(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ListTile(
            title: Icon(Icons.add),
            onTap: _syncRecords,
          ),
        ],
      ),
    );
  }
}
