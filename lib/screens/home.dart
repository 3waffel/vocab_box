import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vocab_box/common/deck_loader.dart';
import 'package:vocab_box/common/snackbar.dart';
import 'package:vocab_box/screens/learning.dart';
import 'package:vocab_box/models/card.dart';
import 'package:vocab_box/common/database/card_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String id = "/home";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _DeckStatus {
  final String deckName;
  final int deckCount;
  final int completeCount;
  final int learningCount;

  _DeckStatus({
    required this.deckName,
    required this.deckCount,
    required this.completeCount,
    required this.learningCount,
  });
}

class _HomeScreenState extends State<HomeScreen> {
  static List<_DeckStatus> deckStatusList = [];

  @override
  void initState() {
    super.initState();
    if (deckStatusList.isEmpty) {
      _syncAllDeckStatus();
    }
  }

  /// Sync all tables
  Future<void> _syncAllDeckStatus() async {
    List<_DeckStatus> newDeckStatusList = [];
    final tables = await cardDatabase.getTableNameList();
    for (final deckName in tables) {
      final maps = await cardDatabase.getTable(deckName);
      final cardList = CardModel.fromMapList(maps);
      final deckCount = cardList.length;
      final completeCount =
          cardList.where((item) => item.correctTimes > 3).length;
      final learningCount = cardList.where((item) => item.isLearning).length;
      newDeckStatusList.add(_DeckStatus(
          deckName: deckName,
          deckCount: deckCount,
          completeCount: completeCount,
          learningCount: learningCount));
    }
    setState(() => deckStatusList = newDeckStatusList);
    SnackBarExt(context).fluidSnackBar("Sync Done");
  }

  /// Sync single deck
  Future<void> _syncSingleDeckStatus(int index) async {
    final deckName = deckStatusList[index].deckName;
    final maps = await cardDatabase.getTable(deckName);
    final cardList = CardModel.fromMapList(maps);
    final deckCount = cardList.length;
    final completeCount =
        cardList.where((item) => item.correctTimes > 3).length;
    final learningCount = cardList.where((item) => item.isLearning).length;
    setState(() {
      deckStatusList[index] = _DeckStatus(
          deckName: deckName,
          deckCount: deckCount,
          completeCount: completeCount,
          learningCount: learningCount);
    });
    SnackBarExt(context).fluidSnackBar("Sync Done: ${deckName}");
  }

  _addDeck() async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'csv'],
    );
    if (result != null) {
      try {
        late String fileContent;
        if (kIsWeb) {
          var bytes = result.files.first.bytes!;
          fileContent = utf8.decode(bytes);
        } else {
          var file = File(result.files.first.path!);
          fileContent = file.readAsStringSync();
        }

        var cardList = DeckLoader().loadFromString(fileContent);
        if (cardList.length > 10000) {
          throw Exception(
              "Deck size exceeds limitation: " + cardList.length.toString());
        }

        var fileName = result.files.first.name;
        var tableName = fileName.replaceAll(RegExp(r"[^a-zA-Z0-9_]"), "_");
        var confirmButton = TextButton(
          onPressed: () {
            cardDatabase.createTable(tableName);
            cardDatabase.insertMany(cardList: cardList, table: tableName);
            Navigator.of(context).pop();
            _syncAllDeckStatus();
          },
          child: Text("Confirm"),
        );
        var cancelButton = TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancel"),
        );
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("New Deck"),
            content: Wrap(
              clipBehavior: Clip.hardEdge,
              direction: Axis.vertical,
              spacing: 10,
              children: [
                Text("deck name:\t" + tableName),
                Text("deck size:\t" + cardList.length.toString()),
                Text(cardList.first.toString()),
              ],
            ),
            actions: [confirmButton, cancelButton],
          ),
        );
      } catch (e) {
        SnackBarExt(context)
            .fluidSnackBar("Failed to load the deck: " + e.toString());
      }
    }
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
            onPressed: _addDeck,
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
            cardDatabase.deleteTable(deckName);
          }),
          confirmDismiss: (direction) async => await showDialog(
            context: context,
            builder: (context) => AlertDialog(
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
          child: _DeckSection(deckStatusList[index]),
        ),
      ),
    );
  }
}

class _DeckSection extends StatelessWidget {
  final _DeckStatus _deckStatus;

  _DeckSection(this._deckStatus);

  @override
  Widget build(BuildContext context) {
    final deckName = _deckStatus.deckName;
    final deckCount = _deckStatus.deckCount;
    final completeCount = _deckStatus.completeCount;
    final learningCount = _deckStatus.learningCount;

    final deckInfoRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${deckName}",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.inbox),
          label: Text("Start"),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LearningScreen(),
              settings: RouteSettings(
                arguments: LearningScreenArguments(deckName: deckName),
              ),
            ),
          ),
        ),
      ],
    );
    final progressBarRow = LinearProgressIndicator(
      value: (completeCount / deckCount),
      minHeight: 6,
    );
    final learningInfoRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Learning ${learningCount.toString()}",
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Text(
          "${deckCount.toString()} in total",
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );

    return Align(
      child: Container(
        constraints: BoxConstraints(minWidth: 400, maxWidth: 500),
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).hoverColor,
          border: Border.all(color: Theme.of(context).highlightColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: deckInfoRow,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: progressBarRow,
            ),
            learningInfoRow
          ],
        ),
      ),
    );
  }
}
