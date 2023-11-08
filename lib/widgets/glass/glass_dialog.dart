import 'dart:ui';
import 'package:flutter/material.dart';

const EdgeInsets _defaultInsetPadding = EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0);

Future<T?> showGlassDialog<T>({
  required BuildContext context,
  bool barrierDismissible = true,
  required WidgetBuilder builder,
  bool useRootNavigator = true,
  ThemeData? theme,
}) {
  final ThemeData themeData = Theme.of(context);
  return showGeneralDialog(
    context: context,
    useRootNavigator: useRootNavigator,
    pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
      final Widget pageChild = Builder(builder: builder);
      return Builder(builder: (BuildContext context) {
        return Theme(
          data: theme ?? themeData,
          child: BackdropFilter(filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5), child: pageChild),
        );
      });
    },
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black38, // 自定义遮罩颜色
    transitionDuration: const Duration(milliseconds: 150),
    transitionBuilder: _buildMaterialDialogTransitions,
  );
}

Widget _buildMaterialDialogTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
  final Animatable<double> dialogScaleTween = Tween<double>(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.linearToEaseOut));
  final CurvedAnimation fadeAnimation = CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOut,
  );
  if (animation.status == AnimationStatus.reverse) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: child,
    );
  }
  return FadeTransition(
    opacity: fadeAnimation,
    child: ScaleTransition(
      scale: animation.drive(dialogScaleTween),
      child: child,
    ),
  );
}
