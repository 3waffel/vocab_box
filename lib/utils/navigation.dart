import 'package:flutter/material.dart';

extension ConstrainedNavigation on NavigatorState {
  Future<T?> pushConstrained<T extends Object?>(
    BuildContext context,
    Widget screen, {
    RouteSettings? settings,
    double maxWidth = 600,
  }) {
    return push<T>(
      MaterialPageRoute<T>(
        builder: (context) => ConstrainedScreenWrapper(
          maxWidth: maxWidth,
          child: screen,
        ),
        settings: settings,
      ),
    );
  }
}

class ConstrainedScreenWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ConstrainedScreenWrapper({
    super.key,
    required this.child,
    this.maxWidth = 600,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
