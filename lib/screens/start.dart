import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab_box/common/card_database.dart';
import 'package:vocab_box/common/snackbar.dart';
import 'package:vocab_box/screens/navigation.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});
  static const String id = "/start";

  @override
  State<StatefulWidget> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  static FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  _setupStore() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('persistedStoragePath');
    if (path == null) {
      final appDocDir = await getApplicationDocumentsDirectory();
      prefs.setString('persistedStoragePath', appDocDir.path);
    }
    cardDatabase = LocalDatabase();
    Navigator.popAndPushNamed(context, NavigationScreen.id);
  }

  _setupAuth() async {
    final provider = GithubAuthProvider();
    if (kIsWeb) {
      await auth.signInWithPopup(provider);
    } else if (Platform.isAndroid) {
      await auth.signInWithProvider(provider);
    }
    if (auth.currentUser != null) {
      cardDatabase = FireBaseDatabase();
      Navigator.popAndPushNamed(context, NavigationScreen.id);
    } else {
      SnackBarExt(context).fluidSnackBar("Failed to sign in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Start")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Builder(builder: (context) {
              if (auth.currentUser == null) {
                return ElevatedButton.icon(
                  icon: Icon(Icons.login),
                  label: Text("Sign in with GitHub"),
                  onPressed: _setupAuth,
                );
              } else {
                return ElevatedButton.icon(
                  icon: Icon(Icons.login),
                  label: Text("Signed in as ${auth.currentUser!.displayName}"),
                  onPressed: () {
                    cardDatabase = FireBaseDatabase();
                    Navigator.popAndPushNamed(context, NavigationScreen.id);
                  },
                );
              }
            }),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: ElevatedButton.icon(
                icon: Icon(Icons.storage),
                label: Text("Start with local database"),
                onPressed: _setupStore,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
