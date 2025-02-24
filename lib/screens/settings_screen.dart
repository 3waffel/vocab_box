import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab_box/screens/start_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  static const String id = "/settings";

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static PackageInfo? packageInfo;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform()
        .then((value) => setState(() => packageInfo = value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          FutureBuilder(
            future: SharedPreferences.getInstance(),
            builder: (context, value) {
              var aboutBoxChildren = <Widget>[];
              final savedSettings = value.data;
              if (savedSettings != null) {
                aboutBoxChildren = savedSettings.getKeys().map((key) {
                  var value = savedSettings.get(key);
                  return Text(
                    "${key}:  ${value.toString()}",
                    style: Theme.of(context).textTheme.labelLarge,
                  );
                }).toList();
              }
              var applicationVersion = packageInfo != null
                  ? "${packageInfo!.version}+${packageInfo!.buildNumber}"
                  : null;
              return AboutListTile(
                  icon: Icon(Icons.info),
                  child: Text("About"),
                  applicationName: packageInfo?.appName,
                  applicationVersion: applicationVersion,
                  aboutBoxChildren: aboutBoxChildren);
            },
          ),
          ListTile(
            leading: Icon(Icons.start),
            title: Text("Back to Start Screen"),
            onTap: () => Navigator.popAndPushNamed(context, StartScreen.id),
          ),
        ],
      ),
    );
  }
}
