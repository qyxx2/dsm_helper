import 'package:dsm_helper/providers/background_task_provider.dart';
import 'package:dsm_helper/providers/external_device_provider.dart';
import 'package:dsm_helper/providers/init_data_provider.dart';
import 'package:dsm_helper/providers/storage_provider.dart';
import 'package:dsm_helper/providers/system_info_provider.dart';
import 'package:dsm_helper/providers/utilization_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class DsmProviderScope {
  const DsmProviderScope._({
    required this.systemInfo,
    required this.initData,
    required this.utilization,
    required this.storage,
    required this.externalDevice,
    required this.backgroundTask,
  });

  factory DsmProviderScope.capture(BuildContext context) {
    return DsmProviderScope._(
      systemInfo: context.read<SystemInfoProvider>(),
      initData: context.read<InitDataProvider>(),
      utilization: context.read<UtilizationProvider>(),
      storage: context.read<StorageProvider>(),
      externalDevice: context.read<ExternalDeviceProvider>(),
      backgroundTask: context.read<BackgroundTaskProvider>(),
    );
  }

  final SystemInfoProvider systemInfo;
  final InitDataProvider initData;
  final UtilizationProvider utilization;
  final StorageProvider storage;
  final ExternalDeviceProvider externalDevice;
  final BackgroundTaskProvider backgroundTask;

  Widget wrap(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: systemInfo),
        ChangeNotifierProvider.value(value: initData),
        ChangeNotifierProvider.value(value: utilization),
        ChangeNotifierProvider.value(value: storage),
        ChangeNotifierProvider.value(value: externalDevice),
        ChangeNotifierProvider.value(value: backgroundTask),
      ],
      child: child,
    );
  }
}
