import 'package:dsm_helper/themes/dark.dart' as legacy_dark;
import 'package:dsm_helper/themes/light.dart' as legacy_light;
import 'package:flutter/material.dart';

class LegacyPageHost extends StatelessWidget {
  const LegacyPageHost({
    super.key,
    required this.builder,
  });

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final theme = brightness == Brightness.dark
        ? legacy_dark.darkTheme
        : legacy_light.lightTheme;

    return Theme(
      data: theme,
      child: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: builder,
          );
        },
      ),
    );
  }
}
