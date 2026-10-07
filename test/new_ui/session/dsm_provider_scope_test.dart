import 'package:dsm_helper/new_ui/session/dsm_provider_scope.dart';
import 'package:dsm_helper/providers/background_task_provider.dart';
import 'package:dsm_helper/providers/external_device_provider.dart';
import 'package:dsm_helper/providers/init_data_provider.dart';
import 'package:dsm_helper/providers/storage_provider.dart';
import 'package:dsm_helper/providers/system_info_provider.dart';
import 'package:dsm_helper/providers/utilization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('captured DSM provider scope survives a root-overlay handoff', (tester) async {
    final outerSystem = SystemInfoProvider();
    final innerSystem = SystemInfoProvider();
    final innerInit = InitDataProvider();
    final innerUtilization = UtilizationProvider();
    final innerStorage = StorageProvider();
    final innerExternal = ExternalDeviceProvider();
    final innerBackground = BackgroundTaskProvider();
    DsmProviderScope? captured;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: outerSystem),
        ],
        child: MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: innerSystem),
              ChangeNotifierProvider.value(value: innerInit),
              ChangeNotifierProvider.value(value: innerUtilization),
              ChangeNotifierProvider.value(value: innerStorage),
              ChangeNotifierProvider.value(value: innerExternal),
              ChangeNotifierProvider.value(value: innerBackground),
            ],
            child: Builder(
              builder: (context) {
                captured = DsmProviderScope.capture(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );

    expect(captured, isNotNull);

    SystemInfoProvider? resolved;
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: outerSystem),
        ],
        child: MaterialApp(
          home: captured!.wrap(
            Builder(
              builder: (context) {
                resolved = context.read<SystemInfoProvider>();
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );

    expect(resolved, same(innerSystem));
    expect(resolved, isNot(same(outerSystem)));
  });
}
