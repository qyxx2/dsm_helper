import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/models/Syno/Core/Notify.dart';
import 'package:dsm_helper/models/Syno/Core/System.dart';
import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';
import 'package:dsm_helper/new_ui/app/dsm_new_ui_shell.dart';
import 'package:dsm_helper/new_ui/applications/applications_page.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_controller.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_data_source.dart';
import 'package:dsm_helper/new_ui/legacy/legacy_page_host.dart';
import 'package:dsm_helper/new_ui/legacy/legacy_shared_bootstrap.dart';
import 'package:dsm_helper/new_ui/notifications/legacy_notification_entry.dart';
import 'package:dsm_helper/pages/control_panel/control_panel.dart';
import 'package:dsm_helper/pages/log_center/log_center.dart';
import 'package:dsm_helper/providers/dark_mode.dart';
import 'package:dsm_helper/providers/setting_provider.dart';
import 'package:dsm_helper/themes/light.dart' as legacy_light;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_util/sp_util.dart';

String _shellSource() =>
    File('lib/new_ui/app/dsm_new_ui_shell.dart').readAsStringSync();

String _destination(String source, String label, {String? before}) {
  final start = source.indexOf("label: '$label',");
  expect(start, isNonNegative, reason: 'Missing primary destination $label');
  final end = before == null
      ? source.length
      : source.indexOf("label: '$before',", start + 1);
  expect(end == -1 || end > start, isTrue);
  return source.substring(start, end < 0 ? source.length : end);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await SpUtil.getInstance();
  });

  test('Applications and My are Modern production roots, not placeholder roots', () {
    final source = _shellSource();
    final apps = _destination(source, '应用', before: '任务');
    final my = _destination(source, '我的');

    expect(apps, contains('modernBuilder:'));
    expect(apps, contains('ApplicationsPage('));
    expect(my, contains('modernBuilder:'));
    expect(my, contains('SettingsPage('));
    expect(RegExp(r'modernBuilder\s*:').allMatches(source).length, 3);
  });

  test('Overview, Files, Tasks and both legacy root fallbacks stay wired', () {
    final source = _shellSource();
    expect(_destination(source, '概览', before: '文件'),
        contains('OverviewPage('));
    expect(_destination(source, '文件', before: '应用'),
        contains('FilePage('));
    expect(_destination(source, '任务', before: '我的'),
        contains('Transfer('));
    expect(_destination(source, '应用', before: '任务'),
        contains('legacyBuilder: (_) => Applications()'));
    expect(_destination(source, '我的'),
        contains('legacyBuilder: (_) => Setting('));
  });

  test('Applications and My share notification, context and legacy-host authority', () {
    final source = _shellSource();
    final apps = _destination(source, '应用', before: '任务');
    final my = _destination(source, '我的');

    for (final destination in [apps, my]) {
      expect(destination, contains('onOpenNotifications: onOpenNotifications'));
      expect(destination, contains('connectionStatusText: connectionStatusText'));
    }
    expect(source, contains('ModernApplicationDestinationCatalog('));
    expect(source, contains('LegacyPageHost(builder: builder)'));
    expect(source, contains('providerScope.wrap('));
    expect(source, contains('KeyedSubtree('));
    expect(source, contains("ValueKey(widget.contextId ?? 'legacy-current-context')"));
  });

  test('Only My owns Task 4 account management and logout callbacks', () {
    final source = _shellSource();
    final apps = _destination(source, '应用', before: '任务');
    final my = _destination(source, '我的');

    expect(my, contains('onOpenAccountManagement:'));
    expect(my, contains('onLogout:'));
    expect(apps, isNot(contains('onOpenAccountManagement:')));
    expect(apps, isNot(contains('onLogout:')));
    expect(source, contains('widget.onManageAccounts'));
    expect(source, contains('widget.onLogout'));
  });
  // 5.3 exercises the real production shell/destination mapping. Only DSM
  // transport and unrelated Overview loads are replaced by deterministic data.
  testWidgets('5.3 Applications opens ordinary and Log Center aliases via legacy host, Back returns and notifications preserve tab',
      (tester) async {
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const sharing = MethodChannel('flutter_sharing_intent');
    const sharingEvents = MethodChannel('flutter_sharing_intent/events-sharing');
    messenger.setMockMethodCallHandler(
      sharing,
      (call) async => call.method == 'getInitialSharing' ? '[]' : null,
    );
    messenger.setMockMethodCallHandler(sharingEvents, (_) async => null);

    final data = InitDataModel.fromJson({
      'Session': {'majorversion': '7', 'hostname': 'NAS-APP', 'user': 'alice'},
      'UserSettings': {
        'Desktop': {
          'valid_appview_order': [
            'SYNO.SDS.AdminCenter.Application',
            'SYNO.SDS.LogCenter.BuiltIn',
          ],
        },
      },
    });

    try {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => DarkModeProvider(0)),
            ChangeNotifierProvider(
              create: (_) => SettingProvider(refreshDuration: 3600),
            ),
          ],
          child: MaterialApp(
            home: DsmNewUiShell(
              contextId: 'nas/app',
              legacyBootstrap: LegacySharedBootstrap(
                loadInitData: () async => data,
              ),
              overviewControllerFactory: (interval) => OverviewController(
                refreshInterval: interval,
                dataSource: OverviewDataSource(
                  loadSystem: () async => System(),
                  loadUtilization: () async => Utilization(),
                  loadStorage: () async => Storage(),
                  loadNotifications: () async => DsmNotify(),
                  loadCurrentConnections: () async => null,
                  loadTaskScheduler: () async => null,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('应用'));
      await tester.pumpAndSettle();

      expect(find.byType(ApplicationsPage), findsOneWidget);
      final apps = find.byKey(const Key('all-applications-grid'));
      expect(find.descendant(of: apps, matching: find.text('控制中心')),
          findsOneWidget);
      expect(find.descendant(of: apps, matching: find.text('日志中心')),
          findsOneWidget);

      await tester.tap(find.descendant(of: apps, matching: find.text('控制中心')));
      await tester.pumpAndSettle();
      expect(find.byType(LegacyPageHost), findsOneWidget);
      expect(find.byType(ControlPanel), findsOneWidget);
      expect(Theme.of(tester.element(find.byType(ControlPanel))).colorScheme.primary,
          legacy_light.lightTheme.colorScheme.primary);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(ApplicationsPage), findsOneWidget);

      // BuiltIn is the DSM7 alias that legacy enum-only launchers missed.
      await tester.tap(find.descendant(of: apps, matching: find.text('日志中心')));
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.byType(LegacyPageHost), findsOneWidget);
      expect(find.byType(LogCenter), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(ApplicationsPage), findsOneWidget);

      await tester.tap(find.byKey(const Key('new-ui-notifications')));
      await tester.pumpAndSettle();
      expect(find.byType(LegacyPageHost), findsOneWidget);
      expect(find.byType(LegacyNotificationEntry), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(tester.widget<NavigationBar>(find.byType(NavigationBar))
          .selectedIndex, 2);

      await tester.tap(find.text('我的'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('应用').last);
      await tester.pumpAndSettle();
      expect(find.byType(ApplicationsPage), findsOneWidget);
      expect(tester.widget<NavigationBar>(find.byType(NavigationBar))
          .selectedIndex, 2);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      messenger.setMockMethodCallHandler(sharing, null);
      messenger.setMockMethodCallHandler(sharingEvents, null);
    }
  }, timeout: const Timeout(Duration(seconds: 50)));

}
