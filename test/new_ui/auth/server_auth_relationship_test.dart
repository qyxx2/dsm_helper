import 'package:dsm_helper/database/table_extension.dart';
import 'package:dsm_helper/models/api_model.dart';
import 'package:dsm_helper/new_ui/app/modern_ui_root.dart';
import 'package:dsm_helper/new_ui/app/new_ui_app_shell.dart';
import 'package:dsm_helper/utils/db_utils.dart';
import 'package:drift/native.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/models/Syno/Api/auth.dart';
import 'package:dsm_helper/new_ui/auth/auth_flow_controller.dart';
import 'package:dsm_helper/new_ui/auth/auth_flow_models.dart';
import 'package:dsm_helper/new_ui/auth/server_account_store.dart';
import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:dsm_helper/new_ui/startup/modern_startup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _StartupSource implements StartupDataSource {
  const _StartupSource(this.snapshot);
  final StartupSnapshot snapshot;

  @override
  Future<StartupSnapshot> load() async => snapshot;
}

Widget _marker(String name) => Scaffold(body: Text(name));

const _saved = StartupSavedContext(
  accountId: 42,
  serverId: 7,
  isDefault: true,
  baseUrl: 'https://nas.local:5001',
  deviceId: 'device-42',
  sid: 'sid-42',
  checkSsl: false,
);

