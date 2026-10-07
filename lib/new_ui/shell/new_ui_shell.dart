import 'dart:async';

import 'package:dsm_helper/new_ui/shell/shell_back_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewUiShellDestination {
  const NewUiShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.root,
  });

  factory NewUiShellDestination.test({
    required String label,
    required WidgetBuilder root,
  }) {
    return NewUiShellDestination(
      label: label,
      icon: Icons.circle_outlined,
      selectedIcon: Icons.circle,
      root: root,
    );
  }

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final WidgetBuilder root;
}

class NewUiShell extends StatefulWidget {
  const NewUiShell({
    super.key,
    required this.destinations,
  }) : assert(destinations.length == 5);

  final List<NewUiShellDestination> destinations;

  @override
  State<NewUiShell> createState() => NewUiShellState();
}

class NewUiShellState extends State<NewUiShell> {
  late final List<GlobalKey<NavigatorState>> _navigatorKeys =
      List.generate(widget.destinations.length, (_) => GlobalKey<NavigatorState>());

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  Future<bool> popCurrentTab() async {
    final navigator = _navigatorKeys[_selectedIndex].currentState;
    if (navigator == null || !navigator.canPop()) {
      return false;
    }
    navigator.pop();
    return true;
  }

  Future<void> resetForContextSwitch() async {
    for (final key in _navigatorKeys) {
      key.currentState?.popUntil((route) => route.isFirst);
    }
    if (mounted) {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  Future<void> _handleBack(bool didPop) async {
    if (didPop) {
      return;
    }

    final navigator = _navigatorKeys[_selectedIndex].currentState;
    final action = ShellBackPolicy.resolve(
      currentTabCanPop: navigator?.canPop() ?? false,
    );

    switch (action) {
      case ShellBackAction.popCurrentTab:
        navigator?.pop();
      case ShellBackAction.exitSystem:
        unawaited(SystemNavigator.pop());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: _handleBack,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: List.generate(widget.destinations.length, (index) {
            final destination = widget.destinations[index];
            return Navigator(
              key: _navigatorKeys[index],
              onGenerateRoute: (settings) {
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: destination.root,
                );
              },
            );
          }),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            if (index == _selectedIndex) {
              return;
            }
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: widget.destinations
              .map(
                (destination) => NavigationDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: destination.label,
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}
