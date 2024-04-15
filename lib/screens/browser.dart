import 'package:flutter/material.dart';
import 'package:vocab_box/common/card_database.dart';
import 'package:vocab_box/models/card.dart';

/// TODO implement lazy load
class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});
  static const String id = "/browser";

  @override
  State<StatefulWidget> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  static List<String> deckNameList = [];
  String? selectedDeck;
  List<CardModel> cardList = [];
  List<CardModel> filtered = [];

  @override
  void initState() {
    super.initState();
    _initDeckNameList();
  }

  Future<void> _initDeckNameList() async {
    final tables = await cardDatabase.getTableNameList();
    setState(() => deckNameList = tables);
  }

  Future<void> _loadDeck() async {
    if (selectedDeck != null) {
      final maps = await cardDatabase.getTable(selectedDeck!);
      setState(() {
        cardList = CardModel.fromMapList(maps);
        filtered = cardList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Browser")),
      bottomSheet: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  value: selectedDeck,
                  items: deckNameList
                      .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedDeck = value);
                    _loadDeck();
                  },
                ),
              ),
              SizedBox(
                  width: 180,
                  child: TextField(
                      onChanged: (value) {
                        setState(() => filtered = cardList
                            .where((item) => item.frontTitle.contains(value))
                            .toList());
                      },
                      decoration:
                          InputDecoration(prefixIcon: Icon(Icons.search)))),
            ],
          )),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 10),
        itemCount: filtered.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            filtered[index].frontTitle,
            style: TextStyle(color: filtered[index].color),
          ),
          subtitle: Text("${filtered[index].backTitle}"),
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
        title: Text(card.frontTitle, style: TextStyle(color: card.color)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: Text(card.backTitle, style: TextStyle(fontSize: 16))),
          ListTile(
              title: Text(card.frontSubtitle, style: TextStyle(fontSize: 16))),
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
