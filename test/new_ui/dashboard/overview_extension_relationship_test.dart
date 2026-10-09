import 'dart:ui' as ui;

import 'package:dsm_helper/models/Syno/Core/CurrentConnection.dart';
import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/models/Syno/Core/Notify.dart';
import 'package:dsm_helper/models/Syno/Core/System.dart';
import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/models/Syno/Core/TaskScheduler.dart';
import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_controller.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_data_source.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_page.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:dsm_helper/providers/init_data_provider.dart';
import 'package:dsm_helper/providers/setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const connection = 'SYNO.SDS.SystemInfoApp.ConnectionLogWidget';
const scheduler = 'SYNO.SDS.TaskScheduler.TaskSchedulerWidget';
const core = 'SYNO.SDS.ResourceMonitor.Widget';
const deferred = 'SYNO.SDS.SystemInfoApp.RecentLogWidget';
const opaque = 'vendor.UnknownDashboardWidget';

class _WidgetSettingsStub extends UserSettings {
  _WidgetSettingsStub(List<String> ids)
      : super(synoSDSWidgetInstance: SynoSdsWidgetInstance(moduleList: ids));

  final writes = <List<String>>[];

  @override
  Future<bool?> apply(List<String> modulelist) async {
    writes.add(List<String>.of(modulelist));
    return true;
  }
}

Widget _host({
  required InitDataProvider provider,
  required OverviewControllerFactory factory,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<InitDataProvider>.value(value: provider),
      ChangeNotifierProvider<SettingProvider>.value(
        value: SettingProvider(refreshDuration: 30),
      ),
    ],
    child: MaterialApp(
      theme: NewUiTheme.light(),
      home: OverviewPage(
        controllerFactory: factory,
        onOpenNotifications: () {},
      ),
    ),
  );
}

void main() {
  testWidgets(
      'B5 config result controls extension polling and display without phantom modules',
      (tester) async {
    tester.view.physicalSize = const ui.Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final user = _WidgetSettingsStub(<String>[
      core,
      connection,
      deferred,
      opaque,
    ]);
    final provider = InitDataProvider()
      ..setInitData(
        InitDataModel(
          session: Session(hostname: 'NAS-ONE'),
          userSettings: user,
        ),
      );

    var connectionCalls = 0;
    var schedulerCalls = 0;
    OverviewController? controller;

    await tester.pumpWidget(
      _host(
        provider: provider,
        factory: (interval) {
          controller = OverviewController(
            dataSource: OverviewDataSource(
              loadSystem: () async => System(upTime: '24:0:0'),
              loadUtilization: () async => Utilization(
                memory: Memory(realUsage: 42),
              ),
              loadStorage: () async => Storage(),
              loadNotifications: () async => DsmNotify(),
              loadCurrentConnections: () async {
                connectionCalls++;
                return CurrentConnection(
                  total: 1,
                  items: <UserItems>[
                    UserItems(who: 'alice', from: '192.168.1.5'),
                  ],
                );
              },
              loadTaskScheduler: () async {
                schedulerCalls++;
                return TaskScheduler(
                  total: 1,
                  tasks: <Tasks>[
                    Tasks(
                      name: 'nightly-backup',
                      nextTriggerTime: '2026-10-10 02:00',
                      enable: true,
                    ),
                  ],
                );
              },
            ),
            refreshInterval: interval,
          );
          return controller!;
        },
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(connectionCalls, 1);
    expect(schedulerCalls, 0);
    expect(find.byKey(const Key('overview-current-connections')), findsOneWidget);
    expect(find.byKey(const Key('overview-task-scheduler')), findsNothing);
    expect(find.text('alice'), findsOneWidget);
    expect(find.text('42%'), findsOneWidget);

    await tester.tap(find.byKey(const Key('overview-edit-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('overview-visible-$connection')));
    await tester.tap(find.byKey(const Key('overview-visible-$scheduler')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('overview-edit-save')));
    await tester.pumpAndSettle();
    await tester.pump();

    const expected = <String>[core, scheduler, deferred, opaque];
    expect(user.writes.single, expected);
    expect(
      provider.initData.userSettings!.synoSDSWidgetInstance!.moduleList,
      expected,
    );
    expect(connectionCalls, 1);
    expect(schedulerCalls, 1);
    expect(find.byKey(const Key('overview-current-connections')), findsNothing);
    expect(find.byKey(const Key('overview-task-scheduler')), findsOneWidget);
    expect(find.text('nightly-backup'), findsOneWidget);
    expect(find.text('42%'), findsOneWidget);
    expect(find.text(deferred), findsNothing);
    expect(find.text(opaque), findsNothing);

    await controller!.refresh();
    await tester.pump();
    expect(connectionCalls, 1);
    expect(schedulerCalls, 2);

    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 30)));
}
