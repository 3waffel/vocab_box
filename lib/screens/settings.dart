import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

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
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          AboutListTile(
            icon: Icon(Icons.info),
            child: Text("About"),
            applicationName: packageInfo?.appName,
            applicationVersion: packageInfo != null
                ? "${packageInfo!.version}+${packageInfo!.buildNumber}"
                : null,
          )
        ],
      ),
    );
  }
}
