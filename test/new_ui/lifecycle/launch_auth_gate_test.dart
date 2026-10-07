import 'package:dsm_helper/new_ui/shell/new_ui_shell.dart';
import 'package:dsm_helper/new_ui/shell/primary_destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('resume auth gate reveals the exact prior nested route',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewUiShell(
          launchAuthEnabled: () => true,
          launchAuthBuilder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('unlock-test-gate'),
            ),
          ),
          rootBuilders: {
            PrimaryDestination.overview: (context) => Scaffold(
                  body: FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const Scaffold(
                            body: Text('nested-before-background'),
                          ),
                        ),
                      );
                    },
                    child: const Text('open-nested'),
                  ),
                ),
          },
        ),
      ),
    );

    await tester.tap(find.text('open-nested'));
    await tester.pumpAndSettle();
    expect(find.text('nested-before-background'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('unlock-test-gate'), findsOneWidget);

    await tester.tap(find.text('unlock-test-gate'));
    await tester.pumpAndSettle();

    expect(find.text('nested-before-background'), findsOneWidget);
  });

  testWidgets('disabled launch auth leaves navigation unchanged on resume',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewUiShell(
          launchAuthEnabled: () => false,
          launchAuthBuilder: (_) => const Text('must-not-open'),
          rootBuilders: {
            PrimaryDestination.overview: (_) =>
                const Scaffold(body: Text('overview-stays')),
          },
        ),
      ),
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.text('overview-stays'), findsOneWidget);
    expect(find.text('must-not-open'), findsNothing);
  });
}
