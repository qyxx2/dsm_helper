import 'dart:async';

import 'package:dsm_helper/apis/dsm_api/dsm_exception.dart';
import 'package:dsm_helper/models/Syno/Core/Notify.dart';
import 'package:dsm_helper/models/Syno/Core/System.dart';
import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_controller.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_data_source.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_source_state.dart';
import 'package:flutter_test/flutter_test.dart';

OverviewDataSource source({
  OverviewSystemLoader? system,
  OverviewUtilizationLoader? utilization,
  OverviewStorageLoader? storage,
  OverviewNotificationLoader? notifications,
}) =>
    OverviewDataSource(
      loadSystem: system ?? () async => System(model: 'NAS'),
      loadUtilization: utilization ?? () async => Utilization(),
      loadStorage: storage ?? () async => Storage(),
      loadNotifications:
          notifications ?? () async => DsmNotify(items: <DsmNotifyItems>[]),
    );

OverviewController controller(
  OverviewDataSource dataSource, {
  Duration interval = const Duration(seconds: 10),
  OverviewAuthInvalidationHandler? onAuthInvalidated,
}) =>
    OverviewController(
      dataSource: dataSource,
      refreshInterval: interval,
      onAuthInvalidated: onAuthInvalidated,
    );

void main() {
  test('four independent source successes publish valid values', () async {
    final c = controller(source());
    await c.loadInitial();
    expect(c.system.phase, OverviewSourcePhase.valid);
    expect(c.system.value?.model, 'NAS');
    expect(c.utilization.phase, OverviewSourcePhase.valid);
    expect(c.storage.phase, OverviewSourcePhase.valid);
    expect(c.notifications.phase, OverviewSourcePhase.valid);
    expect(c.system.updatedAt, isNotNull);
    c.dispose();
  });

  test('one source failure does not overwrite its successful siblings', () async {
    final c = controller(source(
      utilization: () async => throw StateError('CPU offline'),
    ));
    await c.loadInitial();
    expect(c.system.phase, OverviewSourcePhase.valid);
    expect(c.utilization.phase, OverviewSourcePhase.error);
    expect(c.utilization.value, isNull);
    expect(c.storage.phase, OverviewSourcePhase.valid);
    expect(c.notifications.phase, OverviewSourcePhase.valid);
    c.dispose();
  });

  test('V1 survives refresh failure and is replaced by V2 on success', () async {
    var current = 'V1';
    var fail = false;
    final c = controller(source(system: () async {
      if (fail) throw StateError('temporarily disconnected');
      return System(model: current);
    }));
    await c.loadInitial();
    final originalTime = c.system.updatedAt;
    expect(c.system.value?.model, 'V1');

    fail = true;
    await c.refresh();
    expect(c.system.phase, OverviewSourcePhase.stale);
    expect(c.system.value?.model, 'V1');
    expect(c.system.error, isA<StateError>());
    expect(c.system.updatedAt, originalTime);
    expect(c.storage.phase, OverviewSourcePhase.valid);

    fail = false;
    current = 'V2';
    await c.refresh();
    expect(c.system.phase, OverviewSourcePhase.valid);
    expect(c.system.value?.model, 'V2');
    expect(c.system.error, isNull);
    c.dispose();
  });

  test('successful empty notifications are valid; null means unavailable', () async {
    final c = controller(source(
      system: () async => null,
      notifications: () async => DsmNotify(items: <DsmNotifyItems>[]),
    ));
    await c.loadInitial();
    expect(c.system.phase, OverviewSourcePhase.unavailable);
    expect(c.system.hasValue, isFalse);
    expect(c.notifications.phase, OverviewSourcePhase.valid);
    expect(c.notifications.value?.items, isEmpty);
    c.dispose();
  });

  test('manual refresh requests all four sources each time', () async {
    final calls = <String>[];
    final c = controller(source(
      system: () async {
        calls.add('system');
        return System();
      },
      utilization: () async {
        calls.add('utilization');
        return Utilization();
      },
      storage: () async {
        calls.add('storage');
        return Storage();
      },
      notifications: () async {
        calls.add('notifications');
        return DsmNotify();
      },
    ));
    await c.loadInitial();
    await c.refresh();
    expect(calls.where((x) => x == 'system').length, 2);
    expect(calls.where((x) => x == 'utilization').length, 2);
    expect(calls.where((x) => x == 'storage').length, 2);
    expect(calls.where((x) => x == 'notifications').length, 2);
    c.dispose();
  });

  test('concurrent DSM 119 failures emit one auth signal for controller lifetime', () async {
    var callbacks = 0;
    final c = controller(
      source(
        system: () async => throw const DsmException(119),
        storage: () async => throw const DsmException(119),
      ),
      onAuthInvalidated: (error) {
        expect(error.code, 119);
        callbacks++;
      },
    );
    await c.loadInitial();
    expect(callbacks, 1);
    expect(c.system.phase, OverviewSourcePhase.error);
    expect(c.storage.phase, OverviewSourcePhase.error);
    await c.refresh();
    expect(callbacks, 1);
    c.dispose();
  });

  test('non-119 DSM failures never invalidate authentication', () async {
    var callbacks = 0;
    final c = controller(
      source(system: () async => throw const DsmException(105)),
      onAuthInvalidated: (_) => callbacks++,
    );
    await c.loadInitial();
    expect(callbacks, 0);
    expect(c.system.phase, OverviewSourcePhase.error);
    expect(c.system.error, isA<DsmException>());
    c.dispose();
  });

  test('transport failures are source-local stale, not auth invalidation', () async {
    var fail = false;
    var callbacks = 0;
    final c = controller(
      source(system: () async {
        if (fail) throw Exception('socket disconnected');
        return System(model: 'last valid');
      }),
      onAuthInvalidated: (_) => callbacks++,
    );
    await c.loadInitial();
    fail = true;
    await c.refresh();
    expect(callbacks, 0);
    expect(c.system.phase, OverviewSourcePhase.stale);
    expect(c.system.value?.model, 'last valid');
    expect(c.storage.phase, OverviewSourcePhase.valid);
    c.dispose();
  });

  testWidgets('slow refresh never overlaps an automatic tick', (tester) async {
    final pending = Completer<System?>();
    var systemCalls = 0;
    final c = controller(
      source(system: () {
        systemCalls++;
        return pending.future;
      }),
      interval: const Duration(seconds: 1),
    );
    final first = c.loadInitial();
    c.startAutoRefresh();
    await tester.pump(const Duration(seconds: 4));
    expect(systemCalls, 1);
    pending.complete(System(model: 'completed'));
    await first;
    expect(c.system.value?.model, 'completed');
    expect(systemCalls, 1);
    c.stopAutoRefresh();
    c.dispose();
  }, timeout: const Timeout(Duration(seconds: 15)));

  testWidgets('changing cadence replaces timer instead of duplicating it',
      (tester) async {
    var systemCalls = 0;
    final c = controller(
      source(system: () async {
        systemCalls++;
        return System();
      }),
      interval: const Duration(seconds: 10),
    );
    c.startAutoRefresh();
    c.updateRefreshInterval(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(systemCalls, 1);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(systemCalls, 2);
    c.stopAutoRefresh();
    await tester.pump(const Duration(seconds: 10));
    expect(systemCalls, 2);
    c.dispose();
  }, timeout: const Timeout(Duration(seconds: 15)));
}
