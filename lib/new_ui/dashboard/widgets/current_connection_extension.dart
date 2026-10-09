import 'package:dsm_helper/models/Syno/Core/CurrentConnection.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_source_state.dart';
import 'package:flutter/material.dart';

class CurrentConnectionExtension extends StatelessWidget {
  const CurrentConnectionExtension({
    super.key,
    required this.state,
  });

  final OverviewSourceState<CurrentConnection> state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = state.value;
    final items = value?.items ?? const <UserItems>[];

    return Column(
      key: const Key('overview-current-connections'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('当前连接', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildBody(context, items),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, List<UserItems> items) {
    final theme = Theme.of(context);
    if (!state.hasValue) {
      String message;
      if (state.phase == OverviewSourcePhase.initial ||
          state.phase == OverviewSourcePhase.loading) {
        message = '当前连接加载中';
      } else if (state.phase == OverviewSourcePhase.error) {
        message = '当前连接加载失败';
      } else if (state.phase == OverviewSourcePhase.unavailable) {
        message = '当前连接不可用';
      } else {
        message = '暂无当前连接';
      }
      return Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final children = <Widget>[];
    if (items.isEmpty) {
      children.add(
        Text(
          '暂无当前连接',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    } else {
      children.add(
        Text(
          '${state.value?.total ?? items.length} 个连接',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
      children.add(const SizedBox(height: 8));
      for (var index = 0; index < items.length; index++) {
        if (index > 0) children.add(const Divider(height: 16));
        children.add(_ConnectionRow(item: items[index]));
      }
    }
    if (state.phase == OverviewSourcePhase.stale) {
      children.add(const SizedBox(height: 8));
      children.add(
        Text(
          '当前连接数据已过期',
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

class _ConnectionRow extends StatelessWidget {
  const _ConnectionRow({required this.item});

  final UserItems item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            item.who ?? '未知用户',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            item.from ?? '未知来源',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
