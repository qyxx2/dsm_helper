import 'dart:async';

import 'package:flutter/material.dart';

typedef LaunchAuthCheck = Future<bool> Function();

class LaunchAuthGate extends StatefulWidget {
  const LaunchAuthGate({
    super.key,
    required this.shouldGate,
    required this.gateBuilder,
    required this.child,
    this.gateInitially = false,
  });

  final LaunchAuthCheck shouldGate;
  final WidgetBuilder gateBuilder;
  final Widget child;
  final bool gateInitially;

  @override
  State<LaunchAuthGate> createState() => _LaunchAuthGateState();
}

class _LaunchAuthGateState extends State<LaunchAuthGate>
    with WidgetsBindingObserver {
  bool _gateVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.gateInitially) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_showGateIfRequired(force: true));
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      unawaited(_showGateIfRequired());
    }
  }

  Future<void> _showGateIfRequired({bool force = false}) async {
    if (_gateVisible || !mounted) {
      return;
    }

    final shouldShow = force || await widget.shouldGate();
    if (!shouldShow || !mounted) {
      return;
    }

    _gateVisible = true;
    try {
      await Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: widget.gateBuilder,
        ),
      );
    } finally {
      _gateVisible = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
