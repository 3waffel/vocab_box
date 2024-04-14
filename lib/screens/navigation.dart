import 'package:flutter/material.dart';
import 'package:vocab_box/screens/browser.dart';
import 'package:vocab_box/screens/home.dart';
import 'package:vocab_box/screens/settings.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});
  static const String id = "/navigation";

  @override
  State<StatefulWidget> createState() => _NavigationScreenState();
}

class Destination {
  final String label;
  final Widget icon;
  final Widget selectedIcon;
  final Widget Function(BuildContext) screen;

  const Destination(
    this.label,
    this.icon,
    this.selectedIcon,
    this.screen,
  );
}

class _NavigationScreenState extends State<NavigationScreen> {
  bool showNavigationDrawer = false;
  int screenIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showNavigationDrawer = MediaQuery.of(context).size.width >= 450;
  }

  final destinations = <Destination>[
    Destination(
      "Home",
      Icon(Icons.home_outlined),
      Icon(Icons.home),
      (context) => HomeScreen(),
    ),
    Destination(
      "Browser",
      Icon(Icons.book_outlined),
      Icon(Icons.book),
      (context) => BrowserScreen(),
    ),
    Destination(
      "Settings",
      Icon(Icons.settings_outlined),
      Icon(Icons.settings),
      (context) => SettingsScreen(),
    ),
  ];

  Widget buildBottomBarScaffold() {
    return Scaffold(
      body: Builder(builder: destinations[screenIndex].screen),
      bottomNavigationBar: NavigationBar(
        selectedIndex: screenIndex,
        onDestinationSelected: (index) => setState(() => screenIndex = index),
        destinations: destinations
            .map((dest) => NavigationDestination(
                  label: dest.label,
                  icon: dest.icon,
                  selectedIcon: dest.selectedIcon,
                ))
            .toList(),
      ),
    );
  }

  Widget buildDrawerScaffold() {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        top: false,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: NavigationRail(
                minWidth: 50,
                selectedIndex: screenIndex,
                useIndicator: true,
                onDestinationSelected: (index) =>
                    setState(() => screenIndex = index),
                destinations: destinations
                    .map((dest) => NavigationRailDestination(
                          label: Text(dest.label),
                          icon: dest.icon,
                          selectedIcon: dest.selectedIcon,
                        ))
                    .toList(),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: Builder(builder: destinations[screenIndex].screen))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return showNavigationDrawer
        ? buildDrawerScaffold()
        : buildBottomBarScaffold();
  }
}
