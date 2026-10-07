import 'package:dsm_helper/themes/dark.dart' as legacy_dark;
import 'package:dsm_helper/themes/light.dart' as legacy_light;
import 'package:flutter/material.dart';

class LegacyPageHost extends StatefulWidget {
  const LegacyPageHost({
    super.key,
    required this.builder,
  });

  final WidgetBuilder builder;

  @override
  State<LegacyPageHost> createState() => _LegacyPageHostState();
}

class _LegacyPageHostState extends State<LegacyPageHost> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _handleBack(bool didPop) {
    if (didPop) {
      return;
    }

    final navigator = _navigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return;
    }

    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final theme = brightness == Brightness.dark
        ? legacy_dark.darkTheme
        : legacy_light.lightTheme;

    return Theme(
      data: theme,
      child: PopScope(
        canPop: false,
        onPopInvoked: _handleBack,
        child: Navigator(
          key: _navigatorKey,
          onGenerateRoute: (settings) {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: widget.builder,
            );
          },
        ),
      ),
    );
  }
}
