import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab_box/screens/navigation.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});
  static const String id = "/start";

  @override
  State<StatefulWidget> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  Widget content = Text("Initializing...");

  @override
  void initState() {
    super.initState();
    _checkInitialized();
  }

  _grantPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final path = await getApplicationDocumentsDirectory();
    prefs.setString('persistedStoragePath', path.path);
    Navigator.popAndPushNamed(context, NavigationScreen.id);
  }

  _checkInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('persistedStoragePath');
    if (path != null) {
      Navigator.popAndPushNamed(context, NavigationScreen.id);
    } else {
      setState(() {
        content = ElevatedButton.icon(
          icon: Icon(Icons.storage),
          label: Text("Grant Storage Permission"),
          onPressed: _grantPermission,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Initialization")),
      body: Center(child: content),
    );
  }
}
