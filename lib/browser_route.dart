import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vocab_box/word_loader.dart';

class BrowserScreen extends StatelessWidget {
  const BrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wordList =
        ModalRoute.of(context)!.settings.arguments as List<WordModel>;
    return Scaffold(
        appBar: AppBar(
          title: Text("Browser"),
        ),
        body: ListView.builder(
          itemCount: wordList.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(wordList[index].word),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(),
                settings: RouteSettings(arguments: wordList[index]),
              ),
            ),
          ),
        ));
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final word = ModalRoute.of(context)!.settings.arguments as WordModel;
    late final Color color;
    switch (word.word.split(' ')[0]) {
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
        title: Text(
          word.word,
          style: TextStyle(color: color),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(
              word.meaning,
              style: TextStyle(fontSize: 16),
            ),
          ),
          ListTile(
            title: Text(
              word.example,
              style: TextStyle(fontSize: 16),
            ),
          ),
          ListTile(
            title: Text(
              "Correct Times: ${word.correctTimes.toString()}",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
