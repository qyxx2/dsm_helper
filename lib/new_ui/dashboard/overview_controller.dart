import 'dart:async';

import 'package:dsm_helper/apis/dsm_api/dsm_exception.dart';
import 'package:dsm_helper/models/Syno/Core/CurrentConnection.dart';
import 'package:dsm_helper/models/Syno/Core/Notify.dart';
import 'package:dsm_helper/models/Syno/Core/TaskScheduler.dart';
import 'package:dsm_helper/models/Syno/Core/System.dart';
import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_data_source.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_source_state.dart';
import 'package:flutter/foundation.dart';

typedef OverviewAuthInvalidationHandler = void Function(DsmException error);

const _currentConnectionModuleId =
    'SYNO.SDS.SystemInfoApp.ConnectionLogWidget';
const _taskSchedulerModuleId =
    'SYNO.SDS.TaskScheduler.TaskSchedulerWidget';

class OverviewController extends ChangeNotifier {
  OverviewController({
    required OverviewDataSource dataSource,
    required Duration refreshInterval,
    OverviewAuthInvalidationHandler? onAuthInvalidated,
  })  : _dataSource = dataSource,
        _refreshInterval = refreshInterval,
        _onAuthInvalidated = onAuthInvalidated;

  final OverviewDataSource _dataSource;
  final OverviewAuthInvalidationHandler? _onAuthInvalidated;
  Duration _refreshInterval;
  Timer? _timer;
  Future<void>? _inFlight;
  bool _disposed = false;
  bool _authInvalidated = false;
  bool _started = false;
  Set<String> _enabledExtensions = <String>{};
  int _currentConnectionGeneration = 0;
  int _taskSchedulerGeneration = 0;

  OverviewSourceState<System> _system =
      const OverviewSourceState<System>(phase: OverviewSourcePhase.initial);
  OverviewSourceState<Utilization> _utilization =
      const OverviewSourceState<Utilization>(phase: OverviewSourcePhase.initial);
  OverviewSourceState<Storage> _storage =
      const OverviewSourceState<Storage>(phase: OverviewSourcePhase.initial);
  OverviewSourceState<DsmNotify> _notifications =
      const OverviewSourceState<DsmNotify>(phase: OverviewSourcePhase.initial);
  OverviewSourceState<CurrentConnection> _currentConnections =
      const OverviewSourceState<CurrentConnection>(
        phase: OverviewSourcePhase.initial,
      );
  OverviewSourceState<TaskScheduler> _taskScheduler =
      const OverviewSourceState<TaskScheduler>(
        phase: OverviewSourcePhase.initial,
      );

  OverviewSourceState<System> get system => _system;
  OverviewSourceState<Utilization> get utilization => _utilization;
  OverviewSourceState<Storage> get storage => _storage;
  OverviewSourceState<DsmNotify> get notifications => _notifications;
  OverviewSourceState<CurrentConnection> get currentConnections =>
      _currentConnections;
  OverviewSourceState<TaskScheduler> get taskScheduler => _taskScheduler;

  Future<void> loadInitial() {
    _started = true;
    return refresh();
  }

  Future<void> refresh() {
    if (_disposed) return Future<void>.value();
    final running = _inFlight;
    if (running != null) return running;

    final currentConnectionGeneration = _currentConnectionGeneration;
    final taskSchedulerGeneration = _taskSchedulerGeneration;
    final requests = <Future<void>>[
      _refreshSource<System>(
        previous: _system,
        loader: _dataSource.loadSystem,
        publish: (state) => _system = state,
      ),
      _refreshSource<Utilization>(
        previous: _utilization,
        loader: _dataSource.loadUtilization,
        publish: (state) => _utilization = state,
      ),
      _refreshSource<Storage>(
        previous: _storage,
        loader: _dataSource.loadStorage,
        publish: (state) => _storage = state,
      ),
      _refreshSource<DsmNotify>(
        previous: _notifications,
        loader: _dataSource.loadNotifications,
        publish: (state) => _notifications = state,
      ),
      if (_enabledExtensions.contains(_currentConnectionModuleId))
        _refreshSource<CurrentConnection>(
          previous: _currentConnections,
          loader: _dataSource.loadCurrentConnections,
          publish: (state) => _currentConnections = state,
          shouldPublish: () =>
              _enabledExtensions.contains(_currentConnectionModuleId) &&
              _currentConnectionGeneration == currentConnectionGeneration,
        ),
      if (_enabledExtensions.contains(_taskSchedulerModuleId))
        _refreshSource<TaskScheduler>(
          previous: _taskScheduler,
          loader: _dataSource.loadTaskScheduler,
          publish: (state) => _taskScheduler = state,
          shouldPublish: () =>
              _enabledExtensions.contains(_taskSchedulerModuleId) &&
              _taskSchedulerGeneration == taskSchedulerGeneration,
        ),
    ];
    final cycle = Future.wait<void>(requests).then((_) {});
    _inFlight = cycle;
    // The four source requests handle their own failures and publish separately.
    // Clear the cycle only after every source has settled.
    unawaited(cycle.whenComplete(() {
      if (identical(_inFlight, cycle)) _inFlight = null;
    }));
    return cycle;
  }

