import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/new_ui/app/dsm_new_ui_shell.dart';
import 'package:dsm_helper/new_ui/legacy/legacy_shared_bootstrap.dart';
import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:dsm_helper/providers/dark_mode.dart';
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
  });

  final String majorVersion;
  final String application;
  int requests = 0;

  Future<InitDataModel> call() async {
    requests += 1;
    return InitDataModel.fromJson({
      'Session': {'majorversion': majorVersion},
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
    ChangeNotifierProvider(
      create: (_) => DarkModeProvider(0),
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
  await tester.tap(find.byKey(const Key('open-legacy-feature')));
  await tester.pumpAndSettle();
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
      await tester.pageBack();
      await tester.pumpAndSettle();

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
}
