import 'dart:convert';

import 'package:dsm_helper/models/Syno/Core/Notify.dart';
import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';
import 'package:dsm_helper/pages/dashboard/enums/volume_status_enum.dart';

enum OverviewAlertSeverity { warning, error }

enum OverviewAlertDestination { notifications, storageManager }

class OverviewAlert {
  const OverviewAlert({
    required this.id,
    required this.title,
    required this.severity,
    required this.destination,
  });

  final String id;
  final String title;
  final OverviewAlertSeverity severity;
  final OverviewAlertDestination destination;
}

/// Classifies only explicit DSM severity. Unknown or missing source data does
/// not imply a healthy value, an error, or a locally invented capacity limit.
List<OverviewAlert> buildOverviewAlerts({
  Storage? storage,
  DsmNotify? notifications,
}) {
  final errors = <OverviewAlert>[];
  final warnings = <OverviewAlert>[];

  final seenVolumes = <String>{};
  final volumes = storage?.volumes ?? const <Volumes>[];
  for (var index = 0; index < volumes.length; index++) {
    final volume = volumes[index];
    final status = volume.status;
    if (status == null) continue;
    final volumeStatus = VolumeStatusEnum.fromValue(status);
    final OverviewAlertSeverity severity;
    switch (volumeStatus) {
      case VolumeStatusEnum.danger:
        severity = OverviewAlertSeverity.error;
      case VolumeStatusEnum.attention:
      case VolumeStatusEnum.has_unverified_disk:
      case VolumeStatusEnum.read_only:
        severity = OverviewAlertSeverity.warning;
      case VolumeStatusEnum.normal:
      case VolumeStatusEnum.background:
      case VolumeStatusEnum.background_scrubbing:
      case VolumeStatusEnum.unknown:
        continue;
    }

    final identity = volume.id?.trim();
    if (identity != null && identity.isNotEmpty &&
        !seenVolumes.add(identity)) {
      continue;
    }
    final name = volume.displayName.trim();
    final alert = OverviewAlert(
      id: 'storage:${identity == null || identity.isEmpty ? index : identity}',
      title: '${name.isEmpty ? '存储空间' : name} · ${volumeStatus.label}',
      severity: severity,
      destination: OverviewAlertDestination.storageManager,
    );
    if (severity == OverviewAlertSeverity.error) {
      errors.add(alert);
    } else {
      warnings.add(alert);
    }
  }

  final seenNotifications = <String>{};
  final items = notifications?.items ?? const <DsmNotifyItems>[];
  for (var index = 0; index < items.length; index++) {
    final item = items[index];
    final OverviewAlertSeverity severity;
    switch (item.level) {
      case 'NOTIFICATION_ERROR':
        severity = OverviewAlertSeverity.error;
      case 'NOTIFICATION_WARN':
        severity = OverviewAlertSeverity.warning;
      default:
        continue;
    }

    final title = item.title?.trim();
    // Timestamp + title + source/context identify a specific DSM event.
    // Without both, keep separate entries rather than merging unrelated data.
    final identity = title != null && title.isNotEmpty && item.time != null
        ? jsonEncode([
            item.level, title, item.time, item.className, item.msg ?? const <String>[],
          ])
        : null;
    if (identity != null && !seenNotifications.add(identity)) continue;
    final alert = OverviewAlert(
      id: identity == null ? 'notification:$index' : 'notification:$identity',
      title: title == null || title.isEmpty
          ? (severity == OverviewAlertSeverity.error
              ? 'DSM 错误通知'
              : 'DSM 警告通知')
          : title,
      severity: severity,
      destination: OverviewAlertDestination.notifications,
    );
    if (severity == OverviewAlertSeverity.error) {
      errors.add(alert);
    } else {
      warnings.add(alert);
    }
  }

  return [...errors, ...warnings];
}
