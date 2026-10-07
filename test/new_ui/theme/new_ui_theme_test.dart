import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Material 3 themes use the frozen DSM Helper color roles', () {
    final light = NewUiTheme.light();
    final dark = NewUiTheme.dark();

    expect(light.useMaterial3, isTrue);
    expect(light.colorScheme.primary, const Color(0xFF00A6FF));
    expect(light.colorScheme.onPrimary, const Color(0xFF001E2B));
    expect(light.colorScheme.surface, const Color(0xFFF6F9FB));
    expect(light.appBarTheme.centerTitle, isFalse);
    expect(light.navigationBarTheme.height, 72);

    expect(dark.useMaterial3, isTrue);
    expect(dark.brightness, Brightness.dark);
    expect(dark.colorScheme.primary, const Color(0xFF00A6FF));
    expect(dark.colorScheme.surface, const Color(0xFF0F1418));
    expect(dark.appBarTheme.centerTitle, isFalse);
  });

  test('legacy dark mode values map without changing persisted semantics', () {
    expect(NewUiThemeMode.fromLegacyValue(0), ThemeMode.light);
    expect(NewUiThemeMode.fromLegacyValue(1), ThemeMode.dark);
    expect(NewUiThemeMode.fromLegacyValue(2), ThemeMode.system);
    expect(NewUiThemeMode.fromLegacyValue(99), ThemeMode.system);
  });
}
