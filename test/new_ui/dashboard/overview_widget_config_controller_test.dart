import 'dart:async';

import 'package:dsm_helper/new_ui/dashboard/overview_widget_config_controller.dart';
import 'package:flutter_test/flutter_test.dart';

const connection = 'SYNO.SDS.SystemInfoApp.ConnectionLogWidget';
const scheduler = 'SYNO.SDS.TaskScheduler.TaskSchedulerWidget';
const core = 'SYNO.SDS.ResourceMonitor.Widget';
const opaque = 'custom.thirdParty.UnrecognizedWidget';
const deferred = 'SYNO.SDS.SystemInfoApp.RecentLogWidget';

void main() {
  test('only owned extensions are editable and in DSM order', () {
    final controller = OverviewWidgetConfigController(
      originalModuleIds: [core, scheduler, opaque, connection, deferred],
      saveModuleIds: (_) async => true,
    );
    expect(controller.selectedOwnedIds, [scheduler, connection]);
    controller.setVisible(opaque, false);
    controller.setVisible(core, true);
    controller.setVisible(scheduler, true);
    expect(controller.selectedOwnedIds, [scheduler, connection]);
    controller.setVisible(scheduler, false);
    expect(controller.selectedOwnedIds, [connection]);
    controller.setVisible(scheduler, true);
    expect(controller.selectedOwnedIds, [connection, scheduler]);
    controller.dispose();
  });

  test('reorder changes only currently selected owned extensions', () {
    final controller = OverviewWidgetConfigController(
      originalModuleIds: [core, connection, opaque, scheduler],
      saveModuleIds: (_) async => true,
    );
    controller.reorder(0, 2);
    expect(controller.selectedOwnedIds, [scheduler, connection]);
    controller.reorder(42, 0);
    controller.reorder(0, 42);
    expect(controller.selectedOwnedIds, [scheduler, connection]);
    controller.dispose();
  });

  test('successful save sends all merged IDs and returns persisted list', () async {
    final calls = <List<String>>[];
    final controller = OverviewWidgetConfigController(
      originalModuleIds: [core, connection, deferred, opaque, scheduler],
      saveModuleIds: (ids) async {
        calls.add(List.of(ids));
        return true;
      },
    );
    controller.reorder(0, 2);
    final saved = await controller.save();
    expect(saved, [core, scheduler, deferred, opaque, connection]);
    expect(calls, [saved]);
    expect(controller.error, isNull);
    expect(controller.saving, isFalse);
    controller.dispose();
  });

  test('false save retains original DSM authority; retry merges against it', () async {
    final calls = <List<String>>[];
    var attempts = 0;
    final controller = OverviewWidgetConfigController(
      originalModuleIds: [core, connection, opaque, scheduler, deferred],
      saveModuleIds: (ids) async {
        calls.add(List.of(ids));
        attempts++;
        return attempts == 2;
      },
    );
    controller.setVisible(connection, false);
    expect(await controller.save(), isNull);
    expect(controller.error, isNotNull);
    expect(controller.saving, isFalse);
    controller.setVisible(connection, true);
    expect(await controller.save(), [core, scheduler, opaque, connection, deferred]);
    expect(calls.first, [core, scheduler, opaque, deferred]);
    expect(calls.last, [core, scheduler, opaque, connection, deferred]);
    expect(controller.error, isNull);
    controller.dispose();
  });

  test('exception and null save results are failures, not successful writes', () async {
    var attempts = 0;
    final controller = OverviewWidgetConfigController(
      originalModuleIds: [core, connection, opaque],
      saveModuleIds: (_) async {
        attempts++;
        if (attempts == 1) throw StateError('DSM unavailable');
        return null;
      },
    );
    expect(await controller.save(), isNull);
    expect(controller.error, isA<StateError>());
    expect(await controller.save(), isNull);
    expect(controller.error, isNotNull);
    controller.dispose();
  });

  test('concurrent save does not issue a second DSM write', () async {
    final pending = Completer<bool?>();
    var calls = 0;
    final controller = OverviewWidgetConfigController(
      originalModuleIds: [core, connection],
      saveModuleIds: (_) {
        calls++;
        return pending.future;
      },
    );
    final first = controller.save();
    expect(controller.saving, isTrue);
    expect(await controller.save(), isNull);
    expect(calls, 1);
    controller.setVisible(scheduler, true);
    expect(controller.selectedOwnedIds, [connection]);
    pending.complete(true);
    expect(await first, [core, connection]);
    expect(controller.saving, isFalse);
    controller.dispose();
  });
}
