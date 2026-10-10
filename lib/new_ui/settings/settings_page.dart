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
        children: [
          _section(
            context,
            '当前设备与账号',
            [
              if (hasHostname)
                ListTile(
                  dense: true,
                  title: Text(hostname),
                  subtitle: hasUsername ? Text(username) : null,
                )
              else if (hasUsername)
                ListTile(dense: true, title: Text(username)),
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text('服务器与账号管理'),
                onTap: onOpenAccountManagement,
              ),
              ListTile(
                title: const Text('个人设置'),
                onTap: onOpenUserSettings,
              ),
              ListTile(
                title: const Text('退出登录'),
                onTap: onLogout,
              ),
            ],
          ),
          _section(
            context,
            '外观',
            [
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('主题模式'),
                subtitle: Text(_modeText(darkMode.darkMode)),
                onTap: () => showSettingsThemeModeSheet(context),
              ),
            ],
          ),
          _section(
            context,
            '应用设置',
            [
              ListTile(title: const Text('助手设置'), onTap: onOpenHelperSettings),
              ListTile(
                title: const Text('更多现有设置'),
                onTap: onOpenLegacySettings,
              ),
            ],
          ),
          _section(
            context,
            '关于',
            [
              ListTile(title: const Text('关于'), onTap: onOpenAbout),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        ...children,
      ],
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
