import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/new_ui/app/dsm_new_ui_shell.dart';
import 'package:dsm_helper/new_ui/applications/applications_page.dart';
import 'package:dsm_helper/new_ui/applications/application_favorites_store.dart';
import 'package:dsm_helper/new_ui/legacy/legacy_shared_bootstrap.dart';
import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:dsm_helper/providers/dark_mode.dart';
import 'package:dsm_helper/providers/setting_provider.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_util/sp_util.dart';

class _InitDataLoader {
  _InitDataLoader({
    required this.majorVersion,
    required this.application,
    this.hostname,
  });

  final String majorVersion;
  final String application;
  final String? hostname;
  int requests = 0;

  Future<InitDataModel> call() async {
    requests += 1;
    return InitDataModel.fromJson({
      'Session': {
        'majorversion': majorVersion,
        if (hostname != null) 'hostname': hostname,
      },
      'UserSettings': {
        'Desktop': {
          'valid_appview_order': [application],
        },
      },
    });
  }
}

Future<void> _pumpShell(
  WidgetTester tester, {
  required _InitDataLoader loader,
  required String contextId,
  ActiveContextStatus status = ActiveContextStatus.authenticated,
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DarkModeProvider(0)),
        ChangeNotifierProvider(create: (_) => SettingProvider()),
      ],
      child: MaterialApp(
        home: DsmNewUiShell(
          initialContextStatus: status,
          contextId: contextId,
          legacyBootstrap: LegacySharedBootstrap(
            loadInitData: loader.call,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openApplications(WidgetTester tester) async {
  await tester.tap(find.text('应用'));
  await tester.pumpAndSettle();
  expect(find.byType(ApplicationsPage), findsOneWidget);
  expect(find.byKey(const Key('open-legacy-feature')), findsNothing);
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await SpUtil.getInstance();
  });

  testWidgets(
    'cold-start shell prepares legacy InitData before Dashboard is ever mounted',
    (tester) async {
      final loader = _InitDataLoader(
        majorVersion: '7',
        application: 'SYNO.SDS.AdminCenter.Application',
      );
      Utils.version = 6;

      await _pumpShell(tester, loader: loader, contextId: 'server/account');

      expect(loader.requests, 1);
      expect(Utils.version, 7);

      await _openApplications(tester);

      expect(find.text('控制中心'), findsOneWidget);
      expect(loader.requests, 1);
    },
  );

  testWidgets(
    'new shell context replaces shared InitData and DSM version instead of exposing the previous NAS',
    (tester) async {
      final loaderA = _InitDataLoader(
        majorVersion: '7',
        application: 'SYNO.SDS.AdminCenter.Application',
      );
      final loaderB = _InitDataLoader(
        majorVersion: '6',
        application: 'SYNO.SDS.PkgManApp.Instance',
      );

      await _pumpShell(tester, loader: loaderA, contextId: 'A');
      expect(Utils.version, 7);

      await _openApplications(tester);
      expect(find.text('控制中心'), findsOneWidget);

      // Switching identity remounts the context-keyed shell directly; the
      // Modern Applications root does not require a legacy route pop.
      await _pumpShell(tester, loader: loaderB, contextId: 'B');
      expect(Utils.version, 6);

      await _openApplications(tester);
      expect(find.text('套件中心'), findsOneWidget);
      expect(find.text('控制中心'), findsNothing);
      expect(loaderA.requests, 1);
      expect(loaderB.requests, 1);
    },
  );

  testWidgets(
    'offline shell preserves startup semantics without probing legacy InitData',
    (tester) async {
      final loader = _InitDataLoader(
        majorVersion: '7',
        application: 'SYNO.SDS.AdminCenter.Application',
      );

      await _pumpShell(
        tester,
        loader: loader,
        contextId: 'offline-context',
        status: ActiveContextStatus.offline,
      );

      expect(loader.requests, 0);
      expect(find.text('离线'), findsWidgets);
      expect(find.text('应用'), findsOneWidget);
    },
  );
  testWidgets(
    '5.5 context A/B remount resets tabs, replaces InitData and re-filters preserved favorites',
    (tester) async {
      const key = SpUtilApplicationFavoritesStore.storageKey;
      const persisted = <String>[
        'control_panel',
        'future_unknown_id',
        'log_center',
      ];
      await SpUtil.putStringList(key, persisted);

      final loaderA = _InitDataLoader(
        majorVersion: '7',
        application: 'SYNO.SDS.AdminCenter.Application',
        hostname: 'NAS-A',
      );
      final loaderB = _InitDataLoader(
        majorVersion: '7',
        application: 'SYNO.SDS.LogCenter.BuiltIn',
        hostname: 'NAS-B',
      );
      try {
        await _pumpShell(tester, loader: loaderA, contextId: 'server-A/alice');
        await _openApplications(tester);

        final commonA = find.byKey(const Key('favorite-applications-grid'));
        expect(find.descendant(of: commonA, matching: find.text('控制中心')),
            findsOneWidget);
        expect(find.text('日志中心'), findsNothing);
        expect(SpUtil.getStringList(key), persisted);

        // KeyedSubtree context identity is the Task 3/4 reset authority:
        // the Applications navigator and A's InitData must not survive.
        await _pumpShell(tester, loader: loaderB, contextId: 'server-B/bob');
        expect(tester.widget<NavigationBar>(find.byType(NavigationBar))
            .selectedIndex, 0);
        await tester.tap(find.text('我的'));
        await tester.pumpAndSettle();
        expect(find.text('NAS-B'), findsOneWidget);
        expect(find.text('NAS-A'), findsNothing);
        await _openApplications(tester);

        final commonB = find.byKey(const Key('favorite-applications-grid'));
        expect(find.descendant(of: commonB, matching: find.text('日志中心')),
            findsOneWidget);
        expect(find.text('控制中心'), findsNothing);
        expect(SpUtil.getStringList(key), persisted);

        // Switching back restores A-only visibility from the same stored list,
        // without a destructive projection or DSM Desktop write.
        await _pumpShell(tester, loader: loaderA, contextId: 'server-A/alice');
        expect(tester.widget<NavigationBar>(find.byType(NavigationBar))
            .selectedIndex, 0);
        await _openApplications(tester);
        expect(find.descendant(
          of: find.byKey(const Key('favorite-applications-grid')),
          matching: find.text('控制中心'),
        ), findsOneWidget);
        expect(find.text('日志中心'), findsNothing);
        expect(SpUtil.getStringList(key), persisted);
        expect(loaderA.requests, 2);
        expect(loaderB.requests, 1);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await SpUtil.putStringList(key, const <String>[]);
      }
    },
    timeout: const Timeout(Duration(seconds: 50)),
  );

}
