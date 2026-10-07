import 'package:dsm_helper/new_ui/legacy/legacy_page_host.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:dsm_helper/themes/light.dart' as legacy;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('legacy host scopes legacy ThemeData without bleeding into the shell', (tester) async {
    late ThemeData shellTheme;
    late ThemeData hostedTheme;

    await tester.pumpWidget(
      MaterialApp(
        theme: NewUiTheme.light(),
        home: Builder(
          builder: (context) {
            shellTheme = Theme.of(context);
            return LegacyPageHost(
              builder: (context) {
                hostedTheme = Theme.of(context);
                return const Scaffold(body: Text('legacy'));
              },
            );
          },
        ),
      ),
    );

    expect(shellTheme.useMaterial3, isTrue);
    expect(shellTheme.colorScheme.primary, const Color(0xFF00A6FF));
    expect(hostedTheme.useMaterial3, legacy.lightTheme.useMaterial3);
    expect(hostedTheme.extension, isNotNull);
    expect(hostedTheme.colorScheme.primary, legacy.lightTheme.colorScheme.primary);
    expect(shellTheme.colorScheme.primary, const Color(0xFF00A6FF));
  });
}
