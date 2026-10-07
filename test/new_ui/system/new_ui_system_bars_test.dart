import 'package:dsm_helper/new_ui/system/new_ui_system_bars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('light surface uses dark system icons with transparent bars', () {
    final style = NewUiSystemBars.forBrightness(Brightness.light);

    expect(style.statusBarColor, Colors.transparent);
    expect(style.systemNavigationBarColor, Colors.transparent);
    expect(style.statusBarIconBrightness, Brightness.dark);
    expect(style.systemNavigationBarIconBrightness, Brightness.dark);
  });

  test('dark surface uses light system icons with transparent bars', () {
    final style = NewUiSystemBars.forBrightness(Brightness.dark);

    expect(style.statusBarColor, Colors.transparent);
    expect(style.systemNavigationBarColor, Colors.transparent);
    expect(style.statusBarIconBrightness, Brightness.light);
    expect(style.systemNavigationBarIconBrightness, Brightness.light);
  });
}
