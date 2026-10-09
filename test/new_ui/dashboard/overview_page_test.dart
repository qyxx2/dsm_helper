import 'dart:async';
import 'dart:ui' as ui;

import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/models/Syno/Core/Notify.dart';
import 'package:dsm_helper/models/Syno/Core/System.dart';
import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_alerts.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_controller.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_data_source.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_page.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_shortcuts.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:dsm_helper/providers/init_data_provider.dart';
import 'package:dsm_helper/providers/setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _MutableSettings extends SettingProvider {
  _MutableSettings(int seconds)
      : _seconds = seconds,
        super(refreshDuration: seconds);
  int _seconds;

  @override
  int get refreshDuration => _seconds;

  void change(int seconds) {
    _seconds = seconds;
    notifyListeners();
  }
}

OverviewDataSource _source({
  OverviewSystemLoader? system,
  OverviewUtilizationLoader? utilization,
  OverviewStorageLoader? storage,
  OverviewNotificationLoader? notifications,
}) =>
    OverviewDataSource(
      loadSystem: system ?? () async => System(upTime: '48:2:5'),
      loadUtilization: utilization ??
          () async => Utilization(
                cpu: Cpu(userLoad: 22, systemLoad: 8),
                memory: Memory(realUsage: 42),
              ),
      loadStorage: storage ??
          () async => Storage(volumes: [
                Volumes(
                  id: 'volume_1',
                  size: Size(total: 8 * 1073741824, used: 2 * 1073741824),
                ),
              ]),
      loadNotifications: notifications ?? () async => DsmNotify(),
    );

Widget _host({
  required InitDataProvider initData,
  required SettingProvider settings,
  required OverviewControllerFactory factory,
  Brightness brightness = Brightness.light,
  double scale = 1,
  VoidCallback? onNotification,
  ValueChanged<OverviewAlertDestination>? onAlertDestination,
  ValueChanged<OverviewShortcut>? onShortcut,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<InitDataProvider>.value(value: initData),
      ChangeNotifierProvider<SettingProvider>.value(value: settings),
    ],
    child: MaterialApp(
      theme: brightness == Brightness.light
          ? NewUiTheme.light()
          : NewUiTheme.dark(),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: OverviewPage(
          controllerFactory: factory,
          onOpenNotifications: onNotification ?? () {},
          onOpenAlertDestination: onAlertDestination,
          onOpenShortcut: onShortcut,
          connectionStatusText: '离线',
        ),
      ),
    ),
  );
}

InitDataProvider _init() => InitDataProvider()
  ..setInitData(InitDataModel(session: Session(hostname: 'NAS-ONE')));

class _WidgetSettingsStub extends UserSettings {
  _WidgetSettingsStub({
    required List<String> ids,
    this.result = true,
  }) : super(synoSDSWidgetInstance: SynoSdsWidgetInstance(moduleList: ids));

  bool? result;
  final writes = <List<String>>[];

  @override
  Future<bool?> apply(List<String> modulelist) async {
    writes.add(List.of(modulelist));
    return result;
  }
}

