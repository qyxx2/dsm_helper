import 'package:flutter/material.dart';

class NewUiPrimaryPage extends StatelessWidget {
  const NewUiPrimaryPage({
    super.key,
    required this.title,
    required this.onOpenNotifications,
    required this.onOpenLegacyFeature,
    this.legacyFeatureLabel = '打开现有功能',
  });

  final String title;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenLegacyFeature;
  final String legacyFeatureLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
