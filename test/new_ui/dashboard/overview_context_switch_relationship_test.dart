import 'dart:async';

import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/models/Syno/Core/Notify.dart';
import 'package:dsm_helper/models/Syno/Core/System.dart';
import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';
import 'package:dsm_helper/new_ui/app/dsm_new_ui_shell.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_controller.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_data_source.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_page.dart';
import 'package:dsm_helper/new_ui/dashboard/widgets/shortcut_section.dart';
import 'package:dsm_helper/new_ui/legacy/legacy_shared_bootstrap.dart';
import 'package:dsm_helper/providers/dark_mode.dart';
import 'package:dsm_helper/providers/init_data_provider.dart';
import 'package:dsm_helper/providers/setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_util/sp_util.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await SpUtil.getInstance();
  });

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
