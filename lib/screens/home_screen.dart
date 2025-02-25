import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

  Widget buildDeckListView() {
    return ListView.builder(
      itemCount: deckStatusList.length,
      itemBuilder: (context, index) => Slidable(
        key: Key(deckStatusList[index].deckName),
        child: DeckSection(deckStatusList[index]),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          dismissible: DismissiblePane(
            closeOnCancel: true,
            onDismissed: () => setState(() {
              var deckName = deckStatusList[index].deckName;
              deckStatusList.removeAt(index);
              cardRepository.deleteTable(deckName);
            }),
            confirmDismiss: () async {
              var confirm = await showDialog(
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
              );
              return confirm ?? false;
            },
          ),
          children: [
            SlidableAction(
              onPressed: (_) => _syncSingleDeckStatus(
                deckStatusList[index].deckName,
              ),
              icon: Icons.sync,
              backgroundColor: ColorScheme.of(context).tertiary,
            ),
          ],
        ),
      ),
    );
  }

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
      body: buildDeckListView(),
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
      navigatorSnackBar("Sync All Done");
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
    navigatorSnackBar("Sync Done: ${deckName}");
  }
}
