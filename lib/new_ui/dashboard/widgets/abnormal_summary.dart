import 'package:dsm_helper/new_ui/dashboard/overview_alerts.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';

/// Conditional, read-only summary. Navigation is owned by the calling shell,
/// and is disabled until that explicit destination callback is supplied.
class AbnormalSummary extends StatelessWidget {
  const AbnormalSummary({
    super.key,
    required this.alerts,
    this.onOpenDestination,
    this.notificationsStale = false,
  });

  final List<OverviewAlert> alerts;
  final ValueChanged<OverviewAlertDestination>? onOpenDestination;
  final bool notificationsStale;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final semantics = theme.extension<NewUiSemanticColors>() ??
        (theme.brightness == Brightness.dark
            ? NewUiSemanticColors.dark
            : NewUiSemanticColors.light);

    return Column(
      key: const Key('overview-abnormal-summary'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('异常提醒', style: theme.textTheme.titleMedium),
        ),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < alerts.length; index++) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: theme.colorScheme.outlineVariant,
                  ),
                _AlertRow(
                  alert: alerts[index],
                  warningColor: semantics.warning,
                  onOpenDestination: onOpenDestination,
                ),
              ],
              if (notificationsStale) ...[
                const Divider(height: 1, indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '通知数据已过期',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.alert,
    required this.warningColor,
    required this.onOpenDestination,
  });

  final OverviewAlert alert;
  final Color warningColor;
  final ValueChanged<OverviewAlertDestination>? onOpenDestination;

  @override
  Widget build(BuildContext context) {
    final isError = alert.severity == OverviewAlertSeverity.error;
    final theme = Theme.of(context);
    final label = isError ? '错误' : '警告';
    return ListTile(
      key: Key('overview-alert-${alert.id}'),
      dense: true,
      leading: Icon(
        isError ? Icons.error_outline : Icons.warning_amber_outlined,
        color: isError ? theme.colorScheme.error : warningColor,
        semanticLabel: label,
      ),
      title: Text(alert.title),
      subtitle: Text(label, style: theme.textTheme.bodySmall),
      trailing: onOpenDestination == null
          ? null
          : const Icon(Icons.chevron_right),
      onTap: onOpenDestination == null
          ? null
          : () => onOpenDestination!(alert.destination),
    );
  }
}
