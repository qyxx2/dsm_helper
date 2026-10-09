import 'package:dsm_helper/models/Syno/Core/TaskScheduler.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_source_state.dart';
import 'package:flutter/material.dart';

class TaskSchedulerExtension extends StatelessWidget {
  const TaskSchedulerExtension({
    super.key,
    required this.state,
  });

  final OverviewSourceState<TaskScheduler> state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = state.value?.tasks ?? const <Tasks>[];

    return Column(
      key: const Key('overview-task-scheduler'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('计划任务', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildBody(context, tasks),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, List<Tasks> tasks) {
    final theme = Theme.of(context);
    if (!state.hasValue) {
      String message;
      if (state.phase == OverviewSourcePhase.initial ||
          state.phase == OverviewSourcePhase.loading) {
        message = '计划任务加载中';
      } else if (state.phase == OverviewSourcePhase.error) {
        message = '计划任务加载失败';
      } else if (state.phase == OverviewSourcePhase.unavailable) {
        message = '计划任务不可用';
      } else {
        message = '暂无计划任务';
      }
      return Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final children = <Widget>[];
    if (tasks.isEmpty) {
      children.add(
        Text(
          '暂无计划任务',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    } else {
      for (var index = 0; index < tasks.length; index++) {
        if (index > 0) children.add(const Divider(height: 16));
        children.add(_TaskRow(task: tasks[index]));
      }
    }
    if (state.phase == OverviewSourcePhase.stale) {
      children.add(const SizedBox(height: 8));
      children.add(
        Text(
          '计划任务数据已过期',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task});

  final Tasks task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = task.enable == true ? '已启用' : '已禁用';
    String trigger;
    if (task.nextTriggerTime == 'bootup') {
      trigger = '开机';
    } else if (task.nextTriggerTime == 'shutdown') {
      trigger = '关机';
    } else if (task.nextTriggerTime != null && task.nextTriggerTime!.isNotEmpty) {
      trigger = task.nextTriggerTime!;
    } else {
      trigger = '未知';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.name ?? '未命名任务',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          '$enabled · 下次运行：$trigger',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
