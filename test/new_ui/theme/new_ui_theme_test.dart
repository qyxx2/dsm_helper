import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewUiTheme', () {
    test('maps the persisted legacy theme mode without changing its semantics', () {
      expect(NewUiTheme.resolveMode(0), ThemeMode.light);
      expect(NewUiTheme.resolveMode(1), ThemeMode.dark);
      expect(NewUiTheme.resolveMode(2), ThemeMode.system);
    });

    test('light theme uses the frozen Material 3 foundation tokens', () {
      final theme = NewUiTheme.light();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, const Color(0xFF00A6FF));
      expect(theme.colorScheme.onPrimary, const Color(0xFF001E2B));
      expect(theme.colorScheme.surface, const Color(0xFFF6F9FB));
      expect(theme.colorScheme.surfaceContainer, const Color(0xFFEAF1F5));
      expect(theme.colorScheme.onSurface, const Color(0xFF172126));
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF6F9FB));
      expect(theme.appBarTheme.centerTitle, isFalse);
      expect(theme.appBarTheme.toolbarHeight, 56);
      expect(theme.navigationBarTheme.height, 72);
      expect(theme.textTheme.bodyMedium?.fontSize, 14);
    });

    test('dark theme uses the frozen low-saturation grey-blue surfaces', () {
      final theme = NewUiTheme.dark();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, const Color(0xFF00A6FF));
      expect(theme.colorScheme.surface, const Color(0xFF0F1418));
      expect(theme.colorScheme.surfaceContainerLow, const Color(0xFF151B20));
      expect(theme.colorScheme.surfaceContainerHighest, const Color(0xFF28343C));
      expect(theme.colorScheme.onSurface, const Color(0xFFE5EBEF));
    });
  });
}
