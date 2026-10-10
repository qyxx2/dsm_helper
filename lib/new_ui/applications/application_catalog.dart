import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/utils/utils.dart';

enum ModernApplicationId {
  controlPanel,
  packageCenter,
  resourceMonitor,
  storageManager,
  logCenter,
  securityAdvisor,
  xunlei,
  containerManager,
  downloadStation,
  moments,
  photos,
  virtualMachineManager,
}

extension ModernApplicationIdPersistence on ModernApplicationId {
  String get storageKey => switch (this) {
        ModernApplicationId.controlPanel => 'control_panel',
        ModernApplicationId.packageCenter => 'package_center',
        ModernApplicationId.resourceMonitor => 'resource_monitor',
        ModernApplicationId.storageManager => 'storage_manager',
        ModernApplicationId.logCenter => 'log_center',
        ModernApplicationId.securityAdvisor => 'security_advisor',
        ModernApplicationId.xunlei => 'xunlei',
        ModernApplicationId.containerManager => 'container_manager',
        ModernApplicationId.downloadStation => 'download_station',
        ModernApplicationId.moments => 'moments',
        ModernApplicationId.photos => 'photos',
        ModernApplicationId.virtualMachineManager => 'virtual_machine_manager',
      };
}

enum ApplicationCatalogAvailability {
  unavailable,
  available,
}

class ModernApplicationItem {
  const ModernApplicationItem({
    required this.id,
    required this.sourcePackageName,
    required this.label,
    required this.assetPath,
  });

  final ModernApplicationId id;
  final String sourcePackageName;
  final String label;
  final String assetPath;
}

class ApplicationCatalogSnapshot {
  const ApplicationCatalogSnapshot({
    required this.availability,
    required this.items,
  });

  final ApplicationCatalogAvailability availability;
  final List<ModernApplicationItem> items;
}

class ModernApplicationCatalog {
  const ModernApplicationCatalog();

  static const _containerManagerPackage =
      'SYNO.SDS.ContainerManager.Application';

  ApplicationCatalogSnapshot build(InitDataModel initData) {
    final desktop = initData.userSettings?.desktop;
    if (desktop == null) {
      return const ApplicationCatalogSnapshot(
        availability: ApplicationCatalogAvailability.unavailable,
        items: [],
      );
    }

    final validOrder = desktop.validAppviewOrder ?? const <String>[];
    final source = validOrder.isNotEmpty
        ? validOrder
        : (desktop.appviewOrder ?? const <String>[]);
    final preferContainerManager = source.contains(_containerManagerPackage);

    final items = <ModernApplicationItem>[];
    final seen = <ModernApplicationId>{};
    for (final packageName in source) {
      final item = _resolve(
        packageName,
        preferContainerManager: preferContainerManager,
      );
      if (item != null && seen.add(item.id)) {
        items.add(item);
      }
    }

    return ApplicationCatalogSnapshot(
      availability: ApplicationCatalogAvailability.available,
      items: List.unmodifiable(items),
    );
  }

  ModernApplicationItem? _resolve(
    String packageName, {
    required bool preferContainerManager,
  }) {
    final assetRoot = 'assets/applications/${Utils.version}';

    switch (packageName) {
      case 'SYNO.SDS.AdminCenter.Application':
        return ModernApplicationItem(
          id: ModernApplicationId.controlPanel,
          sourcePackageName: packageName,
          label: '控制中心',
          assetPath: '$assetRoot/control_panel.png',
        );
      case 'SYNO.SDS.PkgManApp.Instance':
        return ModernApplicationItem(
          id: ModernApplicationId.packageCenter,
          sourcePackageName: packageName,
          label: '套件中心',
          assetPath: '$assetRoot/package_center.png',
        );
      case 'SYNO.SDS.ResourceMonitor.Instance':
        return ModernApplicationItem(
          id: ModernApplicationId.resourceMonitor,
          sourcePackageName: packageName,
          label: '资源监控',
          assetPath: '$assetRoot/resource_monitor.png',
        );
      case 'SYNO.SDS.StorageManager.Instance':
        return ModernApplicationItem(
          id: ModernApplicationId.storageManager,
          sourcePackageName: packageName,
          label: '存储管理器',
          assetPath: '$assetRoot/storage_manager.png',
        );
      case 'SYNO.SDS.LogCenter.Instance':
      case 'SYNO.SDS.LogCenter.BuiltIn':
        return ModernApplicationItem(
          id: ModernApplicationId.logCenter,
          sourcePackageName: packageName,
          label: '日志中心',
          assetPath: '$assetRoot/log_center.png',
        );
      case 'SYNO.SDS.SecurityScan.Instance':
        return ModernApplicationItem(
          id: ModernApplicationId.securityAdvisor,
          sourcePackageName: packageName,
          label: '安全顾问',
          assetPath: '$assetRoot/security_scan.png',
        );
      case 'SYNO.SDS.XLPan.Application':
        return ModernApplicationItem(
          id: ModernApplicationId.xunlei,
          sourcePackageName: packageName,
          label: '迅雷',
          assetPath: 'assets/applications/xunlei.png',
        );
      case 'SYNO.SDS.Docker.Application':
      case _containerManagerPackage:
        if (preferContainerManager) {
          return const ModernApplicationItem(
            id: ModernApplicationId.containerManager,
            sourcePackageName: _containerManagerPackage,
            label: 'Container Manager',
            assetPath: 'assets/applications/container_manager.png',
          );
        }
        return const ModernApplicationItem(
          id: ModernApplicationId.containerManager,
          sourcePackageName: 'SYNO.SDS.Docker.Application',
          label: 'Docker',
          assetPath: 'assets/applications/docker.png',
        );
      case 'SYNO.SDS.DownloadStation.Application':
        return ModernApplicationItem(
          id: ModernApplicationId.downloadStation,
          sourcePackageName: packageName,
          label: 'Download Station',
          assetPath: 'assets/applications/download_station.png',
        );
      case 'SYNO.Photo.AppInstance':
        return ModernApplicationItem(
          id: ModernApplicationId.moments,
          sourcePackageName: packageName,
          label: 'Moments',
          assetPath: '$assetRoot/moments.png',
        );
      case 'SYNO.Foto.AppInstance':
        return ModernApplicationItem(
          id: ModernApplicationId.photos,
          sourcePackageName: packageName,
          label: 'Synology Photos',
          assetPath: '$assetRoot/synology_photos.png',
        );
      case 'SYNO.SDS.Virtualization.Application':
        return ModernApplicationItem(
          id: ModernApplicationId.virtualMachineManager,
          sourcePackageName: packageName,
          label: 'Virtual Machine Manager',
          assetPath: '$assetRoot/virtual_machine.png',
        );
      default:
        return null;
    }
  }
}
