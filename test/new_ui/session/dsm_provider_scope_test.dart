import 'package:dsm_helper/new_ui/app/new_ui_app_shell.dart';
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
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> _dsmProviders({
  required SystemInfoProvider systemInfo,
  required InitDataProvider initData,
  required UtilizationProvider utilization,
  required StorageProvider storage,
  required ExternalDeviceProvider externalDevice,
  required BackgroundTaskProvider backgroundTask,
}) {
  return [
    ChangeNotifierProvider.value(value: systemInfo),
    ChangeNotifierProvider.value(value: initData),
    ChangeNotifierProvider.value(value: utilization),
    ChangeNotifierProvider.value(value: storage),
    ChangeNotifierProvider.value(value: externalDevice),
    ChangeNotifierProvider.value(value: backgroundTask),
  ];
}

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
            providers: _dsmProviders(
              systemInfo: innerSystem,
              initData: innerInit,
              utilization: innerUtilization,
              storage: innerStorage,
              externalDevice: innerExternal,
              backgroundTask: innerBackground,
            ),
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

  testWidgets('root legacy host wrapper keeps current DSM providers on nested legacy routes', (tester) async {
    final outerSystem = SystemInfoProvider();
    final innerSystem = SystemInfoProvider();
    final innerInit = InitDataProvider();
    final innerUtilization = UtilizationProvider();
    final innerStorage = StorageProvider();
    final innerExternal = ExternalDeviceProvider();
    final innerBackground = BackgroundTaskProvider();
    SystemInfoProvider? nestedResolved;

    Widget legacyRoot(BuildContext context) {
      return Scaffold(
        body: ElevatedButton(
          key: const Key('push-legacy-child'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) {
                  nestedResolved = context.read<SystemInfoProvider>();
                  return const Scaffold(body: Text('nested-legacy'));
                },
              ),
            );
          },
          child: const Text('push child'),
        ),
      );
    }

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: outerSystem),
        ],
        child: MaterialApp(
          home: MultiProvider(
            providers: _dsmProviders(
              systemInfo: innerSystem,
              initData: innerInit,
              utilization: innerUtilization,
              storage: innerStorage,
              externalDevice: innerExternal,
              backgroundTask: innerBackground,
            ),
            child: Builder(
              builder: (context) {
                final scope = DsmProviderScope.capture(context);
                return NewUiAppShell(
                  legacyHostWrapper: scope.wrap,
                  notificationBuilder: (_) => const SizedBox(),
                  destinations: List.generate(
                    5,
                    (index) => NewUiAppDestination.test(
                      label: ['概览', '文件', '应用', '任务', '我的'][index],
                      legacyBuilder: legacyRoot,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-legacy-feature')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('push-legacy-child')));
    await tester.pumpAndSettle();

    expect(find.text('nested-legacy'), findsOneWidget);
    expect(nestedResolved, same(innerSystem));
    expect(nestedResolved, isNot(same(outerSystem)));
  });
}
