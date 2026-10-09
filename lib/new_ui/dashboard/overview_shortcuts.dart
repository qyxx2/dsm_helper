import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/pages/common/browser.dart';
import 'package:dsm_helper/pages/control_panel/control_panel.dart';
import 'package:dsm_helper/pages/docker/container_detail/container_detail.dart';
import 'package:dsm_helper/pages/docker/docker.dart';
import 'package:dsm_helper/pages/download_station/download_station.dart';
import 'package:dsm_helper/pages/log_center/log_center.dart';
import 'package:dsm_helper/pages/packages/packages.dart';
import 'package:dsm_helper/pages/resource_monitor/resource_monitor.dart';
import 'package:dsm_helper/pages/storage_manager/storage_manager.dart';
import 'package:dsm_helper/pages/virtual_machine/virtual_machine.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:flutter/widgets.dart';

/// A read-only destination derived from the current DSM desktop settings.
class OverviewShortcut {
  const OverviewShortcut({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.routeName,
    required this.legacyBuilder,
  });

  final String id;
  final String label;
  final String assetPath;
  final String routeName;
  final WidgetBuilder legacyBuilder;
}

/// Reads only DSM's current desktop entries; never writes shortcut settings.
class OverviewShortcutCatalog {
  const OverviewShortcutCatalog();

  List<OverviewShortcut> build(InitDataModel initData) {
    final desktop = initData.userSettings?.desktop;
    final shortcuts = desktop?.shortcutItems;
    final available = desktop?.validAppviewOrder;
    if (shortcuts == null || available == null || available.isEmpty) {
      return const [];
    }

    final result = <OverviewShortcut>[];
    for (var index = 0; index < shortcuts.length && result.length < 4; index++) {
      final source = shortcuts[index];
      final id = source.className;
      if (id == null) continue;

      final shortcut = _map(id, index, source, available);
      if (shortcut != null) result.add(shortcut);
    }
    return result;
  }

  OverviewShortcut? _map(
    String className,
    int index,
    ShortcutItems source,
    List<String> available,
  ) {
    final assetRoot = 'assets/applications/${Utils.version}';
    final String label;
    final String asset;
    final String route;
    final WidgetBuilder builder;

    switch (className) {
      case 'SYNO.SDS.PkgManApp.Instance':
        if (!available.contains(className)) return null;
        label = '套件中心';
        asset = '$assetRoot/package_center.png';
        route = '/package_center';
        builder = (_) => Packages();
        break;
      case 'SYNO.SDS.AdminCenter.Application':
        if (!available.contains(className)) return null;
        label = '控制面板';
        asset = '$assetRoot/control_panel.png';
        route = '/control_panel';
        builder = (_) => ControlPanel();
        break;
      case 'SYNO.SDS.StorageManager.Instance':
        if (!available.contains(className)) return null;
        label = '存储空间管理员';
        asset = '$assetRoot/storage_manager.png';
        route = '/storage_manager';
        builder = (_) => StorageManager();
        break;
      case 'SYNO.SDS.ResourceMonitor.Instance':
        if (!available.contains(className)) return null;
        label = '资源监控';
        asset = '$assetRoot/resource_monitor.png';
        route = '/resource_monitor';
        builder = (_) => ResourceMonitor();
        break;
      case 'SYNO.SDS.LogCenter.Instance':
        if (!available.contains(className) &&
            !available.contains('SYNO.SDS.LogCenter.BuiltIn')) {
          return null;
        }
        label = '日志中心';
        asset = '$assetRoot/log_center.png';
        route = '/log_center';
        builder = (_) => LogCenter();
        break;
      case 'SYNO.SDS.Virtualization.Application':
        if (!available.contains(className)) return null;
        label = 'Virtual Machine Manager';
        asset = '$assetRoot/virtual_machine.png';
        route = '/virtual_machine';
        builder = (_) => VirtualMachine();
        break;
      case 'SYNO.SDS.DownloadStation.Application':
        if (!available.contains(className)) return null;
        label = 'Download Station';
        asset = 'assets/applications/download_station.png';
        route = '/download_station';
        builder = (_) => DownloadStation();
        break;
      case 'SYNO.SDS.Docker.Application':
        final isContainer =
            available.contains('SYNO.SDS.ContainerManager.Application');
        if (!isContainer && !available.contains(className)) return null;
        label = isContainer ? 'Container Manager' : 'Docker';
        asset = isContainer
            ? 'assets/applications/container_manager.png'
            : 'assets/applications/docker.png';
        route = isContainer ? '/container_manager' : '/docker';
        builder = (_) => Docker(isContainer: isContainer);
        break;
      case 'SYNO.SDS.Docker.ContainerDetail.Instance':
        if (!available.contains('SYNO.SDS.Docker.Application') &&
            !available.contains('SYNO.SDS.ContainerManager.Application')) {
          return null;
        }
        final name = source.param?.data?.name;
        if (name == null || name.trim().isEmpty) return null;
        label = name;
        asset = 'assets/applications/container_manager.png';
        if (source.type == 'url') {
          final url = source.url;
          if (url == null || url.trim().isEmpty) return null;
          route = '/browser';
          builder = (_) => Browser(url: url, title: name);
        } else {
          route = '/docker_container_detail';
          builder = (_) => ContainerDetail(name);
        }
        break;
      case 'SYNO.SDS.XLPan.Application':
        if (!available.contains(className)) return null;
        label = '迅雷';
        asset = 'assets/applications/xunlei.png';
        route = '/xunlei';
        builder = (_) => Browser(
              title: '迅雷-远程设备',
              url: 'https://pan.xunlei.com/yc/?fromApp=paipai',
            );
        break;
      default:
        return null;
    }

    return OverviewShortcut(
      id: '$index:$className',
      label: label,
      assetPath: asset,
      routeName: route,
      legacyBuilder: builder,
    );
  }
}
