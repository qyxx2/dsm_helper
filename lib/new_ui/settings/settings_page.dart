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
    final initData = context.watch<InitDataProvider>().initData;
    final darkMode = context.watch<DarkModeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: onOpenNotifications,
          ),
        ],
      ),
      body: ListView(
        children: [
          if (connectionStatusText != null)
            ListTile(
              title: Text(connectionStatusText!),
              subtitle: Text(_hostLabel(initData)),
            ),
          _section(
            context,
            '当前设备与账号',
            [
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text('账号管理'),
                onTap: onOpenAccountManagement,
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
              ListTile(title: const Text('个人设置'), onTap: onOpenUserSettings),
              ListTile(title: const Text('辅助设置'), onTap: onOpenHelperSettings),
              ListTile(title: const Text('兼容设置'), onTap: onOpenLegacySettings),
            ],
          ),
          _section(
            context,
            '关于',
            [
              ListTile(title: const Text('关于'), onTap: onOpenAbout),
              ListTile(title: const Text('退出登录'), onTap: onLogout),
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

  String _hostLabel(dynamic initData) {
    return initData.systemInfo?.hostname?.toString() ?? '';
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
