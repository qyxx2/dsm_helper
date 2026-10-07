import 'package:dsm_helper/new_ui/legacy/legacy_page_host.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:dsm_helper/themes/light.dart' as legacy;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('legacy child routes remain inside the legacy theme boundary', (tester) async {
    Color? childPrimary;

    await tester.pumpWidget(
      MaterialApp(
        theme: NewUiTheme.light(),
        home: LegacyPageHost(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              key: const Key('push-legacy-child'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) {
                    childPrimary = Theme.of(context).colorScheme.primary;
                    return const Scaffold(body: Text('legacy-child'));
                  },
                ),
              ),
              child: const Text('push'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('push-legacy-child')));
    await tester.pumpAndSettle();

    expect(find.text('legacy-child'), findsOneWidget);
    expect(childPrimary, legacy.lightTheme.colorScheme.primary);
    expect(childPrimary, isNot(NewUiTheme.light().colorScheme.primary));
  });
}
