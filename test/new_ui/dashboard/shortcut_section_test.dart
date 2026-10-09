import 'package:dsm_helper/new_ui/dashboard/overview_shortcuts.dart';
import 'package:dsm_helper/new_ui/dashboard/widgets/shortcut_section.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

OverviewShortcut entry(int i) => OverviewShortcut(
  id: 'shortcut-$i',
  label: '快捷入口 $i',
  assetPath: 'assets/applications/docker.png',
  routeName: '/shortcut-$i',
  legacyBuilder: (_) => const Scaffold(body: Text('legacy')),
);

void main() {
  testWidgets('fixed shortcut region stays visible with no eligible DSM shortcuts',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: NewUiTheme.light(),
      home: const Scaffold(body: ShortcutSection(shortcuts: [])),
    ));

    expect(find.byKey(const Key('overview-shortcuts')), findsOneWidget);
    expect(find.text('快捷方式'), findsOneWidget);
    expect(find.textContaining('暂无可用快捷方式'), findsOneWidget);
  });

  testWidgets('one portrait row preserves order and caps visible items at four',
      (tester) async {
    final entries = List.generate(5, entry);
    await tester.pumpWidget(MaterialApp(
      theme: NewUiTheme.light(),
      home: Scaffold(body: ShortcutSection(shortcuts: entries)),
    ));
    expect(find.byKey(const Key('overview-shortcuts')), findsOneWidget);
    for (var i = 0; i < 4; i++) {
      expect(find.text('快捷入口 $i'), findsOneWidget);
    }
    expect(find.text('快捷入口 4'), findsNothing);
    final first = tester.getTopLeft(find.byKey(const Key('overview-shortcut-shortcut-0')));
    final second = tester.getTopLeft(find.byKey(const Key('overview-shortcut-shortcut-1')));
    final fourth = tester.getTopLeft(find.byKey(const Key('overview-shortcut-shortcut-3')));
    expect(first.dy, second.dy);
    expect(second.dy, fourth.dy);
    expect(first.dx, lessThan(second.dx));
    expect(second.dx, lessThan(fourth.dx));
  });

  testWidgets('tapping a tile emits the identical destination, never an inferred route',
      (tester) async {
    final entries = [entry(0), entry(1), entry(2)];
    OverviewShortcut? selected;
    await tester.pumpWidget(MaterialApp(
      theme: NewUiTheme.light(),
      home: Scaffold(
        body: ShortcutSection(
          shortcuts: entries,
          onOpenShortcut: (shortcut) => selected = shortcut,
        ),
      ),
    ));

    await tester.tap(find.byKey(const Key('overview-shortcut-shortcut-1')));
    expect(selected, same(entries[1]));
  });

  testWidgets('no callback does not produce phantom navigation', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ShortcutSection(shortcuts: [entry(0)])),
    ));
    await tester.tap(find.byKey(const Key('overview-shortcut-shortcut-0')));
    expect(tester.takeException(), isNull);
  });
}
