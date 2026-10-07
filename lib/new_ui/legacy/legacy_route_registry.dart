import 'package:dsm_helper/pages/control_panel/control_panel.dart';
import 'package:dsm_helper/pages/docker/docker.dart';
import 'package:dsm_helper/pages/download_station/download_station.dart';
import 'package:dsm_helper/pages/moments/moments.dart';
import 'package:dsm_helper/pages/packages/packages.dart';
import 'package:dsm_helper/pages/photos/photos.dart';
import 'package:dsm_helper/pages/resource_monitor/resource_monitor.dart';
import 'package:dsm_helper/pages/security_scan/security_scan.dart';
import 'package:dsm_helper/pages/storage_manager/storage_manager.dart';
import 'package:dsm_helper/pages/virtual_machine/virtual_machine.dart';
import 'package:flutter/widgets.dart';

final Map<String, WidgetBuilder> legacyNamedRoutes = {
  "/control_panel": (BuildContext context) => ControlPanel(),
  "/package_center": (BuildContext context) => Packages(),
  "/resource_monitor": (BuildContext context) => ResourceMonitor(),
  "/storage_manager": (BuildContext context) => StorageManager(),
  "/security_scan": (BuildContext context) => SecurityScan(),
  "/docker": (BuildContext context) => Docker(),
  "/container_manager": (BuildContext context) => Docker(isContainer: true),
  "/download_station": (BuildContext context) => DownloadStation(),
  "/moments": (BuildContext context) => Moments(),
  "/synology_photos": (BuildContext context) => Photos(),
  "/virtual_machine": (BuildContext context) => VirtualMachine(),
};
