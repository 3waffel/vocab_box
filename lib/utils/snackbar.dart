import 'package:flutter/material.dart';
import 'package:vocab_box/common/navigator_key.dart';

extension SnackBarExt on BuildContext {
  void fluidSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message, style: Theme.of(this).textTheme.labelMedium),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        closeIconColor: Theme.of(this).colorScheme.primary,
        backgroundColor: Theme.of(this).colorScheme.inversePrimary,
      ));
  }
}

void navigatorSnackBar(String message) =>
    SnackBarExt(navigatorKey.currentContext!).fluidSnackBar(message);
