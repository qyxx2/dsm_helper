import 'package:dsm_helper/new_ui/legacy/legacy_page_host.dart';
import 'package:dsm_helper/new_ui/shell/new_ui_primary_page.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('pushed legacy fallback replaces the New UI AppBar instead of stacking a second one', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NewUiTheme.light(),
        home: Builder(
          builder: (context) => NewUiPrimaryPage(
            title: '应用',
            onOpenNotifications: () {},
            onOpenLegacyFeature: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LegacyPageHost(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('legacy-app')),
                      body: const Text('legacy-body'),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-legacy-feature')));
    await tester.pumpAndSettle();

    expect(find.text('legacy-app'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('应用'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('应用'), findsOneWidget);
  });

  testWidgets('legacy Back delegate can consume Back before the host exits', (tester) async {
    var consume = true;
    var delegated = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: NewUiTheme.light(),
        home: Builder(
          builder: (context) => ElevatedButton(
            key: const Key('open'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => LegacyPageHost(
                  onBack: () {
                    delegated++;
                    if (consume) {
                      consume = false;
                      return true;
                    }
                    return false;
                  },
                  builder: (_) => const Scaffold(body: Text('legacy-root')),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('legacy-root'), findsOneWidget);
    expect(delegated, 1);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('legacy-root'), findsNothing);
    expect(delegated, 2);
  });
}
