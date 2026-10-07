import 'package:dsm_helper/new_ui/lifecycle/launch_auth_gate.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('background auth gate covers and then reveals the exact prior nested route', (tester) async {
    var enabled = true;

    await tester.pumpWidget(
      MaterialApp(
        theme: NewUiTheme.light(),
        home: LaunchAuthGate(
          shouldGate: () async => enabled,
          gateBuilder: (context) => Scaffold(
            body: ElevatedButton(
              key: const Key('unlock'),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('unlock'),
            ),
          ),
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                key: const Key('push-child'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: Text('nested-route')),
                  ),
                ),
                child: const Text('push'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('push-child')));
    await tester.pumpAndSettle();
    expect(find.text('nested-route'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('unlock')), findsOneWidget);

    await tester.tap(find.byKey(const Key('unlock')));
    await tester.pumpAndSettle();
    expect(find.text('nested-route'), findsOneWidget);

    enabled = false;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('unlock')), findsNothing);
    expect(find.text('nested-route'), findsOneWidget);
  });
}
