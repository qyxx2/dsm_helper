import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'shell_back_policy.dart';

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
  int _currentIndex = 0;
  late final List<GlobalKey<NavigatorState>> _navigatorKeys =
      List.generate(widget.destinations.length, (_) => GlobalKey<NavigatorState>());

  int get currentIndex => _currentIndex;

  Future<bool> popCurrentTab() async {
    final navigator = _navigatorKeys[_currentIndex].currentState;
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
        _currentIndex = 0;
      });
    }
  }

  Future<void> _handleBack() async {
    final navigator = _navigatorKeys[_currentIndex].currentState;
    final action = ShellBackPolicy.resolve(
      currentTabCanPop: navigator?.canPop() ?? false,
    );

    if (action == ShellBackAction.popCurrentTab) {
      navigator?.pop();
      return;
    }

    await SystemNavigator.pop();
  }

  Route<dynamic>? _routeFor(int index, RouteSettings settings) {
    if (settings.name != Navigator.defaultRouteName) {
      return null;
    }
    return MaterialPageRoute<void>(
      settings: settings,
      builder: widget.destinations[index].root,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: List.generate(widget.destinations.length, (index) {
            return Navigator(
              key: _navigatorKeys[index],
              onGenerateRoute: (settings) => _routeFor(index, settings),
            );
          }),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            if (index == _currentIndex) {
              _navigatorKeys[index]
                  .currentState
                  ?.popUntil((route) => route.isFirst);
              return;
            }
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: widget.destinations.map((destination) {
            return NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            );
          }).toList(growable: false),
        ),
      ),
    );
  }
}
