import 'dart:async';

import 'package:dsm_helper/models/Syno/Core/TaskScheduler.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_source_state.dart';
import 'package:dsm_helper/new_ui/dashboard/widgets/task_scheduler_extension.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(OverviewSourceState<TaskScheduler> state) {
  return MaterialApp(
    theme: NewUiTheme.light(),
    home: Scaffold(
      body: SingleChildScrollView(
        child: TaskSchedulerExtension(state: state),
      ),
    ),
  );
}

void main() {
  testWidgets('successful empty means no scheduled tasks', (tester) async {
    await tester.pumpWidget(_host(
      OverviewSourceState<TaskScheduler>(
        phase: OverviewSourcePhase.valid,
        value: TaskScheduler(tasks: <Tasks>[], total: 0),
      ),
    ));

    expect(find.byKey(const Key('overview-task-scheduler')), findsOneWidget);
    expect(find.text('计划任务'), findsOneWidget);
    expect(find.text('暂无计划任务'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('compact summary uses real name next trigger and enabled state',
      (tester) async {
    await tester.pumpWidget(_host(
      OverviewSourceState<TaskScheduler>(
        phase: OverviewSourcePhase.valid,
        value: TaskScheduler(
          total: 2,
          tasks: <Tasks>[
            Tasks(
              name: 'nightly-backup',
              nextTriggerTime: '2026-10-10 02:00',
              enable: true,
            ),
            Tasks(
              name: 'cleanup',
              nextTriggerTime: 'bootup',
              enable: false,
            ),
          ],
        ),
      ),
    ));

    expect(find.text('nightly-backup'), findsOneWidget);
    expect(find.textContaining('2026-10-10 02:00'), findsOneWidget);
    expect(find.textContaining('已启用'), findsOneWidget);
    expect(find.text('cleanup'), findsOneWidget);
    expect(find.textContaining('开机'), findsOneWidget);
    expect(find.textContaining('已禁用'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('stale prior tasks remain readable with explicit stale label',
      (tester) async {
    await tester.pumpWidget(_host(
      OverviewSourceState<TaskScheduler>(
        phase: OverviewSourcePhase.stale,
        value: TaskScheduler(
          total: 1,
          tasks: <Tasks>[
            Tasks(
              name: 'last-task',
              nextTriggerTime: 'shutdown',
              enable: true,
            ),
          ],
        ),
        error: StateError('temporary failure'),
      ),
    ));

    expect(find.text('last-task'), findsOneWidget);
    expect(find.textContaining('关机'), findsOneWidget);
    expect(find.textContaining('已过期'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('Modern summary exposes no task mutation controls', (tester) async {
    await tester.pumpWidget(_host(
      OverviewSourceState<TaskScheduler>(
        phase: OverviewSourcePhase.valid,
        value: TaskScheduler(
          total: 1,
          tasks: <Tasks>[
            Tasks(
              name: 'mutable-task',
              nextTriggerTime: '2026-10-10 03:00',
              enable: true,
              canRun: true,
              canEdit: true,
              canDelete: true,
            ),
          ],
        ),
      ),
    ));

    expect(find.text('删除'), findsNothing);
    expect(find.text('编辑'), findsNothing);
    expect(find.text('立即运行'), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(IconButton), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 20)));
}
