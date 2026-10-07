import 'dart:io';

import 'package:dsm_helper/new_ui/intents/external_intent.dart';
import 'package:dsm_helper/new_ui/legacy/legacy_destinations.dart';
import 'package:dsm_helper/new_ui/lifecycle/launch_auth_gate.dart';
import 'package:dsm_helper/new_ui/navigation/root_back_policy.dart';
import 'package:dsm_helper/new_ui/shell/primary_destination.dart';
import 'package:dsm_helper/new_ui/shell/primary_root_page.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef PrimaryRootBuilders = Map<PrimaryDestination, WidgetBuilder>;

class NewUiShell extends StatefulWidget {
  const NewUiShell({
    this.contextLabel,
    this.rootBuilders,
    this.onOpenNotifications,
    this.launchAuthEnabled,
    this.launchAuthBuilder,
    this.externalIntentSource,
    this.onExternalIntent,
    this.onExitRequested,
    this.onExitHint,
    super.key,
  });

  final String? contextLabel;
  final PrimaryRootBuilders? rootBuilders;
  final Future<void> Function(BuildContext context)? onOpenNotifications;
  final bool Function()? launchAuthEnabled;
  final WidgetBuilder? launchAuthBuilder;
  final ExternalIntentSource? externalIntentSource;
  final Future<void> Function(ExternalIntentPayload payload)? onExternalIntent;
  final Future<void> Function()? onExitRequested;
  final void Function(String message)? onExitHint;

  @override
  State<NewUiShell> createState() => _NewUiShellState();
}

class _NewUiShellState extends State<NewUiShell>
    with WidgetsBindingObserver {
  final Map<PrimaryDestination, GlobalKey<NavigatorState>> _navigatorKeys = {
    for (final destination in PrimaryDestination.values)
      destination: GlobalKey<NavigatorState>(),
  };
  final RootBackPolicy _backPolicy = RootBackPolicy();

  PrimaryDestination _currentDestination = PrimaryDestination.overview;
  ExternalIntentController? _intentController;
  bool _authGateVisible = false;

  GlobalKey<NavigatorState> get _currentNavigatorKey =>
      _navigatorKeys[_currentDestination]!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startExternalIntents();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _intentController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _showLaunchAuthGateIfNeeded();
    }
  }

  Future<void> _startExternalIntents() async {
    final source = widget.externalIntentSource ?? _platformIntentSource();
    if (source == null || !mounted) {
      return;
    }

    _intentController = ExternalIntentController(
      source: source,
      onIntent: widget.onExternalIntent ?? _openExternalIntent,
    );
    await _intentController!.start();
  }

  ExternalIntentSource? _platformIntentSource() {
    if (kIsWeb) {
      return null;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      return const FlutterSharingIntentSource();
    }
    return null;
  }

  Future<void> _openExternalIntent(ExternalIntentPayload payload) async {
    final context = _currentNavigatorKey.currentContext;
    if (context == null || !mounted) {
      return;
    }
    await LegacyDestinations.openExternalIntent(context, payload);
  }

  void _showLaunchAuthGateIfNeeded() {
    final enabled = widget.launchAuthEnabled?.call() ?? LaunchAuthGate.isEnabled();
    if (!enabled || _authGateVisible) {
      return;
    }

    final navigator = _currentNavigatorKey.currentState;
    final builder = widget.launchAuthBuilder ?? LaunchAuthGate.build;
    if (navigator == null) {
      return;
    }

    _authGateVisible = true;
    navigator
        .push<void>(
          MaterialPageRoute<void>(
            builder: builder,
            settings: const RouteSettings(name: 'new_ui_launch_auth_gate'),
          ),
        )
        .whenComplete(() {
          if (mounted) {
            _authGateVisible = false;
          }
        });
  }

  Future<void> _handleBack() async {
    final navigator = _currentNavigatorKey.currentState;
    if (navigator != null && await navigator.maybePop()) {
      return;
    }

    switch (_backPolicy.register(DateTime.now())) {
      case RootBackDecision.showExitHint:
        final showHint = widget.onExitHint ?? Utils.toast;
        showHint('再按一次退出${Utils.appName}');
      case RootBackDecision.exitApp:
        final exit = widget.onExitRequested ?? SystemNavigator.pop;
        await exit();
    }
  }

  Future<void> _openNotifications(BuildContext context) async {
    final callback =
        widget.onOpenNotifications ?? LegacyDestinations.openNotifications;
    await callback(context);
  }

  Future<void> _openLegacy(
    BuildContext context,
    PrimaryDestination destination,
  ) async {
    await LegacyDestinations.openPrimary(context, destination);
  }

  Widget _buildRoot(PrimaryDestination destination, BuildContext context) {
    final customBuilder = widget.rootBuilders?[destination];
    if (customBuilder != null) {
      return customBuilder(context);
    }

    return PrimaryRootPage(
      destination: destination,
      contextLabel: widget.contextLabel,
      onOpenNotifications: _openNotifications,
      onOpenLegacy: (context) => _openLegacy(context, destination),
    );
  }

  Widget _buildNavigator(PrimaryDestination destination) {
    return Navigator(
      key: _navigatorKeys[destination],
      onGenerateRoute: (settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => _buildRoot(destination, context),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final newUiTheme =
        brightness == Brightness.dark ? NewUiTheme.dark() : NewUiTheme.light();

    return Theme(
      data: newUiTheme,
      child: PopScope<Object?>(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            _handleBack();
          }
        },
        child: Scaffold(
          body: IndexedStack(
            index: _currentDestination.index,
            children: [
              for (final destination in PrimaryDestination.values)
                _buildNavigator(destination),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentDestination.index,
            onDestinationSelected: (index) {
              setState(() {
                _currentDestination = PrimaryDestination.values[index];
              });
            },
            destinations: [
              for (final destination in PrimaryDestination.values)
                NavigationDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: destination.label,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