void main() {
  testWidgets('cold start without servers and forced launcher selection never activate', (tester) async {
    var activations = 0;
    final snapshots = [
      const StartupSnapshot(
        hasServers: false,
        launcherSelectionEnabled: false,
        knownServerIds: <int>{},
        contexts: <StartupSavedContext>[],
      ),
      const StartupSnapshot(
        hasServers: true,
        launcherSelectionEnabled: true,
        knownServerIds: <int>{7},
        contexts: <StartupSavedContext>[_saved],
      ),
    ];
    for (var i = 0; i < snapshots.length; i++) {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey(i),
        home: ModernStartup(
          key: ValueKey(i),
          dataSource: _StartupSource(snapshots[i]),
          activateContext: (_) async {
            activations++;
            throw StateError('unexpected activation');
          },
          addServerBuilder: (_) => _marker('modern-add-server'),
          selectAccountBuilder: (_) => _marker('modern-selector'),
          shellBuilder: (_, __) => _marker('shell'),
        ),
      ));
      await tester.pumpAndSettle();
      expect(
        find.text(i == 0 ? 'modern-add-server' : 'modern-selector'),
        findsOneWidget,
      );
    }
    expect(activations, 0);
  });

  testWidgets('unique default binds exact context and forwards offline status', (tester) async {
    ActiveContextRequest? request;
    await tester.pumpWidget(MaterialApp(
      home: ModernStartup(
        dataSource: const _StartupSource(StartupSnapshot(
          hasServers: true,
          launcherSelectionEnabled: false,
          knownServerIds: <int>{7},
          contexts: <StartupSavedContext>[_saved],
        )),
        activateContext: (value) async {
          request = value;
          return const ActiveContextResult(
            contextId: '7/42',
            status: ActiveContextStatus.offline,
          );
        },
        addServerBuilder: (_) => _marker('modern-add-server'),
        selectAccountBuilder: (_) => _marker('modern-selector'),
        shellBuilder: (_, result) => _marker('shell-${result.status.name}-${result.contextId}'),
      ),
    ));
    await tester.pumpAndSettle();
    expect(request?.contextId, '7/42');
    expect(request?.deviceId, 'device-42');
    expect(request?.sid, 'sid-42');
    expect(request?.checkSsl, false);
    expect(find.text('shell-offline-7/42'), findsOneWidget);
  });

  testWidgets('119 on unique default must not degrade to generic selector', (tester) async {
    StartupSavedContext? exactReauth;
    await tester.pumpWidget(MaterialApp(
      home: ModernStartup(
        dataSource: const _StartupSource(StartupSnapshot(
          hasServers: true,
          launcherSelectionEnabled: false,
          knownServerIds: <int>{7},
          contexts: <StartupSavedContext>[_saved],
        )),
        activateContext: (_) async => const ActiveContextResult(
          contextId: '7/42',
          status: ActiveContextStatus.reauthNeeded,
        ),
        addServerBuilder: (_) => _marker('modern-add-server'),
        selectAccountBuilder: (_) => _marker('modern-selector'),
        shellBuilder: (_, __) => _marker('shell'),
        onReauthNeeded: (value) => exactReauth = value,
      ),
    ));
    await tester.pumpAndSettle();
    expect(exactReauth?.serverId, 7);
    expect(exactReauth?.accountId, 42);
    expect(find.text('modern-selector'), findsNothing);
    expect(find.text('shell'), findsNothing);
  });

  test('successful login persists before activation and switch clears old capability state', () async {
    final db = Database.forTesting(NativeDatabase.memory());
    try {
      final serverId = await db.into(db.servers).insert(
        ServersCompanion.insert(
          groupId: 1, ssl: true, qcid: '', domain: 'nas.local',
          port: 5001, checkSsl: false, remark: '',
          macAddress: '', createTime: 1,
        ),
      );
      final server = await (db.select(db.servers)
            ..where((table) => table.id.equals(serverId))).getSingle();
      final store = ServerAccountStore(db);
      final controller = AuthFlowController(
        server: server,
        store: store,
        login: ({required account, required password, optCode}) async =>
            Auth(account: account, deviceId: 'new-device', sid: 'new-sid',
                 ikMessage: '', synotoken: 'new-token'),
        nowEpochSeconds: () => 2,
      );
      final operations = <String>[];
      final coordinator = ActiveContextCoordinator(
        clearCapabilities: () => operations.add('clear'),
        bindTransport: (request) => operations.add('bind:${request.contextId}:${request.sid}'),
        discoverCapabilities: () async => operations.add('discover'),
        probeSession: () async => operations.add('probe'),
      );
      await controller.submitCredentials(
        account: 'user', password: 'pass', isDefault: true,
      );
      expect(controller.state.stage, AuthFlowStage.authenticated);
      final saved = controller.state.authenticatedAccount!;
      expect(saved.sid, 'new-sid');
      final result = await coordinator.activate(ActiveContextRequest(
        contextId: '${server.id}/${saved.id}',
        baseUrl: 'https://nas.local:5001',
        deviceId: saved.deviceId,
        sid: saved.sid,
        checkSsl: server.checkSsl,
      ));
      expect(result.status, ActiveContextStatus.authenticated);
      expect(operations, [
        'clear', 'bind:${server.id}/${saved.id}:new-sid',
        'discover', 'probe',
      ]);
      operations.clear();
      await coordinator.activate(const ActiveContextRequest(
        contextId: '8/88', baseUrl: 'http://other:5000',
        deviceId: 'other-device', sid: 'other-sid',
      ));
      expect(operations.first, 'clear');
      expect(operations[1], 'bind:8/88:other-sid');
      expect((await db.select(db.accounts).get()).single.id, saved.id);
    } finally {
      await db.close();
    }
  });

  testWidgets('failed activation cannot open shell', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ModernStartup(
        dataSource: const _StartupSource(StartupSnapshot(
          hasServers: true,
          launcherSelectionEnabled: false,
          knownServerIds: <int>{7},
          contexts: <StartupSavedContext>[_saved],
        )),
        activateContext: (_) async => ActiveContextResult(
          contextId: '7/42',
          status: ActiveContextStatus.failed,
          error: StateError('failed to discover capabilities'),
        ),
        addServerBuilder: (_) => _marker('modern-add-server'),
        selectAccountBuilder: (_) => _marker('modern-selector'),
        shellBuilder: (_, __) => _marker('shell'),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('shell'), findsNothing);
    expect(find.text('重试'), findsOneWidget);
  });

  group('Modern root production handoff with real Drift persistence', () {
    late Database originalDb;
    late Database db;

    setUp(() {
      originalDb = DbUtils.db;
      db = Database.forTesting(NativeDatabase.memory());
      DbUtils.db = db;
    });

    tearDown(() async {
      DbUtils.db = originalDb;
      await db.close();
    });

    Future<({Server server, Account account})> savedAccount() async {
      final id = await db.into(db.servers).insert(
        ServersCompanion.insert(
          groupId: 1,
          ssl: true,
          qcid: '',
          domain: 'nas.local',
          port: 5001,
          checkSsl: false,
          remark: '',
          macAddress: '',
          createTime: 1,
        ),
      );
      final server = await (db.select(db.servers)
            ..where((row) => row.id.equals(id)))
          .getSingle();
      final accountId = await db.into(db.accounts).insert(
        AccountsCompanion.insert(
          serverId: server.id,
          account: 'alice',
          password: 'stored-password',
          remark: '',
          createTime: 1,
          lastLoginTime: 1,
          isDefault: true,
          deviceId: 'saved-device',
          sid: 'stale-sid',
          ikMessage: 'ik-old',
          synoToken: 'old-token',
        ),
      );
      final account = await (db.select(db.accounts)
            ..where((row) => row.id.equals(accountId)))
          .getSingle();
      return (server: server, account: account);
    }

    testWidgets('no-server modern form -> login -> real persisted account -> activation -> shell',
        (tester) async {
      final activations = <ActiveContextRequest>[];
      await tester.pumpWidget(MaterialApp(
        home: ModernUiRoot(
          initialAuthRequired: false,
          initializeDownloader: false,
          dataSource: const _StartupSource(StartupSnapshot(
            hasServers: false,
            launcherSelectionEnabled: false,
            knownServerIds: <int>{},
            contexts: <StartupSavedContext>[],
          )),
          serverProbe: ({required baseUrl, required checkSsl}) async =>
              <String, ApiModel>{'SYNO.API.Auth': ApiModel(maxVersion: 7)},
          loginPreparation: (server, account) async {},
          authLogin: ({required account, required password, optCode}) async =>
              Auth(
                account: account,
                deviceId: 'new-device',
                sid: 'new-sid',
                ikMessage: '',
                synotoken: 'new-token',
              ),
          contextActivator: (request) async {
            activations.add(request);
            return ActiveContextResult(
              contextId: request.contextId,
              status: ActiveContextStatus.authenticated,
            );
          },
          shellBuilder: (_, result) =>
              _marker('shell-${result.status.name}-${result.contextId}'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('server-form-host')), findsOneWidget);
      await tester.enterText(
          find.byKey(const Key('server-form-host')), 'nas.local');
      await tester.tap(find.byKey(const Key('server-form-submit')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('auth-account')), findsOneWidget);
      await tester.enterText(find.byKey(const Key('auth-account')), 'alice');
      await tester.enterText(find.byKey(const Key('auth-password')), 'pass');
      await tester.tap(find.byKey(const Key('auth-submit')));
      await tester.pumpAndSettle();

      final accounts = await db.select(db.accounts).get();
      final servers = await db.select(db.servers).get();
      expect(accounts.length, 1);
      expect(servers.length, 1);
      expect(activations.length, 1);
      expect(activations.single.contextId,
          '${servers.single.id}/${accounts.single.id}');
      expect(activations.single.sid, 'new-sid');
      expect(find.text('shell-authenticated-${activations.single.contextId}'),
          findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    }, timeout: const Timeout(Duration(seconds: 45)));

    testWidgets('cold-start 119 reauthenticates the exact saved row without duplication',
        (tester) async {
      final saved = await savedAccount();
      final requests = <ActiveContextRequest>[];
      var logins = 0;
      await tester.pumpWidget(MaterialApp(
        home: ModernUiRoot(
          initialAuthRequired: false,
          initializeDownloader: false,
          dataSource: _StartupSource(StartupSnapshot(
            hasServers: true,
            launcherSelectionEnabled: false,
            knownServerIds: {saved.server.id},
            contexts: [
              StartupSavedContext(
                serverId: saved.server.id,
                accountId: saved.account.id,
                isDefault: true,
                baseUrl: saved.server.url,
                deviceId: saved.account.deviceId,
                sid: saved.account.sid,
                checkSsl: saved.server.checkSsl,
              ),
            ],
          )),
          loginPreparation: (server, account) async {
            expect(server.id, saved.server.id);
            expect(account?.id, saved.account.id);
          },
          authLogin: ({required account, required password, optCode}) async {
            logins++;
            expect(account, 'alice');
            expect(password, 'stored-password');
            return Auth(
              account: account,
              deviceId: 'new-device',
              sid: 'renewed-sid',
              ikMessage: '',
              synotoken: 'renewed-token',
            );
          },
          contextActivator: (request) async {
            requests.add(request);
            return ActiveContextResult(
              contextId: request.contextId,
              status: requests.length == 1
                  ? ActiveContextStatus.reauthNeeded
                  : ActiveContextStatus.authenticated,
            );
          },
          shellBuilder: (_, result) => _marker('shell-${result.contextId}'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(logins, 1);
      expect(requests.length, 2);
      expect(requests.first.sid, 'stale-sid');
      expect(requests.last.sid, 'renewed-sid');
      expect(requests.last.contextId,
          '${saved.server.id}/${saved.account.id}');
      final after = await db.select(db.accounts).get();
      expect(after.length, 1);
      expect(after.single.id, saved.account.id);
      expect(after.single.sid, 'renewed-sid');
      expect(find.text('shell-${requests.last.contextId}'), findsOneWidget);
      expect(find.byKey(const Key('auth-account')), findsNothing);
      await tester.pumpWidget(const SizedBox());
    }, timeout: const Timeout(Duration(seconds: 45)));

    testWidgets('launcher selection activates the chosen saved identity before shell',
        (tester) async {
      final saved = await savedAccount();
      ActiveContextRequest? activation;
      await tester.pumpWidget(MaterialApp(
        home: ModernUiRoot(
          initialAuthRequired: false,
          initializeDownloader: false,
          dataSource: _StartupSource(StartupSnapshot(
            hasServers: true,
            launcherSelectionEnabled: true,
            knownServerIds: {saved.server.id},
            contexts: [
              StartupSavedContext(
                serverId: saved.server.id,
                accountId: saved.account.id,
                isDefault: true,
                baseUrl: saved.server.url,
                deviceId: saved.account.deviceId,
                sid: saved.account.sid,
                checkSsl: saved.server.checkSsl,
              ),
            ],
          )),
          contextActivator: (request) async {
            activation = request;
            return ActiveContextResult(
              contextId: request.contextId,
              status: ActiveContextStatus.offline,
            );
          },
          shellBuilder: (_, result) => _marker('shell-${result.status.name}'),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('server-account-${saved.account.id}')),
          findsOneWidget);
      expect(activation, isNull);
      await tester.tap(find.byKey(Key('server-account-${saved.account.id}')));
      await tester.pumpAndSettle();
      expect(activation?.contextId,
          '${saved.server.id}/${saved.account.id}');
      expect(activation?.checkSsl, false);
      expect(find.text('shell-offline'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    }, timeout: const Timeout(Duration(seconds: 45)));

    testWidgets('post-login activation failure never presents shell',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ModernUiRoot(
          initialAuthRequired: false,
          initializeDownloader: false,
          dataSource: const _StartupSource(StartupSnapshot(
            hasServers: false,
            launcherSelectionEnabled: false,
            knownServerIds: <int>{},
            contexts: <StartupSavedContext>[],
          )),
          serverProbe: ({required baseUrl, required checkSsl}) async =>
              <String, ApiModel>{'SYNO.API.Auth': ApiModel(maxVersion: 7)},
          loginPreparation: (server, account) async {},
          authLogin: ({required account, required password, optCode}) async =>
              Auth(
                account: account,
                deviceId: 'device',
                sid: 'sid',
                ikMessage: '',
                synotoken: 'token',
              ),
          contextActivator: (request) async => ActiveContextResult(
            contextId: request.contextId,
            status: ActiveContextStatus.failed,
            error: StateError('invalid context'),
          ),
          shellBuilder: (_, __) => _marker('shell'),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const Key('server-form-host')), 'nas.local');
      await tester.tap(find.byKey(const Key('server-form-submit')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('auth-account')), 'alice');
      await tester.enterText(find.byKey(const Key('auth-password')), 'pass');
      await tester.tap(find.byKey(const Key('auth-submit')));
      await tester.pumpAndSettle();
      expect(find.text('shell'), findsNothing);
      expect(find.text('无法激活此账号，请重试'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    }, timeout: const Timeout(Duration(seconds: 45)));
  });

  testWidgets('My tab exposes scoped modern management/logout without losing legacy fallback',
      (tester) async {
    var manage = 0;
    var logout = 0;
    final destinations = [
      for (final label in ['概览', '文件', '应用', '任务', '我的'])
        NewUiAppDestination.test(
          label: label,
          legacyBuilder: (_) => _marker('legacy-$label'),
        ),
    ];
    await tester.pumpWidget(MaterialApp(
      home: NewUiAppShell(
        notificationBuilder: (_) => _marker('notifications'),
        destinations: destinations,
        onOpenAccountManagement: () => manage++,
        onLogout: () => logout++,
      ),
    ));
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('modern-manage-accounts')));
    expect(manage, 1);
    await tester.tap(find.byKey(const Key('modern-logout')));
    expect(logout, 1);
    expect(find.byKey(const Key('open-legacy-feature')), findsOneWidget);
    await tester.tap(find.text('文件'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('modern-manage-accounts')), findsNothing);
    expect(find.byKey(const Key('modern-logout')), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 45)));

}
