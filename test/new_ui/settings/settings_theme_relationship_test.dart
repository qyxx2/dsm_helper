import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/new_ui/settings/settings_page.dart';
import 'package:dsm_helper/new_ui/shell/new_ui_shell.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:dsm_helper/providers/dark_mode.dart';
import 'package:dsm_helper/providers/init_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_util/sp_util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await SpUtil.getInstance();
  });

  for (final choice in [
    (label: '跟随系统', value: 2),
    (label: '浅色', value: 0),
    (label: '深色', value: 1),
  ]) {
    testWidgets('Theme sheet persists ${choice.label} as ${choice.value} without session callbacks',
        (tester) async {
      final initial = InitDataProvider()
        ..setInitData(InitDataModel(
          session: Session(hostname: 'NAS-A', user: 'alice'),
        ));
      final provider = DarkModeProvider(choice.value == 2 ? 0 : 2);
      addTearDown(initial.dispose);
      addTearDown(provider.dispose);
      final events = <String>[];

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<InitDataProvider>.value(value: initial),
            ChangeNotifierProvider<DarkModeProvider>.value(value: provider),
          ],
          child: MaterialApp(
            theme: NewUiTheme.light(),
            home: SettingsPage(
              onOpenNotifications: () => events.add('notifications'),
              onOpenAccountManagement: () => events.add('accounts'),
              onLogout: () => events.add('logout'),
              onOpenUserSettings: () => events.add('user'),
              onOpenHelperSettings: () => events.add('helper'),
              onOpenAbout: () => events.add('about'),
              onOpenLegacySettings: () => events.add('legacy'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('主题模式'));
      await tester.pumpAndSettle();

      final sheet = find.byType(BottomSheet);
      expect(sheet, findsOneWidget);
      final choices = find.descendant(
        of: sheet,
        matching: find.byType(ListTile),
      );
      expect(choices, findsNWidgets(3));
      for (final name in ['跟随系统', '浅色', '深色']) {
        expect(
          find.descendant(of: sheet, matching: find.text(name)),
          findsOneWidget,
        );
      }
      expect(find.text('动态取色'), findsNothing);
      expect(find.text('Dynamic Color'), findsNothing);

      await tester.tap(find.descendant(
        of: sheet,
        matching: find.text(choice.label),
      ));
      await tester.pumpAndSettle();

      expect(provider.darkMode, choice.value);
      expect(SpUtil.getInt('dark_mode'), choice.value);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text('NAS-A'), findsOneWidget);
      expect(events, isEmpty);
    }, timeout: const Timeout(Duration(seconds: 20)));
  }

  testWidgets('Theme change preserves nested My route, active DSM context and persisted mode',
      (tester) async {
    final initData = InitDataProvider()
      ..setInitData(InitDataModel(
        session: Session(hostname: 'NAS-A', user: 'alice'),
      ));
    final mode = DarkModeProvider(0);
    addTearDown(initData.dispose);
    addTearDown(mode.dispose);
    final shellKey = GlobalKey<NewUiShellState>();
    final events = <String>[];

    SettingsPage settingsPage() => SettingsPage(
          onOpenNotifications: () => events.add('notifications'),
          onOpenAccountManagement: () => events.add('accounts'),
          onLogout: () => events.add('logout'),
          onOpenUserSettings: () => events.add('user'),
          onOpenHelperSettings: () => events.add('helper'),
          onOpenAbout: () => events.add('about'),
          onOpenLegacySettings: () => events.add('compatibility'),
        );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<InitDataProvider>.value(value: initData),
          ChangeNotifierProvider<DarkModeProvider>.value(value: mode),
        ],
        child: Consumer<DarkModeProvider>(
          builder: (_, currentMode, __) => MaterialApp(
            theme: NewUiTheme.light(),
            darkTheme: NewUiTheme.dark(),
            themeMode: NewUiThemeMode.fromLegacyValue(currentMode.darkMode),
            home: NewUiShell(
              key: shellKey,
              destinations: [
                for (final label in ['概览', '文件', '应用', '任务'])
                  NewUiShellDestination.test(
                    label: label,
                    root: (_) => Scaffold(body: Text('root-$label')),
                  ),
                NewUiShellDestination.test(
                  label: '我的',
                  root: (tabContext) => Scaffold(
                    body: ElevatedButton(
                      key: const Key('enter-settings'),
                      onPressed: () => Navigator.of(tabContext).push<void>(
                        MaterialPageRoute(builder: (_) => settingsPage()),
                      ),
                      child: const Text('进入设置'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('enter-settings')));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.text('NAS-A'), findsOneWidget);
    expect(shellKey.currentState?.selectedIndex, 4);

    await tester.tap(find.text('主题模式'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
      of: find.byType(BottomSheet),
      matching: find.text('深色'),
    ));
    await tester.pumpAndSettle();

    expect(mode.darkMode, 1);
    expect(SpUtil.getInt('dark_mode'), 1);
    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.byKey(const Key('enter-settings')), findsNothing);
    expect(find.text('NAS-A'), findsOneWidget);
    expect(initData.initData.session?.user, 'alice');
    expect(shellKey.currentState?.selectedIndex, 4);
    expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex, 4);
    expect(Theme.of(tester.element(find.byType(SettingsPage))).brightness,
        Brightness.dark);
    expect(events, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    final restored = DarkModeProvider(SpUtil.getInt('dark_mode') ?? 2);
    addTearDown(restored.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<InitDataProvider>.value(value: initData),
          ChangeNotifierProvider<DarkModeProvider>.value(value: restored),
        ],
        child: MaterialApp(
          theme: NewUiTheme.dark(),
          home: settingsPage(),
        ),
      ),
    );
    await tester.pump();

    expect(restored.darkMode, 1);
    expect(find.text('深色'), findsOneWidget);
    expect(find.text('NAS-A'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 40)));

}
