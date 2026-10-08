import 'package:flutter/material.dart';

class NewUiPrimaryPage extends StatelessWidget {
  const NewUiPrimaryPage({
    super.key,
    required this.title,
    required this.onOpenNotifications,
    required this.onOpenLegacyFeature,
    this.legacyFeatureLabel = '打开现有功能',
    this.connectionStatusText,
    this.onOpenAccountManagement,
    this.onLogout,
  });

  final String title;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenLegacyFeature;
  final String legacyFeatureLabel;
  final String? connectionStatusText;
  final VoidCallback? onOpenAccountManagement;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (connectionStatusText != null) ...[
              const SizedBox(width: 8),
              Text(
                connectionStatusText!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            key: const Key('new-ui-notifications'),
            tooltip: '通知',
            onPressed: onOpenNotifications,
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '此功能将在后续迁移任务中替换。当前继续使用经过验证的现有页面。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (onOpenAccountManagement != null) ...[
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              key: const Key('modern-manage-accounts'),
              onPressed: onOpenAccountManagement,
              icon: const Icon(Icons.manage_accounts_outlined),
              label: const Text('服务器与账号管理'),
            ),
          ],
          if (onLogout != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('modern-logout'),
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('退出登录'),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            key: const Key('open-legacy-feature'),
            onPressed: onOpenLegacyFeature,
            icon: const Icon(Icons.open_in_new),
            label: Text(legacyFeatureLabel),
          ),
        ],
      ),
    );
  }
}
