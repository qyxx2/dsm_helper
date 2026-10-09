import 'dart:async';

import 'package:drift/native.dart';
import 'package:dsm_helper/apis/dsm_api/dsm_exception.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/models/Syno/Api/auth.dart';
import 'package:dsm_helper/models/Syno/Core/Notify.dart';
import 'package:dsm_helper/models/Syno/Core/System.dart';
import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';
import 'package:dsm_helper/new_ui/app/dsm_new_ui_shell.dart';
import 'package:dsm_helper/new_ui/app/modern_ui_root.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_controller.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_data_source.dart';
import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:dsm_helper/new_ui/startup/modern_startup.dart';
import 'package:dsm_helper/providers/dark_mode.dart';
import 'package:dsm_helper/providers/setting_provider.dart';
import 'package:dsm_helper/utils/db_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_util/sp_util.dart';

class _SavedSource implements StartupDataSource {
  const _SavedSource(this.context);
  final StartupSavedContext context;

  @override
  Future<StartupSnapshot> load() async => StartupSnapshot(
        hasServers: true,
        launcherSelectionEnabled: false,
        knownServerIds: {context.serverId},
        contexts: [context],
      );
}

OverviewDataSource _source(Future<System?> Function() system,
    {Future<Storage?> Function()? storage}) =>
    OverviewDataSource(
      loadSystem: system,
      loadUtilization: () async => Utilization(),
      loadStorage: storage ?? (() async => Storage()),
      loadNotifications: () async => DsmNotify(),
    );

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await SpUtil.getInstance();
  });

  test('two 119 sources invalidate once, while transport and non-119 errors do not', () async {
    var reauth = 0;
    final invalid = OverviewController(
      dataSource: _source(
        () async => throw const DsmException(119),
        storage: () async => throw const DsmException(119),
      ),
      refreshInterval: const Duration(seconds: 10),
      onAuthInvalidated: (_) => reauth++,
    );
    await invalid.loadInitial();
    await invalid.refresh();
    expect(reauth, 1);
    invalid.dispose();

    final other = OverviewController(
      dataSource: _source(() async => throw const DsmException(105),
          storage: () async => throw StateError('transport offline')),
      refreshInterval: const Duration(seconds: 10),
      onAuthInvalidated: (_) => reauth++,
    );
    await other.loadInitial();
    expect(reauth, 1);
    other.dispose();
  }, timeout: const Timeout(Duration(seconds: 15)));

  testWidgets(
    'runtime shell auth signal reuses exact saved account and defers persistence until login success',
    (tester) async {
      final originalDb = DbUtils.db;
      final db = Database.forTesting(NativeDatabase.memory());
      DbUtils.db = db;
      try {
        final server = await db.into(db.servers).insertReturning(
              ServersCompanion.insert(
                groupId: 1, ssl: false, qcid: '', domain: 'nas.local',
                port: 5000, checkSsl: false, remark: '',
                macAddress: '', createTime: 1,
              ),
            );
        final account = await db.into(db.accounts).insertReturning(
              AccountsCompanion.insert(
                serverId: server.id, account: 'alice',
                password: 'stored-password', remark: '',
                createTime: 1, lastLoginTime: 1, isDefault: true,
                deviceId: 'old-device', sid: 'stale-sid',
                ikMessage: 'old-ik', synoToken: 'old-token',
              ),
            );
        final contextId = '${server.id}/${account.id}';
        final pendingAuth = Completer<Auth>();
        var logins = 0;
        var activations = 0;
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => DarkModeProvider(0)),
              ChangeNotifierProvider(create: (_) => SettingProvider()),
            ],
            child: MaterialApp(
              home: ModernUiRoot(
                initialAuthRequired: false,
                initializeDownloader: false,
                dataSource: _SavedSource(StartupSavedContext(
                  accountId: account.id, serverId: server.id,
                  isDefault: true, baseUrl: server.url,
                  deviceId: account.deviceId, sid: account.sid,
                  checkSsl: server.checkSsl,
                )),
                contextActivator: (request) async {
                  activations++;
                  expect(request.contextId, contextId);
                  return ActiveContextResult(
                    contextId: contextId,
                    status: ActiveContextStatus.offline,
                  );
                },
                loginPreparation: (server, savedAccount) async {
                  expect(server.id, account.serverId);
                  expect(savedAccount?.id, account.id);
                },
                authLogin: ({required account, required password, optCode}) {
                  expect(account, 'alice');
                  expect(password, 'stored-password');
                  logins++;
                  return pendingAuth.future;
                },
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        final shell = tester.widget<DsmNewUiShell>(find.byType(DsmNewUiShell));
        expect(shell.contextId, contextId);
        expect(shell.onReauthNeeded, isNotNull);
        shell.onReauthNeeded!();
        shell.onReauthNeeded!();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(logins, 1);
        final before = (await db.select(db.accounts).get()).single;
        expect(before.id, account.id);
        expect(before.sid, 'stale-sid');
        expect(before.isDefault, true);

        pendingAuth.complete(Auth(
          account: 'alice', deviceId: 'new-device',
          sid: 'renewed-sid', ikMessage: '', synotoken: 'new-token',
        ));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        final updated = (await db.select(db.accounts).get()).single;
        expect(updated.id, account.id);
        expect(updated.sid, 'renewed-sid');
        expect(updated.isDefault, true);
        expect(logins, 1);
        expect(activations, greaterThanOrEqualTo(1));
      } finally {
        await tester.pumpWidget(const SizedBox());
        DbUtils.db = originalDb;
        await db.close();
      }
    },
    timeout: const Timeout(Duration(seconds: 45)),
  );
}
