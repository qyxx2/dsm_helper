import 'dart:async';

import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/models/Syno/Core/Notify.dart';
import 'package:dsm_helper/models/Syno/Core/System.dart';
import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
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
          connectionStatusText: '离线',
        ),
      ),
    ),
  );
}

InitDataProvider _init() => InitDataProvider()
  ..setInitData(InitDataModel(session: Session(hostname: 'NAS-ONE')));

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
    expect(find.text('数据刷新中'), findsOneWidget);
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
    tester.view.physicalSize = const Size(360, 800);
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
}
