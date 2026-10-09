import 'package:dsm_helper/models/Syno/Core/System.dart';
import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';
import 'package:dsm_helper/pages/dashboard/enums/volume_status_enum.dart';
import 'package:flutter/material.dart';

/// The fixed Overview resources: one compact, consistent presentation,
/// independent from legacy Dashboard cards, gauges, and polling widgets.
class CoreResourceSection extends StatelessWidget {
  const CoreResourceSection({
    super.key,
    this.system,
    this.utilization,
    this.storage,
  });

  final System? system;
  final Utilization? utilization;
  final Storage? storage;

  @override
  Widget build(BuildContext context) {
    final cpu = utilization?.cpu;
    final memory = utilization?.memory;
    final volumes = storage?.volumes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ResourceBlock(
          title: 'CPU',
          value: cpu?.userLoad != null && cpu?.systemLoad != null
              ? '${_num(cpu!.totalLoad)}%'
              : null,
          details: [
            if (cpu?.minLoad1 != null) '1 分钟 ${_num(cpu!.minLoad1!)}',
            if (cpu?.minLoad5 != null) '5 分钟 ${_num(cpu!.minLoad5!)}',
            if (cpu?.minLoad15 != null) '15 分钟 ${_num(cpu!.minLoad15!)}',
            if (system?.sysTemp != null)
              '系统温度 ${_num(system!.sysTemp!)}°C',
          ],
          percent: cpu?.userLoad != null && cpu?.systemLoad != null
              ? cpu!.totalLoad.toDouble()
              : null,
        ),
        const SizedBox(height: 8),
        _ResourceBlock(
          title: '内存',
          value: memory?.realUsage != null
              ? '${_num(memory!.realUsage!)}%'
              : null,
          percent: memory?.realUsage?.toDouble(),
        ),
        if (volumes != null)
          for (final volume in volumes) ...[
            const SizedBox(height: 8),
            _VolumeBlock(volume: volume),
          ],
      ],
    );
  }
}

String _num(num value) =>
    value == value.roundToDouble() ? value.toInt().toString() : value.toString();

double? _fraction(num? percent) {
  if (percent == null || !percent.isFinite || percent < 0 || percent > 100) {
    return null;
  }
  return percent / 100;
}

class _ResourceBlock extends StatelessWidget {
  const _ResourceBlock({
    required this.title,
    this.value,
    this.percent,
    this.details = const [],
  });

  final String title;
  final String? value;
  final num? percent;
  final List<String> details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = _fraction(percent);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            if (value != null) ...[
              const SizedBox(height: 4),
              Text(value!, style: theme.textTheme.headlineSmall),
            ],
            if (fraction != null) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: fraction, minHeight: 6),
            ],
            if (details.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  for (final detail in details)
                    Text(
                      detail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VolumeBlock extends StatelessWidget {
  const _VolumeBlock({required this.volume});

  final Volumes volume;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = volume.status;
    final name = volume.displayName.trim();
    final size = volume.size;
    final total = size?.total;
    final used = size?.used;
    final validCapacity = total != null && total > 0 &&
        used != null && used >= 0 && used <= total;
    final free = validCapacity ? total - used : null;
    final percent = validCapacity ? used / total * 100 : null;

    final statusLabel = status == null || status.trim().isEmpty
        ? null
        : VolumeStatusEnum.fromValue(status).label;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (name.isNotEmpty)
              Text(name, style: theme.textTheme.titleSmall),
            if (statusLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                statusLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (percent != null) ...[
              const SizedBox(height: 4),
              Text(
                '${percent.toStringAsFixed(1)}%',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: percent / 100,
                minHeight: 6,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text('已用 ${_bytes(used!)} / ${_bytes(total!)}',
                    style: theme.textTheme.bodySmall),
                  Text('可用 ${_bytes(free!)}',
                    style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _bytes(int bytes) {
  const units = ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  return '${value.toStringAsFixed(1)} ${units[unit]}';
}
