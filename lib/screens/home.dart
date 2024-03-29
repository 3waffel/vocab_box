import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vocab_box/deck_loader.dart';

import 'package:vocab_box/screens/browser.dart';
import 'package:vocab_box/screens/learning.dart';
import 'package:vocab_box/screens/settings.dart';
import 'package:vocab_box/models/card.dart';
import 'package:vocab_box/card_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LearningScreenArguments learningScreenArguments =
      LearningScreenArguments(learningList: []);

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _syncRecords().then((value) => _loadLearningArguments());
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
    final records = await database.query('cards');
    if (records.length == 0) {
      // TODO switch between different decks
      final newCardList = await DeckLoader().loadDefaultDeck();
      for (final card in newCardList) {
        database.insert(
          'cards',
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
  }

  /// Draw 20 cards from deck
  void _loadLearningArguments() async {
    final cardList = await DeckLoader().cardList;
    setState(() {
      learningScreenArguments = LearningScreenArguments(
        learningList: cardList.where((item) => item.correctTimes < 3).take(20),
      );
    });
  }

  /// Update `learningList` and database when exiting `LearningScreen`
  Future<void> _getResultFromLearningScreen(BuildContext context) async {
    final LearningScreenArguments result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LearningScreen(),
        settings: RouteSettings(arguments: learningScreenArguments),
      ),
    );
    final database = await CardDatabase().database;
    for (final card in result.learningList) {
      await database.update(
        'cards',
        card.toMap(),
        where: 'id = ?',
        whereArgs: [card.id],
      );
    }
    // sync deck_loader with updated database
    await _syncRecords();
    setState(() {
      learningScreenArguments = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Home"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 32),
              child: ElevatedButton.icon(
                icon: Icon(Icons.sync),
                label: Text("Sync Records with Default Deck"),
                onPressed: _syncRecords,
                style: ButtonStyle(),
              ),
            ),
            Text("Deck Count: ${DeckLoader().cardList.length}"),
            Padding(
              padding: EdgeInsets.only(top: 32),
              child: ElevatedButton.icon(
                icon: Icon(Icons.book),
                label: Text("Start Current Learning Group"),
                onPressed: () => _getResultFromLearningScreen(context),
              ),
            ),
            Text("Remaining: ${learningScreenArguments.learningList.length}"),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Menu", style: TextStyle(fontSize: 24)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text("Settings"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Browser"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BrowserScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