  Future<void> _refreshSource<T>({
    required OverviewSourceState<T> previous,
    required Future<T?> Function() loader,
    required void Function(OverviewSourceState<T>) publish,
    bool Function()? shouldPublish,
  }) async {
    _publish(
      publish,
      OverviewSourceState<T>(
        phase: previous.hasValue
            ? OverviewSourcePhase.refreshing
            : OverviewSourcePhase.loading,
        value: previous.value,
        updatedAt: previous.updatedAt,
      ),
    );
    try {
      final loaded = await loader();
      if (_disposed || (shouldPublish != null && !shouldPublish())) return;
      _publish(
        publish,
        loaded == null
            ? OverviewSourceState<T>(phase: OverviewSourcePhase.unavailable)
            : OverviewSourceState<T>(
                phase: OverviewSourcePhase.valid,
                value: loaded,
                updatedAt: DateTime.now(),
              ),
      );
    } catch (error) {
      if (_disposed) return;
      if (shouldPublish == null || shouldPublish()) {
        _publish(
          publish,
          OverviewSourceState<T>(
            phase: previous.hasValue
                ? OverviewSourcePhase.stale
                : OverviewSourcePhase.error,
            value: previous.value,
            updatedAt: previous.updatedAt,
            error: error,
          ),
        );
      }
      if (error is DsmException && error.code == 119 && !_authInvalidated) {
        _authInvalidated = true;
        _onAuthInvalidated?.call(error);
      }
    }
  }

  void _publish<T>(
    void Function(OverviewSourceState<T>) write,
    OverviewSourceState<T> state,
  ) {
    if (_disposed) return;
    write(state);
    notifyListeners();
  }

  void updateEnabledExtensions(Set<String> moduleIds) {
    if (_disposed) return;
    final next = moduleIds
        .where((id) =>
            id == _currentConnectionModuleId || id == _taskSchedulerModuleId)
        .toSet();
    if (setEquals(next, _enabledExtensions)) return;

    final hadCurrent =
        _enabledExtensions.contains(_currentConnectionModuleId);
    final hasCurrent = next.contains(_currentConnectionModuleId);
    final hadScheduler =
        _enabledExtensions.contains(_taskSchedulerModuleId);
    final hasScheduler = next.contains(_taskSchedulerModuleId);

    _enabledExtensions = next;
    var resetVisibleState = false;
    var enabledNewExtension = false;

    if (hadCurrent != hasCurrent) {
      _currentConnectionGeneration++;
      if (hasCurrent) {
        enabledNewExtension = true;
      } else {
        _currentConnections = const OverviewSourceState<CurrentConnection>(
          phase: OverviewSourcePhase.initial,
        );
        resetVisibleState = true;
      }
    }
    if (hadScheduler != hasScheduler) {
      _taskSchedulerGeneration++;
      if (hasScheduler) {
        enabledNewExtension = true;
      } else {
        _taskScheduler = const OverviewSourceState<TaskScheduler>(
          phase: OverviewSourcePhase.initial,
        );
        resetVisibleState = true;
      }
    }

    if (resetVisibleState) notifyListeners();
    if (_started && enabledNewExtension) {
      unawaited(refresh());
    }
  }

  void startAutoRefresh() {
    if (_disposed || _timer != null) return;
    _timer = Timer.periodic(_refreshInterval, (_) {
      unawaited(refresh());
    });
  }

  void updateRefreshInterval(Duration refreshInterval) {
    if (_disposed || refreshInterval == _refreshInterval) return;
    _refreshInterval = refreshInterval;
    if (_timer != null) {
      stopAutoRefresh();
      startAutoRefresh();
    }
  }

  void stopAutoRefresh() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    stopAutoRefresh();
    super.dispose();
  }
}
