import 'package:flutter/material.dart';
import 'package:vocab_box/common/database/card_database.dart';
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
  bool isSearchBarActive = false;

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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton(
              padding: EdgeInsets.symmetric(horizontal: 8),
              borderRadius: BorderRadius.all(Radius.circular(5)),
              value: selectedDeck,
              items: deckNameList
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ))
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
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => isSearchBarActive = false),
                  icon: Icon(Icons.close),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Browser")),
      floatingActionButton: AnimatedSize(
        curve: Curves.bounceInOut,
        duration: const Duration(milliseconds: 200),
        child: isSearchBarActive
            ? _buildSearchBar()
            : IconButton.filledTonal(
                onPressed: () => setState(() => isSearchBarActive = true),
                icon: Icon(Icons.search)),
      ),
      body: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 10),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            Color cardColor = Colors.white70;
            switch (filtered[index].frontTitle.split(' ')[0]) {
              case 'der':
                cardColor = Colors.blueAccent;
              case 'das':
                cardColor = Colors.greenAccent;
              case 'die':
                cardColor = Colors.redAccent;
            }

            return ListTile(
              title: Text(
                filtered[index].frontTitle,
                style: TextStyle(color: cardColor),
              ),
              subtitle: Text("${filtered[index].backTitle}"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(card: filtered[index]),
                ),
              ),
            );
          }),
    );
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required CardModel this.card});
  final CardModel card;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            title: Text(
              card.frontTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          ListTile(
            title: Text(
              card.backTitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ListTile(
            title: Text(
              card.frontSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          ListTile(
            title: Text(
              "Correct Times: ${card.correctTimes.toString()}",
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}
