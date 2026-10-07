import 'package:dsm_helper/themes/dark.dart';
import 'package:dsm_helper/themes/light.dart';
import 'package:flutter/material.dart';

class LegacyPageHost extends StatefulWidget {
  const LegacyPageHost({
    required this.child,
    this.brightness,
    this.onBackAttempt,
    super.key,
  });

  final Widget child;
  final Brightness? brightness;

  /// Return true when the legacy page consumed the Back action internally.
  /// Return false when the host route itself should be popped.
  final Future<bool> Function()? onBackAttempt;

  @override
  State<LegacyPageHost> createState() => _LegacyPageHostState();
}

class _LegacyPageHostState extends State<LegacyPageHost> {
  bool _allowRoutePop = false;
  bool _handlingBack = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBrightness =
        widget.brightness ?? Theme.of(context).brightness;
    final legacyTheme =
        effectiveBrightness == Brightness.dark ? darkTheme : lightTheme;

    final themedChild = Theme(
      data: legacyTheme,
      child: widget.child,
    );

    if (widget.onBackAttempt == null) {
      return themedChild;
    }

    return PopScope(
      canPop: _allowRoutePop,
      onPopInvoked: (didPop) {
        if (!didPop && !_handlingBack) {
          _handleBackAttempt();
        }
      },
      child: themedChild,
    );
  }

  Future<void> _handleBackAttempt() async {
    _handlingBack = true;
    final consumed = await widget.onBackAttempt!();
    if (!mounted) {
      return;
    }

    if (consumed) {
      _handlingBack = false;
      return;
    }

    setState(() {
      _allowRoutePop = true;
    });
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
