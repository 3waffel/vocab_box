import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/material.dart';
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
    return MaterialApp(
      title: 'Vocab Box',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: StartScreen.id,
      routes: {
        StartScreen.id: (context) => StartScreen(),
        NavigationScreen.id: (context) => NavigationScreen(),
      },
    );
  }
}
