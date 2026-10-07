import 'package:dsm_helper/new_ui/legacy/legacy_page_host.dart';
import 'package:dsm_helper/new_ui/shell/new_ui_shell.dart';
import 'package:dsm_helper/new_ui/shell/primary_destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _tabRoot(PrimaryDestination destination) {
  return Scaffold(
    appBar: AppBar(title: Text('root-${destination.name}')),
    body: Center(
      child: FilledButton(
        key: ValueKey('push-${destination.name}'),
        onPressed: () {
          Navigator.of(
            NewUiShell.navigatorContextFor(destination)!,
          ).push(
            MaterialPageRoute<void>(
              builder: (_) => Scaffold(
                appBar: AppBar(title: Text('detail-${destination.name}')),
                body: Text('detail-body-${destination.name}'),
              ),
            ),
          );
        },
        child: const Text('push'),
      ),
    ),
  );
}

void main() {
  testWidgets('primary tabs keep independent navigation stacks', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewUiShell(
          rootBuilders: {
            for (final destination in PrimaryDestination.values)
              destination: (_) => _tabRoot(destination),
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('push-overview')));
    await tester.pumpAndSettle();
    expect(find.text('detail-overview'), findsOneWidget);

    await tester.tap(find.text('文件'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('push-files')));
    await tester.pumpAndSettle();
    expect(find.text('detail-files'), findsOneWidget);

    await tester.tap(find.text('概览'));
    await tester.pumpAndSettle();
    expect(find.text('detail-overview'), findsOneWidget);
    expect(find.text('detail-files'), findsNothing);

    await tester.tap(find.text('文件'));
    await tester.pumpAndSettle();
    expect(find.text('detail-files'), findsOneWidget);
  });

  testWidgets('Back pops only the active tab stack', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewUiShell(
          rootBuilders: {
            for (final destination in PrimaryDestination.values)
              destination: (_) => _tabRoot(destination),
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('push-overview')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('文件'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('push-files')));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('root-files'), findsOneWidget);

    await tester.tap(find.text('概览'));
    await tester.pumpAndSettle();
    expect(find.text('detail-overview'), findsOneWidget);
  });

  testWidgets('theme rebuild preserves the current nested route', (tester) async {
    final brightness = ValueNotifier(Brightness.light);
    addTearDown(brightness.dispose);

    await tester.pumpWidget(
      ValueListenableBuilder<Brightness>(
        valueListenable: brightness,
        builder: (_, value, __) {
          return MaterialApp(
            theme: ThemeData(brightness: value),
            home: NewUiShell(
              rootBuilders: {
                for (final destination in PrimaryDestination.values)
                  destination: (_) => _tabRoot(destination),
              },
            ),
          );
        },
      ),
    );

    await tester.tap(find.byKey(const ValueKey('push-overview')));
    await tester.pumpAndSettle();
    expect(find.text('detail-overview'), findsOneWidget);

    brightness.value = Brightness.dark;
    await tester.pumpAndSettle();

    expect(find.text('detail-overview'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('detail-body-overview'))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('global notification entry works from every primary root',
      (tester) async {
    var opens = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: NewUiShell(
          onOpenNotifications: (_) async {
            opens += 1;
          },
        ),
      ),
    );

    for (final destination in PrimaryDestination.values) {
      await tester.tap(find.text(destination.label));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('new-ui-notifications')));
      await tester.pumpAndSettle();
    }

    expect(opens, PrimaryDestination.values.length);
  });

  testWidgets('legacy handoff replaces the root AppBar without removing shell nav',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewUiShell(
          rootBuilders: {
            PrimaryDestination.overview: (context) => Scaffold(
                  appBar: AppBar(title: const Text('new-root-appbar')),
                  body: FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => LegacyPageHost(
                            child: Scaffold(
                              appBar: AppBar(title: const Text('legacy-appbar')),
                              body: const Text('legacy-body'),
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text('open-legacy'),
                  ),
                ),
          },
        ),
      ),
    );

    await tester.tap(find.text('open-legacy'));
    await tester.pumpAndSettle();

    expect(find.text('legacy-appbar'), findsOneWidget);
    expect(find.text('new-root-appbar'), findsNothing);
    expect(find.text('概览'), findsOneWidget);
  });
}
