import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/new_ui/settings/settings_page.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:dsm_helper/providers/dark_mode.dart';
import 'package:dsm_helper/providers/init_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Future<void> _pumpSettings(
  WidgetTester tester, {
  Session? session,
  String? status,
  VoidCallback? onAccounts,
  VoidCallback? onLogout,
  VoidCallback? onUser,
  VoidCallback? onHelper,
  VoidCallback? onAbout,
  VoidCallback? onCompatibility,
}) async {
  final initData = InitDataProvider()
    ..setInitData(InitDataModel(session: session));
  final mode = DarkModeProvider(2);
  addTearDown(initData.dispose);
  addTearDown(mode.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<InitDataProvider>.value(value: initData),
        ChangeNotifierProvider<DarkModeProvider>.value(value: mode),
      ],
      child: MaterialApp(
        theme: NewUiTheme.light(),
        home: SettingsPage(
          onOpenNotifications: () {},
          onOpenAccountManagement: onAccounts ?? () {},
          onLogout: onLogout ?? () {},
          onOpenUserSettings: onUser ?? () {},
          onOpenHelperSettings: onHelper ?? () {},
          onOpenAbout: onAbout ?? () {},
          onOpenLegacySettings: onCompatibility ?? () {},
          connectionStatusText: status,
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _tapRow(WidgetTester tester, String label) async {
  final row = find.widgetWithText(ListTile, label);
  await tester.scrollUntilVisible(
    row,
    120,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump();
  await tester.tap(row);
  await tester.pump();
}

void main() {
  testWidgets('Settings is a continuous ordered root with current DSM metadata',
      (tester) async {
    await _pumpSettings(
      tester,
      session: Session(hostname: 'NAS-01', user: 'alice'),
      status: '离线',
    );

    expect(find.text('我的'), findsOneWidget);
    expect(find.text('当前设备与账号'), findsOneWidget);
    expect(find.text('外观'), findsOneWidget);
    expect(find.text('应用设置'), findsOneWidget);
    expect(find.text('NAS-01'), findsOneWidget);
    expect(find.text('alice'), findsOneWidget);
    expect(find.text('离线'), findsOneWidget);
    expect(find.byType(Card), findsNothing);
    expect(find.text('关机'), findsNothing);
    expect(find.text('重启'), findsNothing);
    // ListView lazily builds the About section only after it scrolls into view.
    await tester.scrollUntilVisible(
      find.widgetWithText(ListTile, '关于'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(find.widgetWithText(ListTile, '关于'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('Sparse context still renders settings and does not invent NAS metadata',
      (tester) async {
    await _pumpSettings(tester, status: '连接异常');

    expect(find.text('当前设备与账号'), findsOneWidget);
    expect(find.text('主题模式'), findsOneWidget);
    expect(find.text('NAS-01'), findsNothing);
    expect(find.text('alice'), findsNothing);
    expect(find.text('连接异常'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('Every Settings entry delegates exactly once to its supplied callback',
      (tester) async {
    final calls = <String>[];
    await _pumpSettings(
      tester,
      onAccounts: () => calls.add('accounts'),
      onUser: () => calls.add('user'),
      onLogout: () => calls.add('logout'),
      onHelper: () => calls.add('helper'),
      onCompatibility: () => calls.add('compatibility'),
      onAbout: () => calls.add('about'),
    );

    for (final pair in [
      ('服务器与账号管理', 'accounts'),
      ('个人设置', 'user'),
      ('退出登录', 'logout'),
      ('助手设置', 'helper'),
      ('更多现有设置', 'compatibility'),
      ('关于', 'about'),
    ]) {
      await _tapRow(tester, pair.$1);
      expect(calls.last, pair.$2);
    }
    expect(calls, [
      'accounts',
      'user',
      'logout',
      'helper',
      'compatibility',
      'about',
    ]);
  }, timeout: const Timeout(Duration(seconds: 20)));
}
