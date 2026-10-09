import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_shortcuts.dart';
import 'package:dsm_helper/new_ui/dashboard/widgets/shortcut_section.dart';
import 'package:dsm_helper/new_ui/legacy/legacy_page_host.dart';
import 'package:dsm_helper/new_ui/shell/new_ui_shell.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:dsm_helper/pages/control_panel/control_panel.dart';
import 'package:dsm_helper/providers/system_info_provider.dart';
import 'package:dsm_helper/themes/light.dart' as legacy;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('emitted real legacy destination uses isolated host, Back restores same shell and other tab',
      (tester) async {
    final item = const OverviewShortcutCatalog().build(
      InitDataModel(userSettings: UserSettings(desktop: Desktop(
        shortcutItems: [ShortcutItems(className: 'SYNO.SDS.AdminCenter.Application')],
        validAppviewOrder: ['SYNO.SDS.AdminCenter.Application'],
      ))),
    ).single;

    Widget tab(String label) => Scaffold(
      body: Column(children: [
        Text('root-$label'),
        Builder(builder: (context) => ElevatedButton(
          key: Key('push-$label'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => Scaffold(body: Text('child-$label')),
            ),
          ),
          child: const Text('open child'),
        )),
      ]),
    );

    final shell = NewUiShell(destinations: [
      NewUiShellDestination.test(
        label: '概览',
        root: (context) => Scaffold(body: ShortcutSection(
          shortcuts: [item],
          onOpenShortcut: (selected) {
            expect(selected, same(item));
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute<void>(
                builder: (_) => LegacyPageHost(builder: selected.legacyBuilder),
              ),
            );
          },
        )),
      ),
      NewUiShellDestination.test(label: '文件', root: (_) => tab('files')),
      NewUiShellDestination.test(label: '应用', root: (_) => tab('apps')),
      NewUiShellDestination.test(label: '任务', root: (_) => tab('tasks')),
      NewUiShellDestination.test(label: '我的', root: (_) => tab('me')),
    ]);

    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => SystemInfoProvider(),
      child: MaterialApp(theme: NewUiTheme.light(), home: shell),
    ));

    await tester.tap(find.text('文件'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('push-files')));
    await tester.pumpAndSettle();
    expect(find.text('child-files'), findsOneWidget);

    await tester.tap(find.text('概览'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('overview-shortcut-0:SYNO.SDS.AdminCenter.Application')));
    await tester.pumpAndSettle();

    expect(find.byType(ControlPanel), findsOneWidget);
    final legacyContext = tester.element(find.byType(ControlPanel));
    expect(Theme.of(legacyContext).colorScheme.primary,
        legacy.lightTheme.colorScheme.primary);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ControlPanel), findsNothing);
    expect(find.byKey(const Key('overview-shortcuts')), findsOneWidget);

    await tester.tap(find.text('文件'));
    await tester.pumpAndSettle();
    expect(find.text('child-files'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 30)));
}
