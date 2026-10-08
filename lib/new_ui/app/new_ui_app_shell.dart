import 'package:dsm_helper/new_ui/legacy/legacy_page_host.dart';
import 'package:dsm_helper/new_ui/shell/new_ui_primary_page.dart';
import 'package:dsm_helper/new_ui/shell/new_ui_shell.dart';
import 'package:flutter/material.dart';

typedef NewUiLegacyHostWrapper = Widget Function(Widget child);

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
    this.legacyHostWrapper,
    this.connectionStatusText,
    this.onOpenAccountManagement,
    this.onLogout,
  }) : assert(destinations.length == 5);

  final WidgetBuilder notificationBuilder;
  final List<NewUiAppDestination> destinations;
  final NewUiLegacyHostWrapper? legacyHostWrapper;
  final String? connectionStatusText;
  final VoidCallback? onOpenAccountManagement;
  final VoidCallback? onLogout;

  void _pushLegacy(
    BuildContext context,
    WidgetBuilder builder, {
    bool Function()? onBack,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) {
          final host = LegacyPageHost(
            builder: builder,
            onBack: onBack,
          );
          return legacyHostWrapper?.call(host) ?? host;
        },
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
              connectionStatusText: connectionStatusText,
              onOpenAccountManagement:
                  destination.label == '我的' ? onOpenAccountManagement : null,
              onLogout: destination.label == '我的' ? onLogout : null,
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
