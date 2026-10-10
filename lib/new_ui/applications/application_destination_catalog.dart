import 'package:dsm_helper/new_ui/applications/application_catalog.dart';
import 'package:dsm_helper/pages/common/browser.dart';
import 'package:dsm_helper/pages/control_panel/control_panel.dart';
import 'package:dsm_helper/pages/docker/docker.dart';
import 'package:dsm_helper/pages/download_station/download_station.dart';
import 'package:dsm_helper/pages/log_center/log_center.dart';
import 'package:dsm_helper/pages/moments/moments.dart';
import 'package:dsm_helper/pages/packages/packages.dart';
import 'package:dsm_helper/pages/photos/photos.dart';
import 'package:dsm_helper/pages/resource_monitor/resource_monitor.dart';
import 'package:dsm_helper/pages/security_scan/security_scan.dart';
import 'package:dsm_helper/pages/storage_manager/storage_manager.dart';
import 'package:dsm_helper/pages/virtual_machine/virtual_machine.dart';
import 'package:flutter/widgets.dart';

class ModernApplicationDestinationCatalog {
  const ModernApplicationDestinationCatalog();

  WidgetBuilder? builderFor(ModernApplicationId id) {
    return switch (id) {
      ModernApplicationId.controlPanel => (_) => ControlPanel(),
      ModernApplicationId.packageCenter => (_) => Packages(),
      ModernApplicationId.resourceMonitor => (_) => ResourceMonitor(),
      ModernApplicationId.storageManager => (_) => StorageManager(),
      ModernApplicationId.logCenter => (_) => LogCenter(),
      ModernApplicationId.securityAdvisor => (_) => SecurityScan(),
      ModernApplicationId.xunlei => (_) => Browser(
            title: '迅雷-远程设备',
            url: 'https://pan.xunlei.com/yc/?fromApp=paipai',
          ),
      ModernApplicationId.containerManager =>
        (_) => Docker(isContainer: true),
      ModernApplicationId.downloadStation => (_) => DownloadStation(),
      ModernApplicationId.moments => (_) => Moments(),
      ModernApplicationId.photos => (_) => const Photos(),
      ModernApplicationId.virtualMachineManager => (_) => VirtualMachine(),
    };
  }
}
