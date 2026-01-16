import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab_box/components/draggable_headers.dart';
import 'package:vocab_box/data/database/card_repository.dart';
import 'package:vocab_box/utils/snackbar.dart';
import 'package:vocab_box/data/models/card_model.dart';

class DeckImportScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DeckImportScreenState();
}

class _DeckImportScreenState extends State<DeckImportScreen> {
  int currentStep = 0;
  String? fileContent;

  var deckNameController = TextEditingController();
  var fieldDelimiterController = TextEditingController(text: '\t');
  var eolController = TextEditingController(text: '\n');
  var emptyValueController = TextEditingController(text: '');

  final _formKeys = <GlobalKey<FormState>>[
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  List<String>? headers;
  List<CardModel>? cardList;
  List<String> frontFields = [];
  List<String> backFields = [];

  static const String bundledDeckPath = 'assets/word_list_a1.txt';

  Future<List<CardModel>> loadFromAsset({
    String path = bundledDeckPath,
  }) async {
    final rawString = await rootBundle.loadString(path);
    return loadFromString(rawString);
  }

  List<CardModel> loadFromString(String content) {
    final _converter = CsvToListConverter(
      fieldDelimiter: fieldDelimiterController.text,
      eol: eolController.text,
      convertEmptyTo: emptyValueController.text,
      shouldParseNumbers: false,
    );
    final fields = _converter
        .convert(content)
        .map((row) => row.map((cell) => cell.toString().trim()).toList())
        .where((row) => row.any((cell) => cell.isNotEmpty))
        .toList();

    setState(() {
      headers = fields.first;
      frontFields.clear();
      backFields.clear();
    });

    final values = fields.skip(1).toList();
    return List.generate(
      values.length,
      (index) {
        Map<String, Object?> data = {};
        for (var i = 0; i < headers!.length; i++) {
          data[headers![i]] = values[index][i];
        }
        return CardModel.fromMap({
          'id': data['id'] == null
              ? index
              : int.tryParse(data['id'].toString()) ?? index,
          'data': jsonEncode(data),
        });
      },
    );
  }

  void _selectFile() async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'csv'],
    );
    if (result == null) {
      return;
    }
    try {
      if (kIsWeb) {
        var bytes = result.files.first.bytes!;
        fileContent = utf8.decode(bytes);
      } else {
        var file = File(result.files.first.path!);
        fileContent = file.readAsStringSync();
      }
      setState(() => deckNameController.text =
          result.files.first.name.replaceAll(RegExp(r"[^a-zA-Z0-9_]"), "_"));
    } catch (e) {
      navigatorSnackBar("Failed to load the deck: " + e.toString());
    }
  }

  void _convertFile() {
    if (fileContent == null || deckNameController.text.isEmpty) {
      return;
    }

    try {
      var _cardList = loadFromString(fileContent!);
      if (_cardList.length > 10000) {
        throw Exception(
            "Deck size exceeds limitation: " + _cardList.length.toString());
      }
      setState(() {
        cardList = _cardList;
      });
    } catch (e) {
      navigatorSnackBar("Failed to load the deck: " + e.toString());
    }
  }

  void _updateTable() async {
    if (cardList == null || cardList!.length > 10000) {
      return;
    }
    var tableName = deckNameController.text;

    cardRepository.createTable(tableName);
    cardRepository.insertMany(items: cardList!, table: tableName);

    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('${tableName}_frontFields', frontFields);
    prefs.setStringList('${tableName}_backFields', backFields);
  }

  List<Step> getSteps() {
    return <Step>[
      buildLoadFileStep(),
      buildFieldsLayoutStep(),
    ];
  }

  Widget buildFormatInputs() {
    var fieldDelimiterDropdown = DropdownButtonFormField<String>(
      value: fieldDelimiterController.text,
      decoration: InputDecoration(labelText: 'Field Delimiter'),
      items: [
        DropdownMenuItem(value: '\t', child: Text(r'Tab "\t"')),
        DropdownMenuItem(value: ',', child: Text(r'Comma ","')),
        DropdownMenuItem(value: ';', child: Text(r'Semicolon ";"')),
        DropdownMenuItem(value: '|', child: Text(r'Pipe "|"')),
      ],
      onChanged: (value) {
        setState(() {
          fieldDelimiterController.text = value!;
        });
      },
    );
    var eolCharacterDropdown = DropdownButtonFormField<String>(
      value: eolController.text,
      decoration: InputDecoration(labelText: 'End-of-Line Character'),
      items: [
        DropdownMenuItem(value: '\n', child: Text(r'Newline "\n"')),
        DropdownMenuItem(
            value: '\r\n', child: Text(r'Carriage Return + Newline "\r\n"')),
      ],
      onChanged: (value) {
        setState(() {
          eolController.text = value!;
        });
      },
    );
    var emptyReplacementTextField = TextField(
      controller: emptyValueController,
      decoration: InputDecoration(labelText: 'Empty Value Replacement'),
    );
    return Column(
      children: [
        fieldDelimiterDropdown,
        eolCharacterDropdown,
        emptyReplacementTextField,
      ],
    );
  }

  Step buildLoadFileStep() {
    var formChildren = [
      TextFormField(
        controller: deckNameController,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9_]"))
        ],
        onFieldSubmitted: (value) =>
            setState(() => deckNameController.text = value),
        decoration: InputDecoration(labelText: "Deck Name"),
        validator: (_) {
          if (deckNameController.text.isEmpty) {
            return "Please enter deck name";
          } else if (fileContent == null) {
            return "Please select a file";
          } else if (deckNameController.text.startsWith(RegExp(r"[0-9]"))) {
            return "Illegal table name";
          } else {
            return null;
          }
        },
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: TextButton(
          onPressed: _selectFile,
          child: Text("Select File"),
        ),
      ),
      Divider(),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: buildFormatInputs(),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: TextButton(
          onPressed: _convertFile,
          child: Text("Load File"),
        ),
      ),
      Divider(),
      if (cardList != null)
        TextFormField(
          readOnly: true,
          maxLines: null,
          controller: TextEditingController.fromValue(
            TextEditingValue(text: cardList!.length.toString()),
          ),
          decoration: InputDecoration(labelText: "Deck Size"),
          validator: (_) => cardList == null ? "File not loaded yet" : null,
          style: GoogleFonts.notoSansMono(textStyle: TextStyle(fontSize: 12)),
        ),
      if (cardList != null)
        TextFormField(
          readOnly: true,
          maxLines: null,
          controller: TextEditingController.fromValue(
            TextEditingValue(text: cardList!.first.toString()),
          ),
          scrollController: ScrollController(),
          decoration: InputDecoration(labelText: "Loaded Example"),
          validator: (_) => headers == null ? "File not loaded yet" : null,
          style: GoogleFonts.notoSansMono(textStyle: TextStyle(fontSize: 12)),
        ),
    ];

    return Step(
      title: Text("Load"),
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
          children: formChildren,
        ),
      ),
    );
  }

  Step buildFieldsLayoutStep() {
    if (headers == null) {
      return Step(
        title: Text("Layout"),
        isActive: currentStep == 1,
        state: StepState.disabled,
        content: Center(child: Text("Please complete the previous step first")),
      );
    }

    return Step(
      title: Text("Layout"),
      isActive: currentStep == 1,
      state: switch (currentStep) {
        1 => StepState.editing,
        _ when currentStep > 1 => StepState.complete,
        _ => StepState.disabled,
      },
      content: Form(
        key: _formKeys[1],
        child: DraggableHeaders(
          frontFields: frontFields,
          backFields: backFields,
          headers: headers!,
          onAccept: (data, targetList) {
            setState(() {
              targetList.add(data);
              headers!.remove(data);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                _updateTable();
                Navigator.of(context).pop(deckNameController.text);
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
