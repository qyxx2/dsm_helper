import 'dart:async';

import 'package:dsm_helper/new_ui/dashboard/overview_alerts.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_controller.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_source_state.dart';
import 'package:dsm_helper/new_ui/dashboard/widgets/abnormal_summary.dart';
import 'package:dsm_helper/new_ui/dashboard/widgets/core_resource_section.dart';
import 'package:dsm_helper/new_ui/dashboard/widgets/device_summary.dart';
import 'package:dsm_helper/providers/init_data_provider.dart';
import 'package:dsm_helper/providers/setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef OverviewControllerFactory = OverviewController Function(
  Duration refreshInterval,
);

/// Fixed Overview core before the Task 5 shell cutover. The controller is
/// owned by this page; the existing DSM providers remain read authorities.
class OverviewPage extends StatefulWidget {
  const OverviewPage({
    super.key,
    required this.controllerFactory,
    required this.onOpenNotifications,
    this.onOpenAlertDestination,
    this.connectionStatusText,
  });

  final OverviewControllerFactory controllerFactory;
  final VoidCallback onOpenNotifications;
  final ValueChanged<OverviewAlertDestination>? onOpenAlertDestination;
  final String? connectionStatusText;

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  OverviewController? _controller;
  Duration? _refreshInterval;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final interval = Duration(
      seconds: context.watch<SettingProvider>().refreshDuration,
    );

    if (_controller == null) {
      _refreshInterval = interval;
      _controller = widget.controllerFactory(interval);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final controller = _controller;
        if (controller == null) return;
        unawaited(controller.loadInitial());
        controller.startAutoRefresh();
      });
    } else if (_refreshInterval != interval) {
      _refreshInterval = interval;
      _controller!.updateRefreshInterval(interval);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    final hostname = context.watch<InitDataProvider>().initData.session?.hostname;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Flexible(
              child: Text('概览', maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (widget.connectionStatusText != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.connectionStatusText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            key: const Key('new-ui-notifications'),
            tooltip: '通知',
            onPressed: widget.onOpenNotifications,
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final system = controller.system;
          final utilization = controller.utilization;
          final storage = controller.storage;
          final notifications = controller.notifications;
          final alerts = buildOverviewAlerts(
            storage: storage.value,
            notifications: notifications.value,
          );
          final refreshing = [
            system.phase,
            utilization.phase,
            storage.phase,
          ].contains(OverviewSourcePhase.refreshing);

          final hasCoreData =
              system.hasValue || utilization.hasValue || storage.hasValue;
          final hasInitialError = [
            system.phase,
            utilization.phase,
            storage.phase,
          ].every((phase) => phase == OverviewSourcePhase.error);

          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              key: const Key('overview-scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                DeviceSummary(
                  hostname: hostname,
                  uptime: system.value?.upTime,
                ),
                if (refreshing)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '数据刷新中',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                if (!hasCoreData && hasInitialError) ...[
                  const Text('概览数据加载失败'),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => unawaited(controller.refresh()),
                      child: const Text('重试'),
                    ),
                  ),
                ],
                _SourceFeedback(label: '系统信息', state: system),
                _SourceFeedback(label: '资源', state: utilization),
                _SourceFeedback(label: '存储', state: storage),
                CoreResourceSection(
                  system: system.value,
                  utilization: utilization.value,
                  storage: storage.value,
                ),
                if (alerts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  AbnormalSummary(
                    alerts: alerts,
                    notificationsStale:
                        notifications.phase == OverviewSourcePhase.stale,
                    onOpenDestination: widget.onOpenAlertDestination,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Loading/error/offline information belongs to its source, never another
/// source or an indiscriminate full-page replacement.
class _SourceFeedback extends StatelessWidget {
  const _SourceFeedback({required this.label, required this.state});

  final String label;
  final OverviewSourceState<dynamic> state;

  @override
  Widget build(BuildContext context) {
    final String? message;
    final bool busy;
    switch (state.phase) {
      case OverviewSourcePhase.initial:
      case OverviewSourcePhase.loading:
        message = '$label加载中';
        busy = true;
      case OverviewSourcePhase.stale:
        message = '$label数据已过期';
        busy = false;
      case OverviewSourcePhase.error:
        message = '$label加载失败';
        busy = false;
      case OverviewSourcePhase.unavailable:
        message = '$label不可用';
        busy = false;
      case OverviewSourcePhase.valid:
      case OverviewSourcePhase.refreshing:
        message = null;
        busy = false;
    }
    if (message == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (busy) ...[
            const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: state.phase == OverviewSourcePhase.error
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
