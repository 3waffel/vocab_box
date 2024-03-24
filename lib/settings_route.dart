import 'package:flutter/material.dart';

class SettingsRoute extends StatelessWidget {
  const SettingsRoute({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: ElevatedButton(
              child: Text("placeholder"),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}
