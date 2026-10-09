import 'package:dsm_helper/models/Syno/Core/CurrentConnection.dart';
import 'package:dsm_helper/models/Syno/Core/Notify.dart';
import 'package:dsm_helper/models/Syno/Core/TaskScheduler.dart';
import 'package:dsm_helper/models/Syno/Core/System.dart';
import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';

typedef OverviewSystemLoader = Future<System?> Function();
typedef OverviewUtilizationLoader = Future<Utilization?> Function();
typedef OverviewStorageLoader = Future<Storage?> Function();
typedef OverviewNotificationLoader = Future<DsmNotify?> Function();
typedef OverviewCurrentConnectionLoader = Future<CurrentConnection?> Function();
typedef OverviewTaskSchedulerLoader = Future<TaskScheduler?> Function();

class OverviewDataSource {
  const OverviewDataSource({
    required this.loadSystem,
    required this.loadUtilization,
    required this.loadStorage,
    required this.loadNotifications,
    this.loadCurrentConnections = CurrentConnection.get,
    this.loadTaskScheduler = TaskScheduler.list,
  });

  factory OverviewDataSource.production() => OverviewDataSource(
        loadSystem: System.info,
        loadUtilization: Utilization.get,
        loadStorage: Storage.loadInfo,
        loadNotifications: DsmNotify.notify,
        loadCurrentConnections: CurrentConnection.get,
        loadTaskScheduler: TaskScheduler.list,
      );

  final OverviewSystemLoader loadSystem;
  final OverviewUtilizationLoader loadUtilization;
  final OverviewStorageLoader loadStorage;
  final OverviewNotificationLoader loadNotifications;
  final OverviewCurrentConnectionLoader loadCurrentConnections;
  final OverviewTaskSchedulerLoader loadTaskScheduler;
}
