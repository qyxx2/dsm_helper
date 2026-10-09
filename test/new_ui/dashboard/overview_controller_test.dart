import 'dart:async';

import 'package:dsm_helper/apis/dsm_api/dsm_exception.dart';
import 'package:dsm_helper/models/Syno/Core/CurrentConnection.dart';
import 'package:dsm_helper/models/Syno/Core/Notify.dart';
import 'package:dsm_helper/models/Syno/Core/TaskScheduler.dart';
import 'package:dsm_helper/models/Syno/Core/System.dart';
import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_controller.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_data_source.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_source_state.dart';
import 'package:flutter_test/flutter_test.dart';

const currentConnectionModuleId =
    'SYNO.SDS.SystemInfoApp.ConnectionLogWidget';
const taskSchedulerModuleId =
    'SYNO.SDS.TaskScheduler.TaskSchedulerWidget';

OverviewDataSource source({
  OverviewSystemLoader? system,
  OverviewUtilizationLoader? utilization,
  OverviewStorageLoader? storage,
  OverviewNotificationLoader? notifications,
  OverviewCurrentConnectionLoader? currentConnections,
  OverviewTaskSchedulerLoader? taskScheduler,
}) =>
    OverviewDataSource(
      loadSystem: system ?? () async => System(model: 'NAS'),
      loadUtilization: utilization ?? () async => Utilization(),
      loadStorage: storage ?? () async => Storage(),
      loadNotifications:
          notifications ?? () async => DsmNotify(items: <DsmNotifyItems>[]),
      loadCurrentConnections:
          currentConnections ?? () async => CurrentConnection(),
      loadTaskScheduler: taskScheduler ?? () async => TaskScheduler(),
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

  test('each core source failure remains local to that source', () async {
    for (final failed in <String>[
      'system',
      'utilization',
      'storage',
      'notifications',
    ]) {
      final c = controller(source(
        system: () async {
          if (failed == 'system') throw StateError('system failed');
          return System(model: 'valid');
        },
        utilization: () async {
          if (failed == 'utilization') throw StateError('utilization failed');
          return Utilization();
        },
        storage: () async {
          if (failed == 'storage') throw StateError('storage failed');
          return Storage();
        },
        notifications: () async {
          if (failed == 'notifications') throw StateError('notifications failed');
          return DsmNotify(items: <DsmNotifyItems>[]);
        },
      ));
      await c.loadInitial();

      expect(c.system.phase, failed == 'system'
          ? OverviewSourcePhase.error : OverviewSourcePhase.valid);
      expect(c.utilization.phase, failed == 'utilization'
          ? OverviewSourcePhase.error : OverviewSourcePhase.valid);
      expect(c.storage.phase, failed == 'storage'
          ? OverviewSourcePhase.error : OverviewSourcePhase.valid);
      expect(c.notifications.phase, failed == 'notifications'
          ? OverviewSourcePhase.error : OverviewSourcePhase.valid);
      expect(<OverviewSourceState<Object?>>[
        c.system,
        c.utilization,
        c.storage,
        c.notifications,
      ].where((state) => state.phase == OverviewSourcePhase.valid).length, 3);
      c.dispose();
    }
  });

  test('refresh holds V1 while pending, retains stale V1, then accepts V2',
      () async {
    Future<System?> Function() loader =
        () async => System(model: 'V1');
    final c = controller(source(system: () => loader()));
    await c.loadInitial();
    final initialUpdatedAt = c.system.updatedAt;

    final pending = Completer<System?>();
    loader = () => pending.future;
    final refreshing = c.refresh();
    expect(c.system.phase, OverviewSourcePhase.refreshing);
    expect(c.system.value?.model, 'V1');
    expect(c.system.updatedAt, initialUpdatedAt);

    pending.completeError(StateError('temporary failure'));
    await refreshing;
    expect(c.system.phase, OverviewSourcePhase.stale);
    expect(c.system.value?.model, 'V1');
    expect(c.system.updatedAt, initialUpdatedAt);

    loader = () async => System(model: 'V2');
    await c.refresh();
    expect(c.system.phase, OverviewSourcePhase.valid);
    expect(c.system.value?.model, 'V2');
    expect(c.system.error, isNull);
    c.dispose();
  });

  test('fast sources publish before a slow sibling completes', () async {
    final pendingStorage = Completer<Storage?>();
    final c = controller(source(storage: () => pendingStorage.future));
    final initial = c.loadInitial();
    await Future<void>.delayed(Duration.zero);

    expect(c.storage.phase, OverviewSourcePhase.loading);
    expect(c.system.phase, OverviewSourcePhase.valid);
    expect(c.utilization.phase, OverviewSourcePhase.valid);
    expect(c.notifications.phase, OverviewSourcePhase.valid);

    pendingStorage.complete(Storage());
    await initial;
    expect(c.storage.phase, OverviewSourcePhase.valid);
    c.dispose();
  });

  test('storage and notifications can become stale without affecting CPU',
      () async {
    var fail = false;
    final c = controller(source(
      storage: () async {
        if (fail) throw StateError('storage unavailable');
        return Storage();
      },
      notifications: () async {
        if (fail) throw StateError('notifications unavailable');
        return DsmNotify(items: <DsmNotifyItems>[]);
      },
    ));
    await c.loadInitial();
    final storageV1 = c.storage.value;
    final notificationV1 = c.notifications.value;

    fail = true;
    await c.refresh();
    expect(c.system.phase, OverviewSourcePhase.valid);
    expect(c.utilization.phase, OverviewSourcePhase.valid);
    expect(c.storage.phase, OverviewSourcePhase.stale);
    expect(identical(c.storage.value, storageV1), isTrue);
    expect(c.notifications.phase, OverviewSourcePhase.stale);
    expect(identical(c.notifications.value, notificationV1), isTrue);
    c.dispose();
  });

  test('disabled extensions never invoke their loaders', () async {
    var connectionCalls = 0;
    var schedulerCalls = 0;
    final c = controller(source(
      currentConnections: () async {
        connectionCalls++;
        return CurrentConnection();
      },
      taskScheduler: () async {
        schedulerCalls++;
        return TaskScheduler();
      },
    ));

    await c.loadInitial();

    expect(connectionCalls, 0);
    expect(schedulerCalls, 0);
    expect(c.currentConnections.phase, OverviewSourcePhase.initial);
    expect(c.taskScheduler.phase, OverviewSourcePhase.initial);
    c.dispose();
  });

  test('each extension can be selected independently', () async {
    for (final selected in <String>[
      currentConnectionModuleId,
      taskSchedulerModuleId,
    ]) {
      var connectionCalls = 0;
      var schedulerCalls = 0;
      final c = controller(source(
        currentConnections: () async {
          connectionCalls++;
          return CurrentConnection();
        },
        taskScheduler: () async {
          schedulerCalls++;
          return TaskScheduler();
        },
      ));
      c.updateEnabledExtensions(<String>{selected});

      await c.loadInitial();

      expect(
        connectionCalls,
        selected == currentConnectionModuleId ? 1 : 0,
      );
      expect(
        schedulerCalls,
        selected == taskSchedulerModuleId ? 1 : 0,
      );
      c.dispose();
    }
  });

  test('both selected extensions publish successful empty values', () async {
    final c = controller(source(
      currentConnections: () async =>
          CurrentConnection(items: <UserItems>[], total: 0),
      taskScheduler: () async => TaskScheduler(tasks: <Tasks>[], total: 0),
    ));
    c.updateEnabledExtensions(
      <String>{currentConnectionModuleId, taskSchedulerModuleId},
    );

    await c.loadInitial();

    expect(c.currentConnections.phase, OverviewSourcePhase.valid);
    expect(c.currentConnections.value?.items, isEmpty);
    expect(c.taskScheduler.phase, OverviewSourcePhase.valid);
    expect(c.taskScheduler.value?.tasks, isEmpty);
    c.dispose();
  });

  test('extension refresh failures retain stale values independently', () async {
    var connectionFail = false;
    var schedulerFail = false;
    final connectionV1 =
        CurrentConnection(items: <UserItems>[UserItems(who: 'alice')], total: 1);
    final schedulerV1 =
        TaskScheduler(tasks: <Tasks>[Tasks(name: 'backup')], total: 1);
    final c = controller(source(
      currentConnections: () async {
        if (connectionFail) throw StateError('connections failed');
        return connectionV1;
      },
      taskScheduler: () async {
        if (schedulerFail) throw StateError('scheduler failed');
        return schedulerV1;
      },
    ));
    c.updateEnabledExtensions(
      <String>{currentConnectionModuleId, taskSchedulerModuleId},
    );
    await c.loadInitial();

    connectionFail = true;
    await c.refresh();
    expect(c.currentConnections.phase, OverviewSourcePhase.stale);
    expect(identical(c.currentConnections.value, connectionV1), isTrue);
    expect(c.taskScheduler.phase, OverviewSourcePhase.valid);

    connectionFail = false;
    schedulerFail = true;
    await c.refresh();
    expect(c.currentConnections.phase, OverviewSourcePhase.valid);
    expect(c.taskScheduler.phase, OverviewSourcePhase.stale);
    expect(identical(c.taskScheduler.value, schedulerV1), isTrue);
    c.dispose();
  });

  test('enabling while mounted starts loading and disabling stops future loads',
      () async {
    var connectionCalls = 0;
    final c = controller(source(
      currentConnections: () async {
        connectionCalls++;
        return CurrentConnection(total: connectionCalls);
      },
    ));
    await c.loadInitial();
    expect(connectionCalls, 0);

    c.updateEnabledExtensions(<String>{currentConnectionModuleId});
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(connectionCalls, 1);
    expect(c.currentConnections.phase, OverviewSourcePhase.valid);

    c.updateEnabledExtensions(<String>{});
    expect(c.currentConnections.phase, OverviewSourcePhase.initial);
    expect(c.currentConnections.value, isNull);
    await c.refresh();
    expect(connectionCalls, 1);
    c.dispose();
  });

  testWidgets('automatic ticks share the in-flight extension refresh owner',
      (tester) async {
    final pending = Completer<CurrentConnection?>();
    var connectionCalls = 0;
    final c = controller(
      source(currentConnections: () {
        connectionCalls++;
        return pending.future;
      }),
      interval: const Duration(seconds: 1),
    );
    c.updateEnabledExtensions(<String>{currentConnectionModuleId});

    final first = c.loadInitial();
    c.startAutoRefresh();
    await tester.pump(const Duration(seconds: 4));
    expect(connectionCalls, 1);

    pending.complete(CurrentConnection(total: 1));
    await first;
    expect(c.currentConnections.phase, OverviewSourcePhase.valid);
    expect(connectionCalls, 1);
    c.stopAutoRefresh();
    c.dispose();
  }, timeout: const Timeout(Duration(seconds: 15)));

  test('disabled extension ignores a delayed result from the old selection',
      () async {
    final pending = Completer<CurrentConnection?>();
    final c = controller(source(
      currentConnections: () => pending.future,
    ));
    c.updateEnabledExtensions(<String>{currentConnectionModuleId});

    final first = c.loadInitial();
    await Future<void>.delayed(Duration.zero);
    expect(c.currentConnections.phase, OverviewSourcePhase.loading);

    c.updateEnabledExtensions(<String>{});
    expect(c.currentConnections.phase, OverviewSourcePhase.initial);
    pending.complete(
      CurrentConnection(
        items: <UserItems>[UserItems(who: 'late-user')],
        total: 1,
      ),
    );
    await first;

    expect(c.currentConnections.phase, OverviewSourcePhase.initial);
    expect(c.currentConnections.value, isNull);
    c.dispose();
  });

}
