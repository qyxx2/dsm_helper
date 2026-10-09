import 'package:dsm_helper/utils/utils.dart';
import 'package:flutter/material.dart';

/// Compact, read-only device identity. Missing identity fields are not
/// substituted with fake values.
class DeviceSummary extends StatelessWidget {
  const DeviceSummary({super.key, this.hostname, this.uptime});

  final String? hostname;
  final String? uptime;

  String? _formattedUptime() {
    final raw = uptime?.trim();
    if (raw == null || raw.isEmpty) return null;
    try {
      return Utils.parseOpTime(raw);
    } on FormatException {
      return null;
    } on RangeError {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = hostname?.trim();
    final hasName = name != null && name.isNotEmpty;
    final elapsed = _formattedUptime();
    if (!hasName && elapsed == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final nameWidget = hasName
        ? Text(
            name,
            softWrap: true,
            style: theme.textTheme.titleMedium,
          )
        : null;
    final uptimeWidget = elapsed != null
        ? Text(
            elapsed,
            softWrap: true,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        : null;

    final stacked = MediaQuery.textScalerOf(context).scale(1) >= 1.7;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (nameWidget != null) nameWidget,
                if (nameWidget != null && uptimeWidget != null)
                  const SizedBox(height: 4),
                if (uptimeWidget != null) uptimeWidget,
              ],
            )
          : Row(
              children: [
                if (nameWidget != null)
                  Expanded(child: nameWidget)
                else
                  const Spacer(),
                if (nameWidget != null && uptimeWidget != null)
                  const SizedBox(width: 12),
                if (uptimeWidget != null) Flexible(child: uptimeWidget),
              ],
            ),
    );
  }
}
