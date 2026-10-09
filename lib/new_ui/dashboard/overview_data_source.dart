import 'package:dsm_helper/models/Syno/Core/Notify.dart';
import 'package:dsm_helper/models/Syno/Core/System.dart';
import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';

typedef OverviewSystemLoader = Future<System?> Function();
typedef OverviewUtilizationLoader = Future<Utilization?> Function();
typedef OverviewStorageLoader = Future<Storage?> Function();
typedef OverviewNotificationLoader = Future<DsmNotify?> Function();

class OverviewDataSource {
  const OverviewDataSource({
    required this.loadSystem,
    required this.loadUtilization,
    required this.loadStorage,
    required this.loadNotifications,
  });

  factory OverviewDataSource.production() => OverviewDataSource(
        loadSystem: System.info,
        loadUtilization: Utilization.get,
        loadStorage: Storage.loadInfo,
        loadNotifications: DsmNotify.notify,
      );

  final OverviewSystemLoader loadSystem;
  final OverviewUtilizationLoader loadUtilization;
  final OverviewStorageLoader loadStorage;
  final OverviewNotificationLoader loadNotifications;
}
