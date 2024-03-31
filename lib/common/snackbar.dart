import 'package:flutter/material.dart';

extension SnackBarExt on BuildContext {
  void fluidSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message, style: Theme.of(this).textTheme.labelMedium),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        closeIconColor: Theme.of(this).colorScheme.primary,
        backgroundColor: Theme.of(this).colorScheme.inversePrimary,
      ));
  }
}
