import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab_box/components/deck_fields_setting.dart';
import 'package:vocab_box/data/database/card_repository.dart';
import 'package:vocab_box/screens/start_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  static const String id = "/settings";

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Widget? getTrailingButton(String key) {
    final fieldsMatch = RegExp(r'^(.*?)_(front|back)Fields$').firstMatch(key);
    var widget = null;
    switch (key) {
      case _ when fieldsMatch != null:
        {
          final deckName = fieldsMatch.group(1);
          var callback = null;
          widget = FutureBuilder(
            future: cardRepository.getTableNames(),
            builder: (ctx, value) {
              if (!value.hasData) {
                return CircularProgressIndicator();
              }
              var tableNames = value.data!;
              if (tableNames.contains(deckName)) {
                callback = () => Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (context) =>
                          DeckFieldsSetting(deckName: deckName!),
                    ))
                    .then((_) => setState(() {}));
                return IconButton(
                  onPressed: callback,
                  icon: Icon(Icons.edit),
                );
              } else {
                callback = () => SharedPreferences.getInstance()
                    .then((prefs) => prefs.remove(key))
                    .then((_) => setState(() {}));
                return IconButton(
                  onPressed: callback,
                  icon: Icon(Icons.delete),
                );
              }
            },
          );
        }
      default:
    }
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (ctx, value) {
              if (!value.hasData) {
                return CircularProgressIndicator();
              }
              var packageInfo = value.data!;
              var applicationVersion =
                  "${packageInfo.version}+${packageInfo.buildNumber}";
              return AboutListTile(
                icon: Icon(Icons.info),
                child: Text("About"),
                applicationName: packageInfo.appName,
                applicationVersion: applicationVersion,
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.start),
            title: Text("Back to Start Screen"),
            onTap: () => Navigator.popAndPushNamed(context, StartScreen.id),
          ),
          ExpansionTile(
            leading: Icon(Icons.menu),
            title: Text("Preferences"),
            children: [
              FutureBuilder(
                future: SharedPreferences.getInstance(),
                builder: (context, value) {
                  if (!value.hasData) {
                    return CircularProgressIndicator();
                  }
                  final prefs = value.data!;
                  final keys = prefs.getKeys().toList();
                  return Column(
                    children: keys.map((key) {
                      final value = prefs.get(key);
                      return ListTile(
                        title: Text(key),
                        subtitle: Text(value.toString()),
                        trailing: getTrailingButton(key),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
