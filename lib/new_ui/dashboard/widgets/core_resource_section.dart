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
            _VolumeBlock(
              volume: volume,
              temperatures: _diskTemperatureLabels(storage, volume),
            ),
          ],
      ],
    );
  }
}

String _num(num value) =>
    value == value.roundToDouble() ? value.toInt().toString() : value.toString();

/// Read disk temperatures only through an exact, unambiguous volume -> pool
/// -> disk relation from the existing Storage response.
List<String> _diskTemperatureLabels(Storage? storage, Volumes volume) {
  final identity = volume.poolPath;
  if (storage == null || identity == null || identity.trim().isEmpty) {
    return const [];
  }

  final pools = storage.storagePools ?? const <StoragePools>[];
  final matches = pools.where(
    (pool) => pool.id == identity || pool.poolPath == identity,
  ).toList();
  if (matches.length != 1) return const [];
  final pool = matches.single;

  final allDisks = storage.disks ?? const <Disks>[];
  final poolDiskIds = pool.disks ?? const <String>[];
  final related = <Disks>[];

  if (poolDiskIds.isNotEmpty) {
    final seenIds = <String>{};
    for (final id in poolDiskIds) {
      if (id.isEmpty || !seenIds.add(id)) continue;
      final matches = allDisks.where((disk) => disk.id == id).toList();
      if (matches.length != 1) continue;
      final disk = matches.single;
      final usedBy = disk.usedBy;
      if (usedBy != null && usedBy.isNotEmpty &&
          usedBy != pool.id && usedBy != pool.poolPath) {
        continue;
      }
      related.add(disk);
    }
  } else {
    // Some DSM replies omit pool.disks. A unique matching usedBy identity
    // can recover that relation, but never use an orphan or another pool.
    final poolIdentities = {
      if (pool.id != null && pool.id!.isNotEmpty) pool.id!,
      if (pool.poolPath != null && pool.poolPath!.isNotEmpty) pool.poolPath!,
    };
    final seenIds = <String>{};
    for (final disk in allDisks) {
      final usedBy = disk.usedBy;
      final id = disk.id;
      if (usedBy == null || !poolIdentities.contains(usedBy) ||
          id == null || id.isEmpty || !seenIds.add(id)) {
        continue;
      }
      final owners = pools.where(
        (candidate) =>
            candidate.id == usedBy || candidate.poolPath == usedBy,
      );
      if (owners.length != 1 || !identical(owners.single, pool)) continue;
      if (allDisks.where((candidate) => candidate.id == id).length != 1) {
        continue;
      }
      related.add(disk);
    }
  }

  final visible = <Disks>[];
  for (final disk in related) {
    final temperature = disk.temp;
    if (disk.isSsd == null || temperature == null ||
        !temperature.isFinite || temperature <= 0) {
      continue;
    }
    visible.add(disk);
    if (visible.length == 4) break;
  }
  final hddCount = visible.where((disk) => disk.isSsd == false).length;
  final ssdCount = visible.length - hddCount;
  var hddIndex = 0;
  var ssdIndex = 0;
  return [
    for (final disk in visible)
      if (disk.isSsd == true)
        'SSD${ssdCount > 1 ? ' ${++ssdIndex}' : ''} ${_num(disk.temp!)}℃'
      else
        'HDD${hddCount > 1 ? ' ${++hddIndex}' : ''} ${_num(disk.temp!)}℃',
  ];
}

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
  const _VolumeBlock({required this.volume, required this.temperatures});

  final Volumes volume;
  final List<String> temperatures;

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
            if (temperatures.isEmpty) ...[
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
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _VolumeTemperatures(temperatures: temperatures),
                  ),
                ],
              ),
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

/// Use two explicit columns on normal phone sizes; narrow/large-text
/// layouts wrap naturally without clipping or creating empty placeholders.
class _VolumeTemperatures extends StatelessWidget {
  const _VolumeTemperatures({required this.temperatures});

  final List<String> temperatures;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 160 &&
            MediaQuery.textScalerOf(context).scale(12) <= 17;
        if (!twoColumns) {
          return Wrap(
            alignment: WrapAlignment.end,
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final temperature in temperatures)
                Text(temperature, style: style),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < temperatures.length; i += 2) ...[
              if (i > 0) const SizedBox(height: 4),
              if (i + 1 == temperatures.length)
                Text(temperatures[i], style: style)
              else
                Row(
                  children: [
                    for (final index in [i, i + 1]) ...[
                      if (index != i) const SizedBox(width: 4),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              temperatures[index],
                              style: style,
                              softWrap: false,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ],
        );
      },
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
