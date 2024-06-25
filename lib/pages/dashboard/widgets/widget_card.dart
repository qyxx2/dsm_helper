import 'package:dsm_helper/themes/app_theme.dart';
import 'package:flutter/material.dart';

class WidgetCard extends StatelessWidget {
  final Widget? icon;

  final String? title;

  final double? titleFontSize;

  final Widget? body;

  final Function()? onTap;

  final EdgeInsets? padding;

  final EdgeInsets? bodyPadding;

  final Color? bodyColor;

  final BoxDecoration? boxDecoration;

  const WidgetCard({this.icon, this.title, this.titleFontSize, this.body, this.bodyColor, this.onTap, this.padding, this.bodyPadding, this.boxDecoration, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(top: 14),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16),
        decoration: boxDecoration,
        child: Column(
          children: [
            if (icon != null || title != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: TextStyle(fontSize: titleFontSize ??  18, fontWeight: FontWeight.w600),
                      ),
                    if (icon != null) icon!,
                  ],
                ),
              ),
            if (body != null)
              Container(
                width: double.infinity,
                padding: bodyPadding ?? EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: bodyColor ?? AppTheme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: body,
              ),
          ],
        ),
      ),
    );
  }
}
