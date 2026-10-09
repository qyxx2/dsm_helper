import 'package:dsm_helper/models/Syno/Core/Notify.dart';
import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_alerts.dart';
import 'package:flutter_test/flutter_test.dart';

DsmNotifyItems notice(String level, String title, int time,
    {List<String>? message}) {
  return DsmNotifyItems(
    level: level,
    title: title,
    time: time,
    className: 'DSM',
    msg: message,
  );
}

void main() {
  test('healthy, information-only and unavailable inputs produce no alerts', () {
    expect(buildOverviewAlerts(), isEmpty);
    expect(
      buildOverviewAlerts(
        storage: Storage(volumes: [
          Volumes(id: 'volume_1', status: 'normal'),
          Volumes(id: 'volume_2', status: 'background'),
          Volumes(id: 'volume_3', status: 'background_scrubbing'),
          Volumes(id: 'volume_4', status: 'unknown'),
          Volumes(id: 'volume_5', status: 'unexpected_new_status'),
          Volumes(id: 'volume_6'),
        ]),
        notifications: DsmNotify(items: [
          notice('NOTIFICATION_INFO', 'InfoMessage', 1),
          notice('UNKNOWN_LEVEL', 'UnknownMessage', 2),
          notice('NOTIFICATION_WARNED', 'SimilarButUnsupported', 3),
          DsmNotifyItems(level: 'NOTIFICATION_ERROR'),
        ]),
      ),
      isEmpty,
    );
  });

  test('only explicit notification WARN/ERROR map to their DSM severity', () {
    final alerts = buildOverviewAlerts(
      notifications: DsmNotify(items: [
        notice('NOTIFICATION_WARN', 'WarnNotice', 10),
        notice('NOTIFICATION_ERROR', 'ErrorNotice', 11),
        notice('NOTIFICATION_INFO', 'InfoNotice', 12),
      ]),
    );
    expect(alerts, hasLength(2));
    expect(alerts.map((a) => a.severity), [
      OverviewAlertSeverity.error,
      OverviewAlertSeverity.warning,
    ]);
    expect(alerts.map((a) => a.title), ['ErrorNotice', 'WarnNotice']);
    expect(alerts.every(
      (a) => a.destination == OverviewAlertDestination.notifications,
    ), isTrue);
  });

  test('explicit abnormal volume statuses map to error/warning', () {
    final alerts = buildOverviewAlerts(storage: Storage(volumes: [
      Volumes(id: 'volume_1', status: 'attention'),
      Volumes(id: 'volume_2', status: 'danger'),
      Volumes(id: 'volume_3', status: 'has_unverified_disk'),
      Volumes(id: 'volume_4', status: 'read_only'),
    ]));
    expect(alerts, hasLength(4));
    expect(alerts.first.severity, OverviewAlertSeverity.error);
    expect(alerts.first.title, contains('存储空间 2'));
    expect(alerts.skip(1).every(
      (a) => a.severity == OverviewAlertSeverity.warning,
    ), isTrue);
    expect(alerts.every(
      (a) => a.destination == OverviewAlertDestination.storageManager,
    ), isTrue);
  });

  test('storage percent alone never invents an abnormal threshold', () {
    final alerts = buildOverviewAlerts(storage: Storage(volumes: [
      Volumes(
        id: 'volume_1',
        status: 'normal',
        size: Size(total: 100, used: 99),
      ),
    ]));
    expect(alerts, isEmpty);
  });

  test('same stable notification identity is collapsed but distinct events survive', () {
    final repeated = notice(
      'NOTIFICATION_WARN',
      'DriveWarning',
      1600000000,
      message: ['drive-A'],
    );
    final alerts = buildOverviewAlerts(notifications: DsmNotify(items: [
      repeated,
      notice('NOTIFICATION_WARN', 'DriveWarning', 1600000000,
          message: ['drive-A']),
      notice('NOTIFICATION_WARN', 'DriveWarning', 1600000001,
          message: ['drive-A']),
      notice('NOTIFICATION_WARN', 'DriveWarning', 1600000000,
          message: ['drive-B']),
      DsmNotifyItems(level: 'NOTIFICATION_WARN', title: 'NoTime'),
      DsmNotifyItems(level: 'NOTIFICATION_WARN', title: 'NoTime'),
    ]));
    expect(alerts, hasLength(5));
    expect(alerts.map((a) => a.id).toSet(), hasLength(5));
  });

  test('source severity takes priority over source order', () {
    final alerts = buildOverviewAlerts(
      storage: Storage(volumes: [Volumes(id: 'volume_1', status: 'danger')]),
      notifications: DsmNotify(items: [
        notice('NOTIFICATION_WARN', 'Warning', 1),
        notice('NOTIFICATION_ERROR', 'Error', 2),
      ]),
    );
    expect(alerts.map((a) => a.severity), [
      OverviewAlertSeverity.error,
      OverviewAlertSeverity.error,
      OverviewAlertSeverity.warning,
    ]);
  });
}
