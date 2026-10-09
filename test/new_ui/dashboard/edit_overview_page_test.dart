import 'dart:async';

import 'package:dsm_helper/new_ui/dashboard/edit_overview_page.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_widget_config_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const connection = 'SYNO.SDS.SystemInfoApp.ConnectionLogWidget';
const scheduler = 'SYNO.SDS.TaskScheduler.TaskSchedulerWidget';
const core = 'SYNO.SDS.SystemInfoApp.SystemHealthWidget';
const deferred = 'SYNO.SDS.SystemInfoApp.RecentLogWidget';
const opaque = 'vendor.UnknownExtension';

Widget _host(OverviewWidgetConfigController controller) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          key: const Key('launch-editor'),
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => EditOverviewPage(controller: controller),
            ),
          ),
          child: const Text('打开编辑'),
        ),
      ),
    ),
  );
}

Future<void> _open(WidgetTester tester, OverviewWidgetConfigController controller) async {
  await tester.pumpWidget(_host(controller));
  await tester.tap(find.byKey(const Key('launch-editor')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('only two owned extension controls are shown; unknown/core/deferred are absent',
      (tester) async {
    final controller = OverviewWidgetConfigController(
      originalModuleIds: [core, connection, opaque, deferred, scheduler],
      saveModuleIds: (_) async => true,
    );
    await _open(tester, controller);
    expect(find.text('编辑概览'), findsOneWidget);
    expect(find.text('当前连接'), findsOneWidget);
    expect(find.text('计划任务'), findsOneWidget);
    expect(find.byKey(const Key('overview-visible-$connection')), findsOneWidget);
    expect(find.byKey(const Key('overview-visible-$scheduler')), findsOneWidget);
    expect(find.text(core), findsNothing);
    expect(find.text(deferred), findsNothing);
    expect(find.text(opaque), findsNothing);
    expect(find.byKey(const Key('overview-reorder-$connection')), findsOneWidget);
    expect(find.byKey(const Key('overview-reorder-$scheduler')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('hide then show controls which selected extension has a reorder handle',
      (tester) async {
    final controller = OverviewWidgetConfigController(
      originalModuleIds: [core, connection, deferred, scheduler],
      saveModuleIds: (_) async => true,
    );
    await _open(tester, controller);
    await tester.tap(find.byKey(const Key('overview-visible-$scheduler')));
    await tester.pump();
    expect(controller.selectedOwnedIds, [connection]);
    expect(find.byKey(const Key('overview-reorder-$scheduler')), findsNothing);
    await tester.tap(find.byKey(const Key('overview-visible-$scheduler')));
    await tester.pump();
    expect(controller.selectedOwnedIds, [connection, scheduler]);
    expect(find.byKey(const Key('overview-reorder-$scheduler')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('reorder handle changes order of selected extensions only',
      (tester) async {
    final controller = OverviewWidgetConfigController(
      originalModuleIds: [core, connection, opaque, scheduler],
      saveModuleIds: (_) async => true,
    );
    await _open(tester, controller);
    await tester.drag(find.byKey(const Key('overview-reorder-$connection')), const Offset(0, 120));
    await tester.pumpAndSettle();
    expect(controller.selectedOwnedIds, [scheduler, connection]);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('saving disables save and shows progress until server success',
      (tester) async {
    final pending = Completer<bool?>();
    final calls = <List<String>>[];
    final controller = OverviewWidgetConfigController(
      originalModuleIds: [core, connection, opaque, scheduler],
      saveModuleIds: (ids) {
        calls.add(List.of(ids));
        return pending.future;
      },
    );
    await _open(tester, controller);
    await tester.tap(find.byKey(const Key('overview-visible-$connection')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('overview-edit-save')));
    await tester.pump();
    expect(calls.single, [core, opaque, scheduler]);
    expect(find.byKey(const Key('overview-edit-saving')), findsOneWidget);
    final save = tester.widget<FilledButton>(find.byKey(const Key('overview-edit-save')));
    expect(save.onPressed, isNull);
    pending.complete(true);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('launch-editor')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('failed save remains editable and leaves route open', (tester) async {
    final controller = OverviewWidgetConfigController(
      originalModuleIds: [core, connection, opaque],
      saveModuleIds: (_) async => false,
    );
    await _open(tester, controller);
    await tester.tap(find.byKey(const Key('overview-edit-save')));
    await tester.pumpAndSettle();
    expect(find.text('编辑概览'), findsOneWidget);
    expect(find.text('保存失败，请重试'), findsOneWidget);
    expect(find.byKey(const Key('overview-edit-save')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('cancel does not call DSM saver and returns to Overview host',
      (tester) async {
    var calls = 0;
    final controller = OverviewWidgetConfigController(
      originalModuleIds: [core, scheduler, opaque],
      saveModuleIds: (_) async {
        calls++;
        return true;
      },
    );
    await _open(tester, controller);
    await tester.tap(find.byKey(const Key('overview-visible-$scheduler')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('overview-edit-cancel')));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.byKey(const Key('launch-editor')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  }, timeout: const Timeout(Duration(seconds: 20)));
}
