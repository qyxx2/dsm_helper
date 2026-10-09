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
import 'package:dsm_helper/new_ui/dashboard/overview_controller.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_data_source.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_page.dart';
import 'package:dsm_helper/new_ui/dashboard/widgets/shortcut_section.dart';
import 'package:dsm_helper/new_ui/shell/new_ui_shell.dart';
import 'package:dsm_helper/new_ui/legacy/legacy_shared_bootstrap.dart';
import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:dsm_helper/new_ui/startup/modern_startup.dart';
import 'package:dsm_helper/providers/dark_mode.dart';
import 'package:dsm_helper/providers/init_data_provider.dart';
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
    'A to B shell context switch drops A Overview data, config, navigation and late completion',
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

      const aConnection = 'SYNO.SDS.SystemInfoApp.ConnectionLogWidget';
      const bScheduler = 'SYNO.SDS.TaskScheduler.TaskSchedulerWidget';
      const aShortcut = 'SYNO.SDS.AdminCenter.Application';
      const bShortcut = 'SYNO.SDS.PkgManApp.Instance';

      InitDataModel init(String hostname, String shortcut, String module) =>
          InitDataModel.fromJson({
            'Session': {'majorversion': '7', 'hostname': hostname},
            'UserSettings': {
              'Desktop': {
                'ShortcutItems': [{'className': shortcut}],
                'valid_appview_order': [shortcut],
              },
              'SYNO.SDS._Widget.Instance': {
                'modulelist': [module, 'opaque-$hostname'],
              },
            },
          });

      final delayedA = Completer<System?>();
      var systemCallsA = 0;
      OverviewController? controllerA;
      OverviewController? controllerB;
      final factoryA = (Duration interval) {
        controllerA = OverviewController(
          refreshInterval: interval,
          dataSource: OverviewDataSource(
            loadSystem: () {
              systemCallsA++;
              return systemCallsA == 1
                  ? Future<System?>.value(System(upTime: '24:0:0'))
                  : delayedA.future;
            },
            loadUtilization: () async =>
                Utilization(memory: Memory(realUsage: 12)),
            loadStorage: () async => Storage(),
            loadNotifications: () async => DsmNotify(items: [
              DsmNotifyItems(level: 'NOTIFICATION_WARN', title: 'A-ALERT'),
            ]),
            loadCurrentConnections: () async => null,
            loadTaskScheduler: () async => null,
          ),
        );
        return controllerA!;
      };
      final factoryB = (Duration interval) {
        controllerB = OverviewController(
          refreshInterval: interval,
          dataSource: OverviewDataSource(
            loadSystem: () async => System(upTime: '48:0:0'),
            loadUtilization: () async =>
                Utilization(memory: Memory(realUsage: 53)),
            loadStorage: () async => Storage(),
            loadNotifications: () async => DsmNotify(items: [
              DsmNotifyItems(level: 'NOTIFICATION_WARN', title: 'B-ALERT'),
            ]),
            loadCurrentConnections: () async => null,
            loadTaskScheduler: () async => null,
          ),
        );
        return controllerB!;
      };

      Widget shell({
        required String contextId,
        required InitDataModel initData,
        required OverviewController Function(Duration) controllerFactory,
      }) =>
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => DarkModeProvider(0)),
              ChangeNotifierProvider(
                create: (_) => SettingProvider(refreshDuration: 3600),
              ),
            ],
            child: MaterialApp(
              home: DsmNewUiShell(
                contextId: contextId,
                legacyBootstrap: LegacySharedBootstrap(
                  loadInitData: () async => initData,
                ),
                overviewControllerFactory: controllerFactory,
              ),
            ),
          );

      try {
        await tester.pumpWidget(shell(
          contextId: '1/11',
          initData: init('NAS-A', aShortcut, aConnection),
          controllerFactory: factoryA,
        ));
        await tester.pumpAndSettle();
        await tester.pump();
        expect(find.text('NAS-A'), findsOneWidget);
        expect(find.text('12%'), findsOneWidget);
        expect(controllerA!.notifications.value?.items?.single.title, 'A-ALERT');
        final aProvider = Provider.of<InitDataProvider>(
          tester.element(find.byType(OverviewPage)),
          listen: false,
        );
        expect(aProvider.initData.userSettings!.synoSDSWidgetInstance!.moduleList,
            [aConnection, 'opaque-NAS-A']);
        expect(controllerA!.currentConnections.phase.name,
            isNot('initial'));

        await tester.tap(find.text('文件'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
          1,
        );
        // The A overview continues refreshing while A's non-overview tab
        // is selected. The old response must not publish into B.
        final oldCycle = controllerA!.refresh();
        expect(systemCallsA, 2);

        await tester.pumpWidget(shell(
          contextId: '2/22',
          initData: init('NAS-B', bShortcut, bScheduler),
          controllerFactory: factoryB,
        ));
        await tester.pumpAndSettle();
        await tester.pump();
        expect(
          tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
          0,
        );
        expect(find.byType(OverviewPage), findsOneWidget);
        expect(find.text('NAS-B'), findsOneWidget);
        expect(find.text('53%'), findsOneWidget);
        expect(find.text('NAS-A'), findsNothing);
        expect(find.text('12%'), findsNothing);
        expect(controllerB, isNotNull);
        expect(controllerB, isNot(same(controllerA)));
        expect(controllerB!.notifications.value?.items?.single.title, 'B-ALERT');

        final bProvider = Provider.of<InitDataProvider>(
          tester.element(find.byType(OverviewPage)),
          listen: false,
        );
        expect(bProvider, isNot(same(aProvider)));
        expect(bProvider.initData.userSettings!.synoSDSWidgetInstance!.moduleList,
            [bScheduler, 'opaque-NAS-B']);
        expect(
          bProvider.initData.userSettings!.desktop!.shortcutItems!.single.className,
          bShortcut,
        );

        delayedA.complete(System(upTime: '99:0:0'));
        await oldCycle;
        await tester.pump();
        expect(find.text('NAS-B'), findsOneWidget);
        expect(find.text('53%'), findsOneWidget);
        expect(find.text('NAS-A'), findsNothing);
        expect(find.text('12%'), findsNothing);
        expect(controllerB!.system.value?.upTime, '48:0:0');

        await tester.scrollUntilVisible(
          find.byKey(const Key('overview-shortcuts')),
          150,
          scrollable: find.descendant(
            of: find.byKey(const Key('overview-scroll')),
            matching: find.byType(Scrollable),
          ),
        );
        final shortcuts = tester.widget<ShortcutSection>(
          find.byType(ShortcutSection),
        );
        expect(shortcuts.shortcuts.map((s) => s.label), ['套件中心']);
        expect(shortcuts.shortcuts.map((s) => s.label), isNot(contains('控制面板')));
        expect(find.byKey(const Key('overview-current-connections')), findsNothing);
        await tester.scrollUntilVisible(
          find.byKey(const Key('overview-task-scheduler')),
          150,
          scrollable: find.descendant(
            of: find.byKey(const Key('overview-scroll')),
            matching: find.byType(Scrollable),
          ),
        );
      } finally {
        if (!delayedA.isCompleted) {
          delayedA.complete(null);
        }
        await tester.pumpWidget(const SizedBox.shrink());
        messenger.setMockMethodCallHandler(sharing, null);
        messenger.setMockMethodCallHandler(sharingEvents, null);
      }
    },
    timeout: const Timeout(Duration(seconds: 35)),
  );
}
