import 'package:flutter/material.dart';

enum PrimaryDestination {
  overview('概览', Icons.dashboard_outlined, Icons.dashboard),
  files('文件', Icons.folder_outlined, Icons.folder),
  applications('应用', Icons.apps_outlined, Icons.apps),
  tasks('任务', Icons.sync_alt_outlined, Icons.sync_alt),
  mine('我的', Icons.person_outline, Icons.person);

  const PrimaryDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
