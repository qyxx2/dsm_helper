import 'dart:async';

import 'package:drift/native.dart';
import 'package:dsm_helper/apis/dsm_api/dsm_exception.dart';
import 'package:dsm_helper/database/table_extension.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/models/Syno/Api/auth.dart';
import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/models/Syno/Core/Notify.dart';
import 'package:dsm_helper/models/Syno/Core/System.dart';
import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';
import 'package:dsm_helper/new_ui/app/dsm_new_ui_shell.dart';
import 'package:dsm_helper/new_ui/app/modern_ui_root.dart';
import 'package:dsm_helper/new_ui/applications/applications_page.dart';
import 'package:dsm_helper/new_ui/settings/settings_page.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_controller.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_data_source.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_page.dart';
import 'package:dsm_helper/new_ui/legacy/legacy_shared_bootstrap.dart';
import 'package:dsm_helper/new_ui/legacy/legacy_page_host.dart';
import 'package:dsm_helper/new_ui/notifications/legacy_notification_entry.dart';
import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:dsm_helper/new_ui/startup/modern_startup.dart';
import 'package:dsm_helper/pages/control_panel/control_panel.dart';
import 'package:dsm_helper/providers/dark_mode.dart';
import 'package:dsm_helper/providers/setting_provider.dart';
import 'package:dsm_helper/utils/db_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_util/sp_util.dart';

class _SavedSource implements StartupDataSource {
  const _SavedSource(this.context);
  final StartupSavedContext context;

  @override
  Future<StartupSnapshot> load() async => StartupSnapshot(
        hasServers: true,
        launcherSelectionEnabled: false,
        knownServerIds: {context.serverId},
        contexts: [context],
      );
}

