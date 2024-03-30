import 'package:flutter/material.dart';
import 'package:vocab_box/deck_loader.dart';
import 'package:vocab_box/models/card.dart';

/// TODO implement lazy load
class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<StatefulWidget> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  List<CardModel> filtered = [];

  @override
  void initState() {
    super.initState();
    filtered = DeckLoader().cardList;
  }

  @override
  Widget build(BuildContext context) {
    final cardList = DeckLoader().cardList;
    return Scaffold(
      appBar: AppBar(title: Text("Browser")),
      bottomSheet: Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            onChanged: (value) {
              setState(() => filtered =
                  cardList.where((item) => item.word.contains(value)).toList());
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
            ),
          )),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 10),
        itemCount: filtered.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            filtered[index].word,
            style: TextStyle(color: filtered[index].color),
          ),
          subtitle: Text("${filtered[index].meaning}"),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(card: filtered[index]),
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
        title: Text(card.word, style: TextStyle(color: card.color)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: Text(card.meaning, style: TextStyle(fontSize: 16))),
          ListTile(title: Text(card.example, style: TextStyle(fontSize: 16))),
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
