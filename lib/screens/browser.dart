import 'package:flutter/material.dart';
import 'package:vocab_box/models/card.dart';

/// TODO implement lazy load
class BrowserScreen extends StatelessWidget {
  const BrowserScreen({super.key, required this.cardList});
  final List<CardModel> cardList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Browser"),
      ),
      body: ListView.builder(
        itemCount: cardList.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            cardList[index].word,
            style: TextStyle(color: cardList[index].color),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(card: cardList[index]),
            ),
          ),
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required CardModel this.card});
  final CardModel card;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          card.word,
          style: TextStyle(color: card.color),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(
              card.meaning,
              style: TextStyle(fontSize: 16),
            ),
          ),
          ListTile(
            title: Text(
              card.example,
              style: TextStyle(fontSize: 16),
            ),
          ),
          ListTile(
            title: Text(
              "Correct Times: ${card.correctTimes.toString()}",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
