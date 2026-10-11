import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/dark_mode.dart';
import '../../providers/init_data_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.onOpenNotifications,
    required this.onOpenAccountManagement,
    required this.onLogout,
    required this.onOpenUserSettings,
    required this.onOpenHelperSettings,
    required this.onOpenAbout,
    required this.onOpenLegacySettings,
    this.connectionStatusText,
  });

  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenAccountManagement;
  final VoidCallback onLogout;
  final VoidCallback onOpenUserSettings;
  final VoidCallback onOpenHelperSettings;
  final VoidCallback onOpenAbout;
  final VoidCallback onOpenLegacySettings;
  final String? connectionStatusText;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<InitDataProvider>().initData.session;
    final darkMode = context.watch<DarkModeProvider>();
    final hostname = session?.hostname?.trim();
    final username = session?.user?.trim();
    final hasHostname = hostname != null && hostname.isNotEmpty;
    final hasUsername = username != null && username.isNotEmpty;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Flexible(
              child: Text('我的', maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (connectionStatusText != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  connectionStatusText!,
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
            icon: const Icon(Icons.notifications_outlined),
            onPressed: onOpenNotifications,
          ),
        ],
      ),
      body: ListView(
        key: const Key('settings-scroll'),
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              key: const Key('current-device-account-card'),
              margin: EdgeInsets.zero,
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            hasHostname
                                ? hostname!
                                : (hasUsername ? username! : '设备信息暂不可用'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall,
                          ),
                          if (hasHostname && hasUsername)
                            Text(
                              username!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: const Key('my-user-settings'),
                      tooltip: '个人设置',
                      onPressed: onOpenUserSettings,
                      icon: const Icon(Icons.manage_accounts_outlined),
                    ),
                    IconButton(
                      key: const Key('my-logout'),
                      tooltip: '退出登录',
                      onPressed: onLogout,
                      icon: const Icon(Icons.logout_outlined),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _entry(context, '服务器与账号管理', onOpenAccountManagement),
          _entry(
            context,
            '主题模式',
            () => showSettingsThemeModeSheet(context),
            value: _modeText(darkMode.darkMode),
          ),
          _entry(context, '助手设置', onOpenHelperSettings),
          _entry(context, '更多现有设置', onOpenLegacySettings),
          _entry(context, '关于', onOpenAbout),
        ],
      ),
    );
  }

  Widget _entry(
    BuildContext context,
    String label,
    VoidCallback onTap, {
    String? value,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minVerticalPadding: 8,
      title: Text(label, style: theme.textTheme.titleSmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null) ...[
            Text(value, style: theme.textTheme.bodySmall),
            const SizedBox(width: 8),
          ],
          Icon(
            Icons.chevron_right,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  String _modeText(int mode) {
    return switch (mode) {
      0 => '浅色',
      1 => '深色',
      _ => '跟随系统',
    };
  }
}

Future<void> showSettingsThemeModeSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('跟随系统'),
            onTap: () {
              context.read<DarkModeProvider>().changeMode(2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('浅色'),
            onTap: () {
              context.read<DarkModeProvider>().changeMode(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('深色'),
            onTap: () {
              context.read<DarkModeProvider>().changeMode(1);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}
