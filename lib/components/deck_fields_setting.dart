import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab_box/common/deck_metadata.dart';
import 'package:vocab_box/data/database/card_repository.dart';

import 'draggable_headers.dart';

class DeckFieldsSetting extends StatefulWidget {
  final String deckName;

  DeckFieldsSetting({required this.deckName});

  @override
  State<StatefulWidget> createState() => _DeckFieldsSettingState();
}

class _DeckFieldsSettingState extends State<DeckFieldsSetting> {
  List<String> headers = [];
  List<String> frontFields = [];
  List<String> backFields = [];
  final TextEditingController headerController = TextEditingController();

  @override
  initState() {
    super.initState();
    _initHeaders();
  }

  void _initHeaders() async {
    var table = await cardRepository.getTable(widget.deckName);
    if (table.firstOrNull?.containsKey('data') != null) {
      var data = jsonDecode(table.first['data']);
      headers = List.from(data.keys);
      return setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Up Fields'),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: [
            DraggableHeaders(
              frontFields: frontFields,
              backFields: backFields,
              headers: headers,
              onAccept: (data, targetList) {
                setState(() {
                  targetList.add(data);
                  headers.remove(data);
                });
              },
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setStringList(
                    '${widget.deckName}_frontFields', frontFields);
                prefs.setStringList(
                    '${widget.deckName}_backFields', backFields);
                Navigator.of(context)
                    .pop<DeckFieldsPair>((frontFields, backFields));
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
