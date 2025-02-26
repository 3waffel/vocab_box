import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocab_box/common/navigator_key.dart';
import 'package:vocab_box/firebase_options.dart' show DefaultFirebaseOptions;
import 'package:vocab_box/screens/navigation_screen.dart';
import 'package:vocab_box/screens/start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    var usedScheme = FlexScheme.verdunHemlock;
    var fontFamily = GoogleFonts.notoSans().fontFamily;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vocab Box',
      theme: FlexThemeData.light(
        appBarElevation: 0.5,
        scheme: usedScheme,
        fontFamily: fontFamily,
      ),
      darkTheme: FlexThemeData.dark(
        appBarElevation: 2,
        scheme: usedScheme,
        fontFamily: fontFamily,
      ),
      initialRoute: StartScreen.id,
      navigatorKey: navigatorKey,
      routes: {
        StartScreen.id: (context) => StartScreen(),
        NavigationScreen.id: (context) => NavigationScreen(),
      },
    );
  }
}
