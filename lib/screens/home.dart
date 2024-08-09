import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    SnackBarExt(context).fluidSnackBar("Sync All Done");
  }

  /// Sync single deck
  Future<void> _syncSingleDeckStatus(String deckName) async {
    var index = deckStatusList.indexWhere((deck) => deck.deckName == deckName);
    if (index == -1) {
      return;
    }

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
              MaterialPageRoute(builder: (context) => _DeckImportForm()),
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
            cardDatabase.deleteTable(deckName);
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
      alignment: Alignment.centerLeft,
      child: Card.outlined(
        margin: EdgeInsets.all(16),
        clipBehavior: Clip.hardEdge,
        child: Container(
          padding: EdgeInsets.all(16),
          constraints: BoxConstraints(minWidth: 400, maxWidth: 500),
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
      ),
    );
  }
}

class _DeckImportForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DeckImportFormState();
}

class _DeckImportFormState extends State<_DeckImportForm> {
  int currentStep = 0;
  TextEditingController deckNameController = TextEditingController();
  String? fileContent;

  (String, String, String) converterFormat = ('\t', '\n', '');
  List<CardField> columns = [
    CardField.id,
    CardField.frontTitle,
    CardField.frontSubtitle,
    CardField.backTitle,
  ];
  List<CardModel>? cardList;

  final _formKeys = <GlobalKey<FormState>>[
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  _selectFile() async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'csv'],
    );
    if (result != null) {
      try {
        if (kIsWeb) {
          var bytes = result.files.first.bytes!;
          fileContent = utf8.decode(bytes);
        } else {
          var file = File(result.files.first.path!);
          fileContent = file.readAsStringSync();
        }
        ;
        setState(() => deckNameController.text =
            result.files.first.name.replaceAll(RegExp(r"[^a-zA-Z0-9_]"), "_"));
      } catch (e) {
        SnackBarExt(context)
            .fluidSnackBar("Failed to load the deck: " + e.toString());
      }
    }
  }

  _convertFile() {
    if (fileContent == null || deckNameController.text.isEmpty) {
      return;
    }

    try {
      var _cardList = DeckLoader().loadFromString(
        fileContent!,
        converterFormat,
        columns,
      );
      if (_cardList.length > 10000) {
        throw Exception(
            "Deck size exceeds limitation: " + _cardList.length.toString());
      }
      setState(() => cardList = _cardList);
    } catch (e) {
      SnackBarExt(context)
          .fluidSnackBar("Failed to load the deck: " + e.toString());
    }
  }

  _uploadTable() {
    if (cardList == null || cardList!.length > 10000) {
      return;
    }
    var tableName = deckNameController.text;
    cardDatabase.createTable(tableName);
    cardDatabase.insertMany(cardList: cardList!, table: tableName);
  }

  List<Step> getSteps() {
    return <Step>[
      Step(
        title: Text("File"),
        isActive: currentStep == 0,
        state: switch (currentStep) {
          0 => StepState.editing,
          _ when currentStep > 0 => StepState.complete,
          _ => StepState.disabled,
        },
        content: Form(
          key: _formKeys[0],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormField(
                builder: (state) => TextButton(
                  onPressed: _selectFile,
                  child: state.isValid ? Text("Selected") : Text("Select File"),
                ),
                validator: (_) =>
                    (fileContent == null) ? "Please select a file" : null,
              ),
              TextFormField(
                controller: deckNameController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9_]"))
                ],
                onFieldSubmitted: (value) =>
                    setState(() => deckNameController.text = value),
                decoration: InputDecoration(labelText: "Deck Name"),
                validator: (_) => (deckNameController.text.isEmpty)
                    ? "Please enter deck name"
                    : null,
              ),
            ],
          ),
        ),
      ),
      Step(
        title: Text("Convert"),
        isActive: currentStep == 1,
        state: switch (currentStep) {
          1 => StepState.editing,
          _ when currentStep > 1 => StepState.complete,
          _ => StepState.disabled,
        },
        content: Form(
          key: _formKeys[1],
          child: Column(
            children: [
              SizedBox(
                height: 80,
                width: double.infinity,
                child: ReorderableListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: columns
                      .map((e) => Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white30),
                          ),
                          key: Key(e.name),
                          padding: EdgeInsets.all(20),
                          child: Text(e.name)))
                      .toList(),
                  onReorder: (oldIndex, newIndex) => setState(() {
                    if (newIndex > columns.length) newIndex = columns.length;
                    if (oldIndex < newIndex) newIndex--;
                    columns.insert(newIndex, columns.removeAt(oldIndex));
                  }),
                ),
              ),
              DropdownButtonFormField(
                hint: Text("Field Delimiter"),
                value: '\t',
                items: [
                  DropdownMenuItem(value: ',', child: Text("comma")),
                  DropdownMenuItem(value: '\t', child: Text("tab")),
                ],
                onChanged: (value) => converterFormat = (
                  value ?? converterFormat.$1,
                  converterFormat.$2,
                  converterFormat.$3,
                ),
              ),
              FormField(
                builder: (state) => Row(
                  children: [
                    TextButton(
                      onPressed: _convertFile,
                      child: Text("Load"),
                    ),
                    Flexible(
                      child: state.isValid
                          ? Text(cardList!.first.toString())
                          : Text("Card list is not loaded"),
                    ),
                  ],
                ),
                validator: (_) =>
                    cardList == null ? "Card list is not loaded" : null,
              ),
            ],
          ),
        ),
      ),
      Step(
        title: Text("Check"),
        isActive: currentStep == 2,
        state: switch (currentStep) {
          2 => StepState.editing,
          _ when currentStep > 2 => StepState.complete,
          _ => StepState.disabled,
        },
        content: Form(
            key: _formKeys[2],
            child: Wrap(
              clipBehavior: Clip.hardEdge,
              direction: Axis.vertical,
              spacing: 10,
              children: cardList == null
                  ? []
                  : [
                      Text("deck name:\t" + deckNameController.text),
                      Text("deck size:\t" + cardList!.length.toString()),
                      Text(cardList!.first.toString()),
                    ],
            )),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(8),
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: currentStep,
          onStepCancel: () => currentStep == 0
              ? Navigator.of(context).pop()
              : setState(() => currentStep -= 1),
          onStepContinue: () {
            if (_formKeys[currentStep].currentState!.validate()) {
              if (currentStep == getSteps().length - 1) {
                _uploadTable();
                Navigator.of(context).pop();
              } else {
                setState(() => currentStep += 1);
              }
            }
          },
          onStepTapped: (step) => setState(() => currentStep = step),
          steps: getSteps(),
        ),
      ),
    );
  }
}
