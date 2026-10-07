import 'package:dsm_helper/new_ui/legacy/legacy_page_host.dart';
import 'package:dsm_helper/new_ui/shell/new_ui_primary_page.dart';
import 'package:dsm_helper/new_ui/shell/new_ui_shell.dart';
import 'package:flutter/material.dart';

class NewUiAppDestination {
  const NewUiAppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.legacyBuilder,
    this.onLegacyBack,
  });

  factory NewUiAppDestination.test({
    required String label,
    required WidgetBuilder legacyBuilder,
    bool Function()? onLegacyBack,
  }) {
    return NewUiAppDestination(
      label: label,
      icon: Icons.circle_outlined,
      selectedIcon: Icons.circle,
      legacyBuilder: legacyBuilder,
      onLegacyBack: onLegacyBack,
    );
  }

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final WidgetBuilder legacyBuilder;
  final bool Function()? onLegacyBack;
}

class NewUiAppShell extends StatelessWidget {
  const NewUiAppShell({
    super.key,
    required this.notificationBuilder,
    required this.destinations,
  }) : assert(destinations.length == 5);

  final WidgetBuilder notificationBuilder;
  final List<NewUiAppDestination> destinations;

  void _pushLegacy(
    BuildContext context,
    WidgetBuilder builder, {
    bool Function()? onBack,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => LegacyPageHost(
          builder: builder,
          onBack: onBack,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NewUiShell(
      destinations: destinations.map((destination) {
        return NewUiShellDestination(
          label: destination.label,
          icon: destination.icon,
          selectedIcon: destination.selectedIcon,
          root: (tabContext) {
            return NewUiPrimaryPage(
              title: destination.label,
              onOpenNotifications: () {
                _pushLegacy(tabContext, notificationBuilder);
              },
              onOpenLegacyFeature: () {
                _pushLegacy(
                  tabContext,
                  destination.legacyBuilder,
                  onBack: destination.onLegacyBack,
                );
              },
            );
          },
        );
      }).toList(growable: false),
    );
  }
}
