import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

import 'package:vocab_box/browser_route.dart';
import 'package:vocab_box/settings_route.dart';
import 'package:vocab_box/word_loader.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Database? database = null;
  List<WordModel>? wordsList = null;
  int wordIndex = 0;
  final int maxCorrectTimes = 3;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  void _updateWordIndex() {
    setState(() {
      final newWordIndex = Random().nextInt(wordsList!.length);
      if (newWordIndex == wordIndex ||
          wordsList![newWordIndex].correctTimes >= maxCorrectTimes) {
        wordIndex = wordsList!
            .indexWhere((element) => element.correctTimes < maxCorrectTimes);
      }
      wordIndex = newWordIndex.clamp(0, wordsList!.length - 1);
    });
  }

  Future<void> _loadStore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.getBool('testKey') ?? false;
    });

    database = await initDatabase();
    final wordsMap = await database!.query('words');
    wordsList = [
      for (final {
            'word': word as String,
            'example': example as String,
            'meaning': meaning as String,
          } in wordsMap)
        WordModel(word: word, example: example, meaning: meaning),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final word = wordsList?[wordIndex];
    late final Color color;
    switch (word?.word.split(' ')[0]) {
      case 'der':
        color = Color.fromARGB(211, 86, 244, 255);
      case 'das':
        color = Color.fromARGB(200, 108, 255, 75);
      case 'die':
        color = Color.fromARGB(255, 255, 86, 117);
      default:
        color = Theme.of(context).primaryColorLight;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Vocab Box"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 32),
              child: Text(
                word?.word ?? "",
                style: TextStyle(
                  fontSize: 32,
                  color: color,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(32),
              child: Text(word?.example ?? ""),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    child: Column(
                        children: [Icon(Icons.close), Text("Don't Know")]),
                    onPressed: () {
                      wordsList?[wordIndex].correctTimes = 0;
                      _updateWordIndex();
                    },
                  ),
                  MaterialButton(
                    child: Column(children: [Icon(Icons.done), Text("Know")]),
                    onPressed: () {
                      wordsList?[wordIndex].correctTimes += 1;
                      _updateWordIndex();
                    },
                  ),
                  MaterialButton(
                    child:
                        Column(children: [Icon(Icons.skip_next), Text("Next")]),
                    onPressed: () {
                      _updateWordIndex();
                    },
                  ),
                ],
              ),
            )
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            )),
            ListTile(
              title: const Text("Settings"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsRoute(),
                    settings: RouteSettings(),
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
                    builder: (context) => const BrowserScreen(),
                    settings: RouteSettings(
                      arguments: wordsList,
                    ),
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

Future<Database> initDatabase() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final database = openDatabase(
    join(await getDatabasesPath(), 'words.db'),
    onCreate: (db, version) async {
      db.execute(
        'CREATE TABLE words(word TEXT, example TEXT, meaning TEXT, correctTimes INTEGER)',
      );

      final wordList = await WordLoader.loadDefaultDeck();
      for (var word in wordList) {
        db.insert(
          'words',
          word.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    },
    version: 1,
  );
  return database;
}
