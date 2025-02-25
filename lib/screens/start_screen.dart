import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab_box/data/database/card_repository.dart';
import 'package:vocab_box/utils/snackbar.dart';
import 'package:vocab_box/screens/navigation_screen.dart';

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
        cardRepository = CardRepository.local;
        Navigator.popAndPushNamed(context, NavigationScreen.id);
      } catch (e) {
        navigatorSnackBar("Failed to set up store");
        rethrow;
      }
    } else {
      cardRepository = CardRepository.local;
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
      navigatorSnackBar("Failed to sign in");
      rethrow;
    }
    if (auth.currentUser != null) {
      cardRepository = CardRepository.firebase;
      Navigator.popAndPushNamed(context, NavigationScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    var logo = ClipRRect(
      borderRadius: BorderRadius.circular(42),
      child: Image.asset("assets/icon.png", width: 128, height: 128),
    );
    var title = Text(
      "Vocab Box",
      style: GoogleFonts.notable(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );

    var newAuthButton = ElevatedButton.icon(
      icon: Icon(Icons.login),
      label: Text("Sign in with GitHub"),
      onPressed: (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows)
          ? null
          : _setupAuth,
    );
    var oldAuthButton = ElevatedButton.icon(
      icon: Icon(Icons.login),
      label: Text("Signed in as ${auth.currentUser?.displayName}"),
      onPressed: () {
        cardRepository = CardRepository.firebase;
        Navigator.popAndPushNamed(context, NavigationScreen.id);
      },
    );
    var useLocalButton = ElevatedButton.icon(
      icon: Icon(Icons.storage),
      label: Text("Start with local database"),
      onPressed: (kIsWeb) ? null : _setupStore,
    );

    return Scaffold(
      body: Center(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.symmetric(vertical: 16), child: logo),
            Padding(padding: EdgeInsets.only(bottom: 72), child: title),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              children: [
                auth.currentUser == null ? newAuthButton : oldAuthButton
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 32),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [useLocalButton],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
