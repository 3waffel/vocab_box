import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
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
  Future<void> _syncRecords() async {
    final database = await CardDatabase().database;
    final records = await database.query(CardDatabase.table);
    if (records.length == 0) {
      // TODO switch between different decks
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text("Sync Done", style: Theme.of(context).textTheme.labelMedium),
      showCloseIcon: true,
      closeIconColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    ));
    setState(() {});
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text("Deck Updated", style: Theme.of(context).textTheme.labelMedium),
      showCloseIcon: true,
      closeIconColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    ));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.sync),
                label: Text(
                    "Sync Default Deck - ${DeckLoader().cardList.length} in total"),
                onPressed: _syncRecords,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: ElevatedButton.icon(
                icon: Icon(Icons.inbox),
                label: Text("Start Current Group"),
                onPressed: () async =>
                    await _getResultFromLearningScreen(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
