import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vocab_box/common/deck_metadata.dart';
import 'package:vocab_box/components/deck_import_form.dart';
import 'package:vocab_box/components/deck_section.dart';
import 'package:vocab_box/data/database/card_repository.dart';
import 'package:vocab_box/utils/snackbar.dart';

class HomeScreen extends StatefulWidget {
  static const String id = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static List<DeckMetadata> deckStatusList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      floatingActionButton: Wrap(
        direction: Axis.vertical,
        spacing: 10,
        children: [
          IconButton.filledTonal(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DeckImportForm()),
            ),
          ),
          IconButton.filledTonal(
            icon: Icon(Icons.sync),
            onPressed: _syncAllDeckStatus,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: deckStatusList.length,
        itemBuilder: (context, index) => Dismissible(
          key: Key(deckStatusList[index].deckName),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) => setState(() {
            var deckName = deckStatusList[index].deckName;
            deckStatusList.removeAt(index);
            cardRepository.deleteTable(deckName);
          }),
          confirmDismiss: (direction) async => await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Delete Deck"),
              content: Text("Are you sure to delete this deck?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Continue"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Cancel"),
                ),
              ],
            ),
          ),
          child: DeckSection(deckStatusList[index]),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (deckStatusList.isEmpty) {
      _syncAllDeckStatus();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  /// Sync all tables
  Future<void> _syncAllDeckStatus() async {
    List<DeckMetadata> newDeckStatusList = [];
    final tables = await cardRepository.getTableNames();
    for (final deckName in tables) {
      var deckMetadata = await DeckMetadata.syncDeckMetadata(deckName);
      newDeckStatusList.add(deckMetadata);
    }
    if (!listEquals(deckStatusList, newDeckStatusList)) {
      setState(() => deckStatusList = newDeckStatusList);
      SnackBarExt(context).fluidSnackBar("Sync All Done");
    }
  }

  /// Sync single deck
  Future<void> _syncSingleDeckStatus(String deckName) async {
    var index = deckStatusList.indexWhere((deck) => deck.deckName == deckName);
    if (index == -1) {
      return;
    }
    var deckMetadata = await DeckMetadata.syncDeckMetadata(deckName);
    setState(() {
      deckStatusList[index] = deckMetadata;
    });
    SnackBarExt(context).fluidSnackBar("Sync Done: ${deckName}");
  }
}
