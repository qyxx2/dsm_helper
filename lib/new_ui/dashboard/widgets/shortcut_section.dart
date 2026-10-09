import 'package:dsm_helper/new_ui/dashboard/overview_shortcuts.dart';
import 'package:flutter/material.dart';

/// Fixed Overview region: DSM owns the entries; the caller owns navigation.
class ShortcutSection extends StatelessWidget {
  const ShortcutSection({
    super.key,
    required this.shortcuts,
    this.onOpenShortcut,
  });

  final List<OverviewShortcut> shortcuts;
  final ValueChanged<OverviewShortcut>? onOpenShortcut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = shortcuts.take(4).toList(growable: false);

    return Column(
      key: const Key('overview-shortcuts'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('快捷方式', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '暂无可用快捷方式，可在 DSM 桌面配置',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < 4; index++) ...[
                if (index > 0) const SizedBox(width: 8),
                Expanded(
                  child: index < visible.length
                      ? _ShortcutTile(
                          shortcut: visible[index],
                          onTap: onOpenShortcut == null
                              ? null
                              : () => onOpenShortcut!(visible[index]),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
      ],
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.shortcut,
    required this.onTap,
  });

  final OverviewShortcut shortcut;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      key: Key('overview-shortcut-${shortcut.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              shortcut.assetPath,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.apps_outlined,
                size: 40,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              shortcut.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
