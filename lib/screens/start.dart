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
    if (!prefs.containsKey('persistedStoragePath')) {
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        prefs.setString('persistedStoragePath', appDocDir.path);
        cardDatabase = LocalDatabase();
        Navigator.popAndPushNamed(context, NavigationScreen.id);
      } catch (e) {
        SnackBarExt(context).fluidSnackBar("Failed to set up store");
        rethrow;
      }
    } else {
      cardDatabase = LocalDatabase();
      Navigator.popAndPushNamed(context, NavigationScreen.id);
    }
  }

  _setupAuth() async {
    final provider = GithubAuthProvider();
    try {
      if (kIsWeb) {
        await auth.signInWithPopup(provider);
      } else if (Platform.isAndroid) {
        await auth.signInWithProvider(provider);
      } else {
        throw "Platform not supported";
      }
    } catch (e) {
      SnackBarExt(context).fluidSnackBar("Failed to sign in");
      rethrow;
    }
    if (auth.currentUser != null) {
      cardDatabase = FireBaseDatabase();
      Navigator.popAndPushNamed(context, NavigationScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(42),
                child: Image.asset(
                  "assets/icon.png",
                  width: 128,
                  height: 128,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 72),
              child: Text(
                "Vocab Box",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  Builder(builder: (context) {
                    if (auth.currentUser == null) {
                      return ElevatedButton.icon(
                        icon: Icon(Icons.login),
                        label: Text("Sign in with GitHub"),
                        onPressed: (!kIsWeb &&
                                defaultTargetPlatform == TargetPlatform.windows)
                            ? null
                            : _setupAuth,
                      );
                    } else {
                      return ElevatedButton.icon(
                        icon: Icon(Icons.login),
                        label: Text(
                            "Signed in as ${auth.currentUser!.displayName}"),
                        onPressed: () {
                          cardDatabase = FireBaseDatabase();
                          Navigator.popAndPushNamed(
                              context, NavigationScreen.id);
                        },
                      );
                    }
                  }),
                ]),
            Padding(
              padding: EdgeInsets.only(top: 32),
              child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.storage),
                      label: Text("Start with local database"),
                      onPressed: (kIsWeb) ? null : _setupStore,
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
