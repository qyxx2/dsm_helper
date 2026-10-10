import 'package:dsm_helper/models/Syno/Core/Notify.dart';
import 'package:dsm_helper/models/Syno/Core/System.dart';
import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';
import 'package:dsm_helper/new_ui/app/dsm_new_ui_shell.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_controller.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_data_source.dart';
import 'package:dsm_helper/new_ui/legacy/legacy_shared_bootstrap.dart';
import 'package:dsm_helper/new_ui/notifications/legacy_notification_entry.dart';
import 'package:dsm_helper/pages/user/setting.dart';
import 'package:dsm_helper/providers/setting_provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_util/sp_util.dart';
import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/new_ui/legacy/legacy_page_host.dart';
import 'package:dsm_helper/new_ui/settings/settings_page.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:dsm_helper/providers/dark_mode.dart';
import 'package:dsm_helper/providers/init_data_provider.dart';
import 'package:dsm_helper/themes/dark.dart' as legacy_dark;
import 'package:dsm_helper/themes/light.dart' as legacy_light;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await SpUtil.getInstance();
  });

  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets('Settings legacy children return to My without account transitions in $brightness',
        (tester) async {
      final initData = InitDataProvider()
        ..setInitData(InitDataModel(
          session: Session(hostname: 'NAS-A', user: 'alice'),
        ));
      final mode = DarkModeProvider(brightness == Brightness.dark ? 1 : 0);
      addTearDown(initData.dispose);
      addTearDown(mode.dispose);
      var accountCalls = 0;
      var logoutCalls = 0;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<InitDataProvider>.value(value: initData),
            ChangeNotifierProvider<DarkModeProvider>.value(value: mode),
          ],
          child: MaterialApp(
            theme: brightness == Brightness.dark
                ? NewUiTheme.dark()
                : NewUiTheme.light(),
            home: Builder(
              builder: (rootContext) {
                void openChild(String label) {
                  Navigator.of(rootContext).push<void>(
                    MaterialPageRoute(
                      builder: (_) => LegacyPageHost(
                        builder: (legacyContext) => Scaffold(
                          appBar: AppBar(title: Text('legacy-$label')),
                          body: Text(
                            'child-$label:${legacyContext.read<InitDataProvider>().initData.session?.hostname}',
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return SettingsPage(
                  onOpenNotifications: () {},
                  onOpenAccountManagement: () => accountCalls++,
                  onLogout: () => logoutCalls++,
                  onOpenUserSettings: () => openChild('user'),
                  onOpenHelperSettings: () => openChild('helper'),
                  onOpenAbout: () => openChild('about'),
                  onOpenLegacySettings: () => openChild('compatibility'),
                );
              },
            ),
          ),
        ),
      );

      for (final entry in [
        ('个人设置', 'user'),
        ('助手设置', 'helper'),
        ('关于', 'about'),
        ('更多现有设置', 'compatibility'),
      ]) {
        final row = find.widgetWithText(ListTile, entry.$1);
        await tester.scrollUntilVisible(
          row, 120, scrollable: find.byType(Scrollable).first,
        );
        await tester.pump();
        await tester.tap(row);
        await tester.pumpAndSettle();

        final childLabel = 'child-${entry.$2}:NAS-A';
        expect(find.text(childLabel), findsOneWidget);
        expect(find.text('legacy-${entry.$2}'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        final theme = Theme.of(tester.element(find.text(childLabel)));
        final expectedTheme = brightness == Brightness.dark
            ? legacy_dark.darkTheme
            : legacy_light.lightTheme;
        expect(theme.colorScheme.primary, expectedTheme.colorScheme.primary);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text(childLabel), findsNothing);
        expect(find.text('我的'), findsOneWidget);
        expect(accountCalls, 0);
        expect(logoutCalls, 0);
      }
    }, timeout: const Timeout(Duration(seconds: 50)));
  }
  testWidgets(
    '5.4 production My keeps Task4 callbacks, theme, real detail and notifications in the same context',
    (tester) async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const sharing = MethodChannel('flutter_sharing_intent');
      const sharingEvents = MethodChannel('flutter_sharing_intent/events-sharing');
      messenger.setMockMethodCallHandler(
        sharing,
        (call) async => call.method == 'getInitialSharing' ? '[]' : null,
      );
      messenger.setMockMethodCallHandler(sharingEvents, (_) async => null);

      final mode = DarkModeProvider(0);
      var manageCalls = 0;
      var logoutCalls = 0;
      final initData = InitDataModel.fromJson({
        'Session': {
          'majorversion': '7',
          'hostname': 'NAS-SET',
          'user': 'alice',
        },
        'UserSettings': {
          'Desktop': {'valid_appview_order': <String>[]},
        },
      });

      try {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<DarkModeProvider>.value(value: mode),
              ChangeNotifierProvider(
                create: (_) => SettingProvider(refreshDuration: 3600),
              ),
            ],
            child: MaterialApp(
              home: DsmNewUiShell(
                contextId: 'nas/settings',
                legacyBootstrap: LegacySharedBootstrap(
                  loadInitData: () async => initData,
                ),
                onManageAccounts: () => manageCalls++,
                onLogout: () => logoutCalls++,
                overviewControllerFactory: (interval) => OverviewController(
                  refreshInterval: interval,
                  dataSource: OverviewDataSource(
                    loadSystem: () async => System(),
                    loadUtilization: () async => Utilization(),
                    loadStorage: () async => Storage(),
                    loadNotifications: () async => DsmNotify(),
                    loadCurrentConnections: () async => null,
                    loadTaskScheduler: () async => null,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('我的'));
        await tester.pumpAndSettle();
        expect(find.byType(SettingsPage), findsOneWidget);
        expect(find.text('NAS-SET'), findsOneWidget);
        expect(find.text('alice'), findsOneWidget);
        expect(tester.widget<NavigationBar>(find.byType(NavigationBar))
            .selectedIndex, 4);
        expect(find.text('关机'), findsNothing);
        expect(find.text('重启'), findsNothing);

        await tester.tap(find.text('服务器与账号管理'));
        await tester.pump();
        await tester.tap(find.text('退出登录'));
        await tester.pump();
        expect(manageCalls, 1);
        expect(logoutCalls, 1);
        expect(find.byType(SettingsPage), findsOneWidget);

        await tester.tap(find.text('主题模式'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('深色').last);
        await tester.pumpAndSettle();
        expect(mode.darkMode, 1);
        expect(SpUtil.getInt('dark_mode'), 1);
        expect(find.byType(SettingsPage), findsOneWidget);
        expect(find.text('NAS-SET'), findsOneWidget);
        expect(manageCalls, 1);
        expect(logoutCalls, 1);

        await tester.tap(find.byKey(const Key('new-ui-notifications')));
        await tester.pumpAndSettle();
        expect(find.byType(LegacyPageHost), findsOneWidget);
        expect(find.byType(LegacyNotificationEntry), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(SettingsPage), findsOneWidget);

        await tester.tap(find.text('个人设置'));
        // NormalUser.get is an unrelated live DSM request; inspect only the
        // route handoff before its transport completes.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        expect(find.byType(LegacyPageHost), findsOneWidget);
        expect(find.byType(UserSetting), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(SettingsPage), findsOneWidget);
        expect(find.text('NAS-SET'), findsOneWidget);

        await tester.tap(find.text('应用').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('我的').last);
        await tester.pumpAndSettle();
        expect(find.byType(SettingsPage), findsOneWidget);
        expect(mode.darkMode, 1);
        expect(manageCalls, 1);
        expect(logoutCalls, 1);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        mode.dispose();
        messenger.setMockMethodCallHandler(sharing, null);
        messenger.setMockMethodCallHandler(sharingEvents, null);
      }
    },
    timeout: const Timeout(Duration(seconds: 50)),
  );

}
