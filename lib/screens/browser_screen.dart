import 'package:flutter/material.dart';
import 'package:vocab_box/common/deck_metadata.dart';
import 'package:vocab_box/data/database/card_repository.dart';
import 'package:vocab_box/data/models/card_model.dart';
import 'package:vocab_box/screens/detail_screen.dart';

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
  DeckMetadata? deckMetadata;

  List<CardModel> cardList = [];
  List<CardModel> filtered = [];
  bool isSearchBarActive = false;

  @override
  void initState() {
    super.initState();
    _initDeckNameList();
  }

  Future<void> _initDeckNameList() async {
    final tables = await cardRepository.getTableNames();
    setState(() => deckNameList = tables);
  }

  Future<void> _loadDeck() async {
    if (selectedDeck != null) {
      final maps = await cardRepository.getTable(selectedDeck!);
      final metadata = await DeckMetadata.syncDeckMetadata(selectedDeck!);
      setState(() {
        deckMetadata = metadata;
        cardList = CardModel.fromMapList(maps);
        filtered = cardList;
      });
    }
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondary,
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
                var frontFields = deckMetadata?.frontFields;
                if (frontFields == null || frontFields.isEmpty) {
                  return;
                }
                setState(() => filtered = cardList
                    .where(
                        (item) => (item.data[frontFields[0]]).contains(value))
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
        curve: Curves.decelerate,
        duration: const Duration(milliseconds: 100),
        child: isSearchBarActive
            ? _buildSearchBar()
            : IconButton.filledTonal(
                onPressed: () => setState(() => isSearchBarActive = true),
                icon: Icon(Icons.search)),
      ),
      body: deckMetadata == null || deckMetadata!.frontFields.isEmpty
          ? null
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                Color cardColor = Colors.white70;
                var data = filtered[index].data;
                var title = Text(
                  data[deckMetadata!.frontFields[0]],
                  style: TextStyle(color: cardColor),
                );
                var subtitle = deckMetadata!.backFields.isEmpty
                    ? null
                    : Text(data[deckMetadata!.backFields[0]]);

                return ListTile(
                  title: title,
                  subtitle: subtitle,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        card: filtered[index],
                        deckMetadata: deckMetadata!,
                      ),
                    ),
                  ),
                );
              }),
    );
  }
}
