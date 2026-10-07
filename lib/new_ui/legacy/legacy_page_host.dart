import 'package:dsm_helper/themes/dark.dart';
import 'package:dsm_helper/themes/light.dart';
import 'package:flutter/material.dart';

class LegacyPageHost extends StatelessWidget {
  const LegacyPageHost({
    required this.child,
    this.brightness,
    super.key,
  });

  final Widget child;
  final Brightness? brightness;

  @override
  Widget build(BuildContext context) {
    final effectiveBrightness = brightness ?? Theme.of(context).brightness;
    final legacyTheme =
        effectiveBrightness == Brightness.dark ? darkTheme : lightTheme;

    return Theme(
      data: legacyTheme,
      child: child,
    );
  }
}
