import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewUiSystemBars {
  const NewUiSystemBars._();

  static SystemUiOverlayStyle forBrightness(Brightness brightness) {
    final iconBrightness = brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: iconBrightness,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: iconBrightness,
      systemNavigationBarDividerColor: Colors.transparent,
    );
  }
}