void main() {
  testWidgets('initial loading is explicit and valid data appears independently',
      (tester) async {
    final pendingSystem = Completer<System?>();
    var created = 0;
    final init = _init();
    final settings = _MutableSettings(20);
    await tester.pumpWidget(_host(
      initData: init,
      settings: settings,
      factory: (interval) {
        created++;
        expect(interval, const Duration(seconds: 20));
        return OverviewController(
          dataSource: _source(system: () => pendingSystem.future),
          refreshInterval: interval,
        );
      },
    ));
    expect(created, 1);
    expect(find.text('NAS-ONE'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    await tester.pump();
    expect(find.text('30%'), findsOneWidget);
    expect(find.text('42%'), findsOneWidget);
    expect(find.text('25.0%'), findsOneWidget);
    pendingSystem.complete(System(upTime: '48:2:5'));
    await tester.pump();
    expect(find.text('2天 00:02:05'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('source-local failures preserve valid CPU and storage siblings',
      (tester) async {
    final init = _init();
    final settings = _MutableSettings(25);
    await tester.pumpWidget(_host(
      initData: init,
      settings: settings,
      factory: (interval) => OverviewController(
        dataSource: _source(
          system: () async => throw StateError('system failed'),
          utilization: () async => Utilization(
            cpu: Cpu(userLoad: 10, systemLoad: 5),
            memory: Memory(realUsage: 64),
          ),
        ),
        refreshInterval: interval,
      ),
    ));
    await tester.pump();
    expect(find.text('15%'), findsOneWidget);
    expect(find.text('64%'), findsOneWidget);
    expect(find.text('存储空间 1'), findsOneWidget);
    expect(find.text('系统信息加载失败'), findsOneWidget);
    expect(find.text('NAS-ONE'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('refresh retains V1, failure marks explicit stale, success replaces V2',
      (tester) async {
    var calls = 0;
    final pending = Completer<Utilization?>();
    OverviewController? controller;
    final init = _init();
    final settings = _MutableSettings(30);
    await tester.pumpWidget(_host(
      initData: init,
      settings: settings,
      factory: (interval) {
        controller = OverviewController(
          dataSource: _source(utilization: () {
            calls++;
            if (calls == 1) {
              return Future.value(
                  Utilization(memory: Memory(realUsage: 43)));
            }
            if (calls == 2) return pending.future;
            return Future.value(
                Utilization(memory: Memory(realUsage: 65)));
          }),
          refreshInterval: interval,
        );
        return controller!;
      },
    ));
    await tester.pump();
    expect(find.text('43%'), findsOneWidget);
    final refreshing = controller!.refresh();
    await tester.pump();
    expect(find.text('43%'), findsOneWidget);
    expect(find.byKey(const Key('overview-refresh-slot')), findsOneWidget);
    expect(find.byKey(const Key('overview-refresh-indicator')), findsOneWidget);
    expect(find.text('数据刷新中'), findsNothing);
    pending.completeError(StateError('temporary disconnect'));
    await refreshing;
    await tester.pump();
    expect(find.text('43%'), findsOneWidget);
    expect(find.text('资源数据已过期'), findsOneWidget);
    await controller!.refresh();
    await tester.pump();
    expect(find.text('65%'), findsOneWidget);
    expect(find.text('资源数据已过期'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('pull-to-refresh invokes same controller without blanking data',
      (tester) async {
    var utilizationCalls = 0;
    final init = _init();
    final settings = _MutableSettings(60);
    await tester.pumpWidget(_host(
      initData: init,
      settings: settings,
      factory: (interval) => OverviewController(
        dataSource: _source(utilization: () async {
          utilizationCalls++;
          return Utilization(memory: Memory(realUsage: 37));
        }),
        refreshInterval: interval,
      ),
    ));
    await tester.pump();
    expect(utilizationCalls, 1);
    expect(find.text('37%'), findsOneWidget);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 350));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(utilizationCalls, 2);
    expect(find.text('37%'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('refresh setting changes one timer cadence and controller is disposed',
      (tester) async {
    final init = _init();
    final settings = _MutableSettings(10);
    var created = 0;
    var calls = 0;
    await tester.pumpWidget(_host(
      initData: init,
      settings: settings,
      factory: (interval) {
        created++;
        return OverviewController(
          dataSource: _source(system: () async {
            calls++;
            return System(upTime: '24:0:0');
          }),
          refreshInterval: interval,
        );
      },
    ));
    await tester.pump();
    expect(calls, 1);
    settings.change(2);
    await tester.pump();
    expect(created, 1);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(calls, 2);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(calls, 3);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 6));
    expect(calls, 3);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('notifications callback, light/dark and large text remain usable',
      (tester) async {
    tester.view.physicalSize = const ui.Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final init = _init();
    final settings = _MutableSettings(60);
    var notifications = 0;
    for (final brightness in [Brightness.light, Brightness.dark]) {
      await tester.pumpWidget(_host(
        initData: init,
        settings: settings,
        brightness: brightness,
        scale: 2.2,
        onNotification: () => notifications++,
        factory: (interval) => OverviewController(
          dataSource: _source(),
          refreshInterval: interval,
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('new-ui-notifications')), findsOneWidget);
      await tester.tap(find.byKey(const Key('new-ui-notifications')));
      expect(notifications, greaterThan(0));
    }
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 25)));

  testWidgets('healthy Overview omits abnormal region and ordinary notifications',
      (tester) async {
    final init = _init();
    final settings = _MutableSettings(30);
    await tester.pumpWidget(_host(
      initData: init,
      settings: settings,
      factory: (interval) => OverviewController(
        dataSource: _source(notifications: () async => DsmNotify(items: [
          DsmNotifyItems(
            level: 'NOTIFICATION_INFO',
            title: 'InformationalNotification',
            time: 1,
          ),
        ])),
        refreshInterval: interval,
      ),
    ));
    await tester.pump();
    expect(find.text('异常提醒'), findsNothing);
    expect(find.text('InformationalNotification'), findsNothing);
    expect(find.byKey(const Key('new-ui-notifications')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('abnormal section uses source severity and exact destination',
      (tester) async {
    tester.view.physicalSize = const ui.Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final init = _init();
    final settings = _MutableSettings(30);
    final destinations = <OverviewAlertDestination>[];
    var globalNotificationOpens = 0;
    await tester.pumpWidget(_host(
      initData: init,
      settings: settings,
      onNotification: () => globalNotificationOpens++,
      onAlertDestination: destinations.add,
      factory: (interval) => OverviewController(
        dataSource: _source(
          storage: () async => Storage(volumes: [
            Volumes(id: 'volume_1', status: 'attention'),
          ]),
          notifications: () async => DsmNotify(items: [
            DsmNotifyItems(
              level: 'NOTIFICATION_ERROR',
              title: 'DiskCritical',
              time: 12,
            ),
            DsmNotifyItems(
              level: 'NOTIFICATION_INFO',
              title: 'HarmlessInfo',
              time: 13,
            ),
          ]),
        ),
        refreshInterval: interval,
      ),
    ));
    await tester.pump();
    expect(find.text('异常提醒'), findsOneWidget);
    expect(find.text('DiskCritical'), findsOneWidget);
    expect(find.text('存储空间 1 · 警告'), findsOneWidget);
    expect(find.text('HarmlessInfo'), findsNothing);
    await tester.tap(find.text('DiskCritical'));
    await tester.tap(find.text('存储空间 1 · 警告'));
    expect(destinations, [
      OverviewAlertDestination.notifications,
      OverviewAlertDestination.storageManager,
    ]);
    await tester.tap(find.byKey(const Key('new-ui-notifications')));
    expect(globalNotificationOpens, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 25)));

  testWidgets('stale notification refresh keeps last-valid abnormal evidence',
      (tester) async {
    tester.view.physicalSize = const ui.Size(400, 1300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final init = _init();
    final settings = _MutableSettings(30);
    final pending = Completer<DsmNotify?>();
    var calls = 0;
    OverviewController? controller;
    await tester.pumpWidget(_host(
      initData: init,
      settings: settings,
      factory: (interval) {
        controller = OverviewController(
          dataSource: _source(notifications: () {
            calls++;
            if (calls == 1) {
              return Future.value(DsmNotify(items: [
                DsmNotifyItems(
                  level: 'NOTIFICATION_WARN',
                  title: 'ActualWarning',
                  time: 21,
                ),
              ]));
            }
            return pending.future;
          }),
          refreshInterval: interval,
        );
        return controller!;
      },
    ));
    await tester.pump();
    expect(find.text('ActualWarning'), findsOneWidget);
    final refresh = controller!.refresh();
    await tester.pump();
    expect(find.text('ActualWarning'), findsOneWidget);
    pending.completeError(StateError('notification network interruption'));
    await refresh;
    await tester.pump();
    expect(find.text('ActualWarning'), findsOneWidget);
    expect(find.text('通知数据已过期'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 25)));
  testWidgets('Modern fixed shortcut region ignores legacy showShortcut false and stays when empty',
      (tester) async {
    final init = _init();
    final settings = SettingProvider(refreshDuration: 30, showShortcut: false);
    await tester.pumpWidget(_host(
      initData: init,
      settings: settings,
      factory: (interval) => OverviewController(
        dataSource: _source(),
        refreshInterval: interval,
      ),
    ));
    await tester.pump();
    expect(find.byKey(const Key('overview-shortcuts')), findsOneWidget);
    expect(find.text('快捷方式'), findsOneWidget);
    expect(find.textContaining('暂无可用快捷方式'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('Overview reads DSM shortcuts in source order and forwards exact selected entry',
      (tester) async {
    tester.view.physicalSize = const ui.Size(420, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final init = _init();
    const pkg = 'SYNO.SDS.PkgManApp.Instance';
    const panel = 'SYNO.SDS.AdminCenter.Application';
    init.setInitData(InitDataModel(
      session: Session(hostname: 'NAS-ONE'),
      userSettings: UserSettings(desktop: Desktop(
        shortcutItems: [
          ShortcutItems(className: 'unsupported'),
          ShortcutItems(className: panel),
          ShortcutItems(className: pkg),
        ],
        validAppviewOrder: [pkg, panel],
      )),
    ));
    final selected = <OverviewShortcut>[];
    await tester.pumpWidget(_host(
      initData: init,
      settings: SettingProvider(refreshDuration: 30, showShortcut: false),
      onShortcut: selected.add,
      factory: (interval) => OverviewController(
        dataSource: _source(),
        refreshInterval: interval,
      ),
    ));
    await tester.pump();
    expect(find.text('控制面板'), findsOneWidget);
    expect(find.text('套件中心'), findsOneWidget);
    final panelTile = find.byKey(const Key('overview-shortcut-1:SYNO.SDS.AdminCenter.Application'));
    await tester.ensureVisible(panelTile);
    await tester.tap(panelTile);
    expect(selected.single.label, '控制面板');
    expect(selected.single.routeName, '/control_panel');
    expect(selected.single.id, '1:$panel');
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 25)));


  testWidgets('Overview edit action opens owned-only editor without consuming notifications',
      (tester) async {
    final settingsData = _WidgetSettingsStub(ids: [
      'SYNO.SDS.ResourceMonitor.Widget',
      'SYNO.SDS.SystemInfoApp.ConnectionLogWidget',
      'vendor.UnrecognizedWidget',
    ]);
    final provider = InitDataProvider()
      ..setInitData(InitDataModel(
        session: Session(hostname: 'NAS-ONE'),
        userSettings: settingsData,
      ));
    var notifications = 0;
    await tester.pumpWidget(_host(
      initData: provider,
      settings: SettingProvider(refreshDuration: 30),
      onNotification: () => notifications++,
      factory: (interval) => OverviewController(
        dataSource: _source(),
        refreshInterval: interval,
      ),
    ));
    await tester.pump();
    expect(find.byKey(const Key('new-ui-notifications')), findsOneWidget);
    expect(find.byKey(const Key('overview-edit-action')), findsOneWidget);
    await tester.tap(find.byKey(const Key('overview-edit-action')));
    await tester.pumpAndSettle();
    expect(find.text('编辑概览'), findsOneWidget);
    expect(find.text('当前连接'), findsOneWidget);
    expect(find.text('计划任务'), findsOneWidget);
    await tester.tap(find.byKey(const Key('overview-edit-cancel')));
    await tester.pumpAndSettle();
    expect(settingsData.writes, isEmpty);
    expect(find.byKey(const Key('new-ui-notifications')), findsOneWidget);
    await tester.tap(find.byKey(const Key('new-ui-notifications')));
    expect(notifications, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 25)));

  testWidgets('Overview successful save writes full list then publishes confirmed DSM modules',
      (tester) async {
    const core = 'SYNO.SDS.SystemInfoApp.SystemHealthWidget';
    const conn = 'SYNO.SDS.SystemInfoApp.ConnectionLogWidget';
    const scheduler = 'SYNO.SDS.TaskScheduler.TaskSchedulerWidget';
    const deferred = 'SYNO.SDS.SystemInfoApp.FileChangeLogWidget';
    const opaque = 'vendor.UnrecognizedWidget';
    final user = _WidgetSettingsStub(ids: [core, conn, deferred, opaque]);
    final provider = InitDataProvider()
      ..setInitData(InitDataModel(
        session: Session(hostname: 'NAS-ONE'),
        userSettings: user,
      ));
    var notifications = 0;
    provider.addListener(() => notifications++);
    await tester.pumpWidget(_host(
      initData: provider,
      settings: SettingProvider(refreshDuration: 30),
      factory: (interval) => OverviewController(
        dataSource: _source(),
        refreshInterval: interval,
      ),
    ));
    await tester.pump();
    await tester.tap(find.byKey(const Key('overview-edit-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('overview-visible-$scheduler')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('overview-edit-save')));
    await tester.pumpAndSettle();
    const expected = [core, conn, scheduler, deferred, opaque];
    expect(user.writes.single, expected);
    expect(provider.initData.userSettings!.synoSDSWidgetInstance!.moduleList, expected);
    expect(notifications, 1);
    expect(find.byKey(const Key('overview-edit-action')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 25)));

  testWidgets('Overview failed save preserves DSM module authority and edit stays open',
      (tester) async {
    const core = 'SYNO.SDS.ResourceMonitor.Widget';
    const conn = 'SYNO.SDS.SystemInfoApp.ConnectionLogWidget';
    const opaque = 'vendor.UnrecognizedWidget';
    final original = <String>[core, conn, opaque];
    final user = _WidgetSettingsStub(ids: original, result: false);
    final provider = InitDataProvider()
      ..setInitData(InitDataModel(
        session: Session(hostname: 'NAS-ONE'),
        userSettings: user,
      ));
    var notifications = 0;
    provider.addListener(() => notifications++);
    await tester.pumpWidget(_host(
      initData: provider,
      settings: SettingProvider(refreshDuration: 30),
      factory: (interval) => OverviewController(
        dataSource: _source(),
        refreshInterval: interval,
      ),
    ));
    await tester.pump();
    await tester.tap(find.byKey(const Key('overview-edit-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('overview-visible-$conn')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('overview-edit-save')));
    await tester.pumpAndSettle();
    expect(user.writes.single, [core, opaque]);
    expect(provider.initData.userSettings!.synoSDSWidgetInstance!.moduleList, original);
    expect(notifications, 0);
    expect(find.text('保存失败，请重试'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 25)));

  testWidgets('Overview without loaded DSM module list disables edit action',
      (tester) async {
    final provider = _init();
    await tester.pumpWidget(_host(
      initData: provider,
      settings: SettingProvider(refreshDuration: 30),
      factory: (interval) => OverviewController(
        dataSource: _source(),
        refreshInterval: interval,
      ),
    ));
    await tester.pump();
    final action = tester.widget<IconButton>(
        find.byKey(const Key('overview-edit-action')));
    expect(action.onPressed, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 20)));


  testWidgets('fixed AppBar refresh slot preserves positions across manual, stale and timer refresh',
      (tester) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);
    tester.view.physicalSize = const ui.Size(400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final manual = Completer<Utilization?>();
    final automatic = Completer<Utilization?>();
    var calls = 0;
    var notifications = 0;
    OverviewController? controller;
    final init = InitDataProvider()
      ..setInitData(InitDataModel(
        session: Session(hostname: 'NAS-ONE'),
        userSettings: _WidgetSettingsStub(ids: []),
      ));
    await tester.pumpWidget(_host(
      initData: init,
      settings: _MutableSettings(2),
      onNotification: () => notifications++,
      factory: (interval) {
        controller = OverviewController(
          dataSource: _source(utilization: () {
            calls++;
            if (calls == 1) {
              return Future.value(Utilization(memory: Memory(realUsage: 43)));
            }
            if (calls == 2) return manual.future;
            if (calls == 3) return automatic.future;
            return Future.value(Utilization(memory: Memory(realUsage: 65)));
          }),
          refreshInterval: interval,
        );
        return controller!;
      },
    ));
    await tester.pump();
    expect(calls, 1);
    final slot = find.byKey(const Key('overview-refresh-slot'));
    final indicator = find.byKey(const Key('overview-refresh-indicator'));
    final edit = find.byKey(const Key('overview-edit-action'));
    final notify = find.byKey(const Key('new-ui-notifications'));
    expect(slot, findsOneWidget);
    expect(tester.getSize(slot).width, 20);
    expect(indicator, findsNothing);
    expect(find.text('43%'), findsOneWidget);
    final nameY = tester.getTopLeft(find.text('NAS-ONE')).dy;
    final resourceY = tester.getTopLeft(find.text('43%')).dy;
    final editX = tester.getTopLeft(edit).dx;
    final notifyX = tester.getTopLeft(notify).dx;
    final slotX = tester.getTopLeft(slot).dx;

    final refresh = controller!.refresh();
    await tester.pump();
    expect(indicator, findsOneWidget);
    expect(find.bySemanticsLabel('数据刷新中'), findsOneWidget);
    expect(find.text('数据刷新中'), findsNothing);
    expect(find.text('43%'), findsOneWidget);
    expect(tester.getTopLeft(find.text('NAS-ONE')).dy, nameY);
    expect(tester.getTopLeft(find.text('43%')).dy, resourceY);
    expect(tester.getTopLeft(slot).dx, slotX);
    expect(tester.getTopLeft(edit).dx, editX);
    expect(tester.getTopLeft(notify).dx, notifyX);

    manual.completeError(StateError('refresh failed'));
    await refresh;
    await tester.pump();
    expect(indicator, findsNothing);
    expect(tester.getSize(slot).width, 20);
    expect(find.text('43%'), findsOneWidget);
    expect(find.text('资源数据已过期'), findsOneWidget);
    expect(tester.getTopLeft(find.text('NAS-ONE')).dy, nameY);

    await tester.pump(const Duration(seconds: 2));
    expect(calls, 3);
    expect(indicator, findsOneWidget);
    expect(find.text('43%'), findsOneWidget);
    expect(find.text('数据刷新中'), findsNothing);
    expect(tester.getTopLeft(find.text('NAS-ONE')).dy, nameY);
    expect(tester.getTopLeft(edit).dx, editX);
    expect(tester.getTopLeft(notify).dx, notifyX);

    automatic.complete(Utilization(memory: Memory(realUsage: 65)));
    await tester.pump();
    expect(indicator, findsNothing);
    expect(find.text('65%'), findsOneWidget);
    expect(find.text('资源数据已过期'), findsNothing);
    expect(tester.getTopLeft(find.text('NAS-ONE')).dy, nameY);
    expect(tester.getTopLeft(edit).dx, editX);
    expect(tester.getTopLeft(notify).dx, notifyX);
    await tester.tap(notify);
    expect(notifications, 1);
    expect(tester.widget<IconButton>(edit).onPressed, isNotNull);
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 25)));

}
