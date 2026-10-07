import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewUiSystemBars {
  const NewUiSystemBars._();

  static Future<void> apply(Brightness brightness) async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(forBrightness(brightness));
  }

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
