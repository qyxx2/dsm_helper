import 'package:dsm_helper/new_ui/shell/primary_destination.dart';
import 'package:flutter/material.dart';

class PrimaryRootPage extends StatelessWidget {
  const PrimaryRootPage({
    required this.destination,
    required this.onOpenNotifications,
    required this.onOpenLegacy,
    this.contextLabel,
    super.key,
  });

  final PrimaryDestination destination;
  final String? contextLabel;
  final Future<void> Function(BuildContext context) onOpenNotifications;
  final Future<void> Function(BuildContext context) onOpenLegacy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(destination.label),
        actions: [
          IconButton(
            key: const ValueKey('new-ui-notifications'),
            tooltip: '通知',
            onPressed: () => onOpenNotifications(context),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (contextLabel != null && contextLabel!.trim().isNotEmpty) ...[
            Text(
              contextLabel!,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],
          Card(
            child: ListTile(
              minTileHeight: 64,
              leading: Icon(destination.selectedIcon),
              title: Text('打开当前${destination.label}功能'),
              subtitle: const Text('此功能将在后续迁移任务中逐步替换'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onOpenLegacy(context),
            ),
          ),
        ],
      ),
    );
  }
}
