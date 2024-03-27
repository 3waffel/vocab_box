import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

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
  List<CardModel>? cardList = null;

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

  Future<void> _loadRecords() async {
    final database = await CardDatabase().database;
    final records = await database.query('cards');
    late List<CardModel> newCardList;
    if (records.length == 0) {
      newCardList = await DeckLoader.loadDefaultDeck();
      for (final card in newCardList) {
        database.insert(
          'cards',
          card.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } else {
      newCardList = [
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
    }
    setState(() {
      cardList = newCardList;
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
              child: TextButton(
                child: Text("Load Default Deck"),
                onPressed: _loadRecords,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 32),
              child: TextButton(
                child: Text(cardList != null
                    ? "Current Deck: ${cardList!.length}"
                    : "No Deck Selected"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LearningScreen(),
                      settings: RouteSettings(
                        arguments: LearningScreenArguments(
                          cardList: cardList ?? [],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
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
                    builder: (context) =>
                        BrowserScreen(cardList: cardList ?? []),
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