OverviewDataSource _source(Future<System?> Function() system,
    {Future<Storage?> Function()? storage}) =>
    OverviewDataSource(
      loadSystem: system,
      loadUtilization: () async => Utilization(),
      loadStorage: storage ?? (() async => Storage()),
      loadNotifications: () async => DsmNotify(),
    );

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await SpUtil.getInstance();
  });

  test('two 119 sources invalidate once, while transport and non-119 errors do not', () async {
    var reauth = 0;
    final invalid = OverviewController(
      dataSource: _source(
        () async => throw const DsmException(119),
        storage: () async => throw const DsmException(119),
      ),
      refreshInterval: const Duration(seconds: 10),
      onAuthInvalidated: (_) => reauth++,
    );
    await invalid.loadInitial();
    await invalid.refresh();
    expect(reauth, 1);
    invalid.dispose();

    final other = OverviewController(
      dataSource: _source(() async => throw const DsmException(105),
          storage: () async => throw StateError('transport offline')),
      refreshInterval: const Duration(seconds: 10),
      onAuthInvalidated: (_) => reauth++,
    );
    await other.loadInitial();
    expect(reauth, 1);
    other.dispose();
  }, timeout: const Timeout(Duration(seconds: 15)));

  testWidgets(
    'runtime shell auth signal reuses exact saved account and defers persistence until login success',
    (tester) async {
      // The shell's platform share listener is unrelated to the DSM auth
      // relationship under test. Provide empty platform event responses.
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const sharing = MethodChannel('flutter_sharing_intent');
      const sharingEvents = MethodChannel('flutter_sharing_intent/events-sharing');
      messenger.setMockMethodCallHandler(
        sharing,
        (call) async => call.method == 'getInitialSharing' ? '[]' : null,
      );
      messenger.setMockMethodCallHandler(sharingEvents, (call) async => null);
      final originalDb = DbUtils.db;
      final db = Database.forTesting(NativeDatabase.memory());
      DbUtils.db = db;
      try {
        final server = await db.into(db.servers).insertReturning(
              ServersCompanion.insert(
                groupId: 1, ssl: false, qcid: '', domain: 'nas.local',
                port: 5000, checkSsl: false, remark: '',
                macAddress: '', createTime: 1,
              ),
            );
        final account = await db.into(db.accounts).insertReturning(
              AccountsCompanion.insert(
                serverId: server.id, account: 'alice',
                password: 'stored-password', remark: '',
                createTime: 1, lastLoginTime: 1, isDefault: true,
                deviceId: 'old-device', sid: 'stale-sid',
                ikMessage: 'old-ik', synoToken: 'old-token',
              ),
            );
        final contextId = '${server.id}/${account.id}';
        final pendingAuth = Completer<Auth>();
        var logins = 0;
        var activations = 0;
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => DarkModeProvider(0)),
              ChangeNotifierProvider(create: (_) => SettingProvider()),
            ],
            child: MaterialApp(
              home: ModernUiRoot(
                initialAuthRequired: false,
                initializeDownloader: false,
                overviewControllerFactory: (interval) => OverviewController(
                  dataSource: _source(() async => System(model: 'test-only')),
                  refreshInterval: interval,
                ),
                dataSource: _SavedSource(StartupSavedContext(
                  accountId: account.id, serverId: server.id,
                  isDefault: true, baseUrl: server.url,
                  deviceId: account.deviceId, sid: account.sid,
                  checkSsl: server.checkSsl,
                )),
                contextActivator: (request) async {
                  activations++;
                  expect(request.contextId, contextId);
                  return ActiveContextResult(
                    contextId: contextId,
                    status: ActiveContextStatus.offline,
                  );
                },
                loginPreparation: (server, savedAccount) async {
                  expect(server.id, account.serverId);
                  expect(savedAccount?.id, account.id);
                },
                authLogin: ({required account, required password, optCode}) {
                  expect(account, 'alice');
                  expect(password, 'stored-password');
                  logins++;
                  return pendingAuth.future;
                },
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        final shell = tester.widget<DsmNewUiShell>(find.byType(DsmNewUiShell));
        expect(shell.contextId, contextId);
        expect(shell.onReauthNeeded, isNotNull);
        shell.onReauthNeeded!();
        shell.onReauthNeeded!();
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();
        expect(logins, 1);
        final before = (await db.select(db.accounts).get()).single;
        expect(before.id, account.id);
        expect(before.sid, 'stale-sid');
        expect(before.isDefault, true);

        pendingAuth.complete(Auth(
          account: 'alice', deviceId: 'new-device',
          sid: 'renewed-sid', ikMessage: '', synotoken: 'new-token',
        ));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();
        final updated = (await db.select(db.accounts).get()).single;
        expect(updated.id, account.id);
        expect(updated.sid, 'renewed-sid');
        expect(updated.isDefault, true);
        expect(logins, 1);
        expect(activations, greaterThanOrEqualTo(1));
      } finally {
        await tester.pumpWidget(const SizedBox());
        messenger.setMockMethodCallHandler(sharing, null);
        messenger.setMockMethodCallHandler(sharingEvents, null);
        DbUtils.db = originalDb;
        await db.close();
      }
    },
    timeout: const Timeout(Duration(seconds: 45)),
  );

  testWidgets(
    'production shell notifications and legacy handoff survive Overview failures and preserve other tabs',
    (tester) async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const sharing = MethodChannel('flutter_sharing_intent');
      const sharingEvents =
          MethodChannel('flutter_sharing_intent/events-sharing');
      messenger.setMockMethodCallHandler(
        sharing,
        (call) async => call.method == 'getInitialSharing' ? '[]' : null,
      );
      messenger.setMockMethodCallHandler(sharingEvents, (_) async => null);

      final initData = InitDataModel.fromJson({
        'Session': {'majorversion': '7', 'hostname': 'DSM-NAV'},
        'UserSettings': {
          'Desktop': {
            'ShortcutItems': [
              {'className': 'SYNO.SDS.AdminCenter.Application'},
            ],
            'valid_appview_order': ['SYNO.SDS.AdminCenter.Application'],
          },
          'SYNO.SDS._Widget.Instance': {'modulelist': <String>[]},
        },
      });
      var failed = false;
      var systemRequests = 0;
      var manageCalls = 0;
      var logoutCalls = 0;
      OverviewController? firstController;

      Widget host() => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => DarkModeProvider(0)),
              ChangeNotifierProvider(
                create: (_) => SettingProvider(refreshDuration: 3600),
              ),
            ],
            child: MaterialApp(
              home: DsmNewUiShell(
                contextId: '7/42',
                legacyBootstrap: LegacySharedBootstrap(
                  loadInitData: () async => initData,
                ),
                overviewControllerFactory: (interval) {
                  final controller = OverviewController(
                    refreshInterval: interval,
                    dataSource: OverviewDataSource(
                      loadSystem: () async {
                        systemRequests++;
                        if (failed) throw StateError('DSM unavailable');
                        return System(upTime: '24:0:0');
                      },
                      loadUtilization: () async =>
                          Utilization(memory: Memory(realUsage: 49)),
                      loadStorage: () async => Storage(),
                      loadNotifications: () async => DsmNotify(),
                      loadCurrentConnections: () async => null,
                      loadTaskScheduler: () async => null,
                    ),
                  );
                  firstController ??= controller;
                  return controller;
                },
                onManageAccounts: () => manageCalls++,
                onLogout: () => logoutCalls++,
              ),
            ),
          );

      Future<void> openNotifications() async {
        await tester.tap(find.byKey(const Key('new-ui-notifications')));
        await tester.pumpAndSettle();
        expect(find.byType(LegacyPageHost), findsOneWidget);
        expect(find.byType(LegacyNotificationEntry), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }

      try {
        await tester.pumpWidget(host());
        await tester.pumpAndSettle();
        expect(find.byType(OverviewPage), findsOneWidget);
        expect(find.text('DSM-NAV'), findsOneWidget);
        expect(find.text('49%'), findsOneWidget);

        await openNotifications();
        expect(find.text('DSM-NAV'), findsOneWidget);
        expect(tester.widget<NavigationBar>(find.byType(NavigationBar))
            .selectedIndex, 0);

        failed = true;
        await firstController!.refresh();
        await tester.pump();
        expect(find.text('系统信息数据已过期'), findsOneWidget);
        expect(find.text('49%'), findsOneWidget);
        await openNotifications();
        expect(find.text('系统信息数据已过期'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.byKey(const Key(
              'overview-shortcut-0:SYNO.SDS.AdminCenter.Application')),
          130,
          scrollable: find.descendant(
            of: find.byKey(const Key('overview-scroll')),
            matching: find.byType(Scrollable),
          ),
        );
        await tester.tap(find.byKey(const Key(
            'overview-shortcut-0:SYNO.SDS.AdminCenter.Application')));
        await tester.pumpAndSettle();
        expect(find.byType(LegacyPageHost), findsOneWidget);
        expect(find.byType(ControlPanel), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(OverviewPage), findsOneWidget);
        expect(find.text('DSM-NAV'), findsOneWidget);

        await tester.tap(find.text('应用'));
        await tester.pumpAndSettle();
        expect(tester.widget<NavigationBar>(find.byType(NavigationBar))
            .selectedIndex, 2);
        await openNotifications();
        expect(tester.widget<NavigationBar>(find.byType(NavigationBar))
            .selectedIndex, 2);
        expect(find.byType(ApplicationsPage), findsOneWidget);

        await tester.tap(find.text('我的'));
        await tester.pumpAndSettle();
        expect(find.byType(SettingsPage), findsOneWidget);
        await tester.tap(find.text('服务器与账号管理'));
        await tester.pump();
        await tester.tap(find.text('退出登录'));
        expect(manageCalls, 1);
        expect(logoutCalls, 1);
        expect(tester.widget<NavigationBar>(find.byType(NavigationBar))
            .selectedIndex, 4);
        await openNotifications();
        expect(tester.widget<NavigationBar>(find.byType(NavigationBar))
            .selectedIndex, 4);

        final oldController = firstController!;
        await tester.pumpWidget(const SizedBox.shrink());
        final before = systemRequests;
        await oldController.refresh();
        expect(systemRequests, before);

        // A disposed Overview must not own or disable notifications for a
        // fresh shell, even when its new Overview cannot load system data.
        await tester.pumpWidget(host());
        await tester.pumpAndSettle();
        await tester.tap(find.text('文件'));
        await tester.pumpAndSettle();
        await openNotifications();
        expect(tester.widget<NavigationBar>(find.byType(NavigationBar))
            .selectedIndex, 1);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        messenger.setMockMethodCallHandler(sharing, null);
        messenger.setMockMethodCallHandler(sharingEvents, null);
      }
    },
    timeout: const Timeout(Duration(seconds: 45)),
  );
}
