import 'dart:async';

import 'package:dsm_helper/models/Syno/Core/Notify.dart';
import 'package:dsm_helper/models/Syno/Core/System.dart';
import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_controller.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_data_source.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_source_state.dart';
import 'package:flutter_test/flutter_test.dart';

OverviewDataSource _source(Future<System?> Function() loadSystem) =>
    OverviewDataSource(
      loadSystem: loadSystem,
      loadUtilization: () async => Utilization(),
      loadStorage: () async => Storage(),
      loadNotifications: () async => DsmNotify(),
    );

void main() {
  test('late A completion after disposal cannot publish into active B', () async {
    final delayedA = Completer<System?>();
    final a = OverviewController(
      dataSource: _source(() => delayedA.future),
      refreshInterval: const Duration(seconds: 10),
    );
    var aNotifications = 0;
    a.addListener(() => aNotifications++);
    final loadingA = a.loadInitial();
    final notificationsBeforeDispose = aNotifications;
    a.dispose();

    final b = OverviewController(
      dataSource: _source(() async => System(model: 'NAS-B')),
      refreshInterval: const Duration(seconds: 10),
    );
    final seenB = <String>[];
    b.addListener(() {
      if (b.system.value?.model != null) seenB.add(b.system.value!.model!);
    });
    await b.loadInitial();
    expect(b.system.phase, OverviewSourcePhase.valid);
    expect(b.system.value?.model, 'NAS-B');

    delayedA.complete(System(model: 'NAS-A'));
    await loadingA;
    expect(aNotifications, notificationsBeforeDispose);
    expect(b.system.value?.model, 'NAS-B');
    expect(seenB, isNot(contains('NAS-A')));
    b.dispose();
  });

  testWidgets('stop and disposal prevent any future automatic ticks',
      (tester) async {
    var calls = 0;
    final c = OverviewController(
      dataSource: _source(() async {
        calls++;
        return System(model: 'NAS');
      }),
      refreshInterval: const Duration(seconds: 1),
    );
    await c.loadInitial();
    c.startAutoRefresh();
    c.stopAutoRefresh();
    await tester.pump(const Duration(seconds: 5));
    expect(calls, 1);

    c.startAutoRefresh();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(calls, 2);
    c.dispose();

    await tester.pump(const Duration(seconds: 5));
    expect(calls, 2);
  }, timeout: const Timeout(Duration(seconds: 15)));
}
