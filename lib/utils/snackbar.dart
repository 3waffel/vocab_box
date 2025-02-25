import 'package:flutter/material.dart';
import 'package:vocab_box/common/navigator_key.dart';

extension SnackBarExt on BuildContext {
  void fluidSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message, style: TextTheme.of(this).labelMedium),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        closeIconColor: ColorScheme.of(this).primary,
        backgroundColor: ColorScheme.of(this).primaryContainer,
      ));
  }
}

void navigatorSnackBar(String message) =>
    SnackBarExt(navigatorKey.currentContext!).fluidSnackBar(message);
