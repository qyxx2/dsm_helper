import 'package:dsm_helper/new_ui/dashboard/overview_widget_config.dart';
import 'package:flutter_test/flutter_test.dart';

const connection = 'SYNO.SDS.SystemInfoApp.ConnectionLogWidget';
const scheduler = 'SYNO.SDS.TaskScheduler.TaskSchedulerWidget';
const health = 'SYNO.SDS.SystemInfoApp.SystemHealthWidget';
const resource = 'SYNO.SDS.ResourceMonitor.Widget';
const storage = 'SYNO.SDS.SystemInfoApp.StorageUsageWidget';
const recentLog = 'SYNO.SDS.SystemInfoApp.RecentLogWidget';
const fileLog = 'SYNO.SDS.SystemInfoApp.FileChangeLogWidget';
const opaque = 'vendor.future.UnknownWidget';

void main() {
  test('only the two frozen extension IDs are Task 5 owned', () {
    expect(task5OwnedOverviewWidgetIds, [connection, scheduler]);
  });

  test('reorders owned slots without moving any core/deferred/opaque ID', () {
    expect(
      mergeTask5OverviewModuleIds(
        originalModuleIds: [
          health, connection, resource, recentLog, opaque,
          scheduler, fileLog, storage,
        ],
        editedOwnedIds: [scheduler, connection],
      ),
      [
        health, scheduler, resource, recentLog, opaque,
        connection, fileLog, storage,
      ],
    );
  });

  test('removal discards only unselected owned slots', () {
    expect(
      mergeTask5OverviewModuleIds(
        originalModuleIds: [
          health, connection, fileLog, opaque, scheduler, storage,
        ],
        editedOwnedIds: [scheduler],
      ),
      [health, scheduler, fileLog, opaque, storage],
    );
  });

  test('new owned ID is inserted immediately after last original owned slot', () {
    expect(
      mergeTask5OverviewModuleIds(
        originalModuleIds: [health, connection, opaque, recentLog],
        editedOwnedIds: [scheduler, connection],
      ),
      [health, scheduler, connection, opaque, recentLog],
    );
  });

  test('new owned IDs append when original has no owned slots', () {
    expect(
      mergeTask5OverviewModuleIds(
        originalModuleIds: [health, fileLog, opaque, resource],
        editedOwnedIds: [scheduler, connection],
      ),
      [health, fileLog, opaque, resource, scheduler, connection],
    );
  });

  test('duplicate selections cannot duplicate an owned widget', () {
    final merged = mergeTask5OverviewModuleIds(
      originalModuleIds: [health, connection, recentLog, scheduler, opaque],
      editedOwnedIds: [scheduler, scheduler, connection, connection],
    );
    expect(merged, [health, scheduler, recentLog, connection, opaque]);
    expect(merged.toSet().length, merged.length);
  });

  test('unowned inputs cannot be inserted by edited subsequence', () {
    expect(
      mergeTask5OverviewModuleIds(
        originalModuleIds: [health, opaque, connection],
        editedOwnedIds: [opaque, scheduler, resource],
      ),
      [health, opaque, scheduler],
    );
  });
}
