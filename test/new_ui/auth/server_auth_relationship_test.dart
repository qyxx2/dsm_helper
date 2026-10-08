import 'package:dsm_helper/database/table_extension.dart';
import 'package:dsm_helper/models/api_model.dart';
import 'package:dsm_helper/apis/dsm_api/dsm_exception.dart';
import 'package:dsm_helper/new_ui/app/modern_ui_root.dart';
import 'package:dsm_helper/new_ui/app/new_ui_app_shell.dart';
import 'package:drift/native.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/models/Syno/Api/auth.dart';
import 'package:dsm_helper/new_ui/auth/auth_flow_controller.dart';
import 'package:dsm_helper/new_ui/auth/auth_flow_models.dart';
import 'package:dsm_helper/new_ui/auth/server_account_store.dart';
import 'package:dsm_helper/new_ui/auth/server_form_controller.dart';
import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:dsm_helper/new_ui/startup/modern_startup.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
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

  group('Real Drift auth, server persistence and context activation', () {
    late Database db;
    late ServerAccountStore store;

    setUp(() {
      db = Database.forTesting(NativeDatabase.memory());
      store = ServerAccountStore(db);
    });
    tearDown(() async => db.close());

    Future<({Server server, Account account})> savedAccount() async {
      final server = await db.into(db.servers).insertReturning(
        ServersCompanion.insert(
          groupId: 1, ssl: true, qcid: '', domain: 'nas.local',
          port: 5001, checkSsl: false, remark: '',
          macAddress: '', createTime: 1,
        ),
      );
      final account = await db.into(db.accounts).insertReturning(
        AccountsCompanion.insert(
          serverId: server.id, account: 'alice',
          password: 'stored-password', remark: '',
          createTime: 1, lastLoginTime: 1, isDefault: true,
          deviceId: 'saved-device', sid: 'stale-sid',
          ikMessage: 'ik-old', synoToken: 'old-token',
        ),
      );
      return (server: server, account: account);
    }

    test('no Server -> endpoint validation -> actual login persistence -> activation', () async {
      final form = ServerFormController(
        db: db,
        probe: ({required baseUrl, required checkSsl}) async {
          expect(baseUrl, 'https://nas.local:5001');
          expect(checkSsl, false);
          return {'SYNO.API.Auth': ApiModel(maxVersion: 7)};
        },
        nowEpochSeconds: () => 10,
      );
      final server = await form.submit(
        https: true, host: 'nas.local', port: '',
        checkSsl: false, remark: '',
      );
      expect(server, isNotNull);
      final auth = AuthFlowController(
        server: server!,
        store: store,
        nowEpochSeconds: () => 20,
        login: ({required account, required password, optCode}) async {
          expect(account, 'alice');
          expect(password, 'secret');
          return Auth(
            account: account, deviceId: 'new-device',
            sid: 'new-sid', ikMessage: '',
            synotoken: 'new-token',
          );
        },
      );
      await auth.submitCredentials(
        account: 'alice', password: 'secret', isDefault: true,
      );
      expect(auth.state.stage, AuthFlowStage.authenticated);
      final persisted = (await db.select(db.accounts).get()).single;
      expect(persisted.id, auth.state.authenticatedAccount!.id);
      expect(persisted.serverId, server.id);
      final operations = <String>[];
      final coordinator = ActiveContextCoordinator(
        clearCapabilities: () => operations.add('clear'),
        bindTransport: (req) => operations.add('bind:${req.contextId}:${req.sid}'),
        discoverCapabilities: () async => operations.add('discover'),
        probeSession: () async => operations.add('probe'),
      );
      final result = await coordinator.activate(
        ActiveContextRequest(
          contextId: '${server.id}/${persisted.id}',
          baseUrl: server.url,
          deviceId: persisted.deviceId,
          sid: persisted.sid,
          checkSsl: server.checkSsl,
        ),
      );
      expect(result.status, ActiveContextStatus.authenticated);
      expect(operations, [
        'clear', 'bind:${server.id}/${persisted.id}:new-sid',
        'discover', 'probe',
      ]);
      expect((await db.select(db.servers).get()).length, 1);
      auth.dispose();
      form.dispose();
    });

    test('119 reauth updates exact saved Account and reactivates same context', () async {
      final saved = await savedAccount();
      final operations = <String>[];
      var probes = 0;
      final coordinator = ActiveContextCoordinator(
        clearCapabilities: () => operations.add('clear'),
        bindTransport: (req) => operations.add('bind:${req.contextId}:${req.sid}'),
        discoverCapabilities: () async => operations.add('discover'),
        probeSession: () async {
          probes++;
          if (probes == 1) throw const DsmException(119);
        },
      );
      ActiveContextRequest request(Account account) => ActiveContextRequest(
        contextId: '${saved.server.id}/${account.id}',
        baseUrl: saved.server.url,
        deviceId: account.deviceId,
        sid: account.sid,
        checkSsl: saved.server.checkSsl,
      );
      expect((await coordinator.activate(request(saved.account))).status,
          ActiveContextStatus.reauthNeeded);

      final auth = AuthFlowController(
        server: saved.server,
        existingAccount: saved.account,
        store: store,
        login: ({required account, required password, optCode}) async {
          expect(account, 'alice');
          expect(password, 'stored-password');
          return Auth(account: account, deviceId: 'renewed-device',
              sid: 'renewed-sid', ikMessage: '',
              synotoken: 'renewed-token');
        },
      );
      await auth.reauthenticateSavedAccount();
      expect(auth.state.stage, AuthFlowStage.authenticated);
      final updated = (await db.select(db.accounts).get()).single;
      expect(updated.id, saved.account.id);
      expect(updated.sid, 'renewed-sid');
      expect(updated.isDefault, true);
      final result = await coordinator.activate(request(updated));
      expect(result.status, ActiveContextStatus.authenticated);
      expect(result.contextId, '${saved.server.id}/${saved.account.id}');
      expect(operations, [
        'clear', 'bind:${saved.server.id}/${saved.account.id}:stale-sid',
        'discover', 'clear',
        'bind:${saved.server.id}/${saved.account.id}:renewed-sid',
        'discover',
      ]);
      expect((await db.select(db.accounts).get()).length, 1);
      auth.dispose();
    });
  });

  testWidgets('Modern root starts at Modern add-server without legacy builders or activation',
      (tester) async {
    var activations = 0;
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.light(),
      home: ModernUiRoot(
        initialAuthRequired: false,
        initializeDownloader: false,
        dataSource: const _StartupSource(StartupSnapshot(
          hasServers: false, launcherSelectionEnabled: false,
          knownServerIds: <int>{},
          contexts: <StartupSavedContext>[],
        )),
        contextActivator: (_) async {
          activations++;
          throw StateError('No account should activate');
        },
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('server-form-host')), findsOneWidget);
    expect(find.byKey(const Key('server-form-submit')), findsOneWidget);
    final formTheme = Theme.of(
      tester.element(find.byKey(const Key('server-form-host'))),
    );
    expect(formTheme.colorScheme.primary, NewUiTheme.light().colorScheme.primary);
    expect(formTheme.useMaterial3, isTrue);
    expect(activations, 0);
    await tester.pumpWidget(const SizedBox());
  }, timeout: const Timeout(Duration(seconds: 45)));

  testWidgets('Modern root cold-start forwards exact activated context and offline status',
      (tester) async {
    ActiveContextRequest? bound;
    await tester.pumpWidget(MaterialApp(
      home: ModernUiRoot(
        initialAuthRequired: false,
        initializeDownloader: false,
        dataSource: const _StartupSource(StartupSnapshot(
          hasServers: true, launcherSelectionEnabled: false,
          knownServerIds: <int>{7},
          contexts: <StartupSavedContext>[_saved],
        )),
        contextActivator: (req) async {
          bound = req;
          return const ActiveContextResult(
            contextId: '7/42', status: ActiveContextStatus.offline,
          );
        },
        shellBuilder: (_, result) =>
            _marker('shell-${result.status.name}-${result.contextId}'),
      ),
    ));
    await tester.pumpAndSettle();
    expect(bound?.contextId, '7/42');
    expect(bound?.sid, 'sid-42');
    expect(bound?.checkSsl, false);
    expect(find.text('shell-offline-7/42'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  }, timeout: const Timeout(Duration(seconds: 45)));

  testWidgets('Modern root activation failure does not create a shell',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ModernUiRoot(
        initialAuthRequired: false,
        initializeDownloader: false,
        dataSource: const _StartupSource(StartupSnapshot(
          hasServers: true, launcherSelectionEnabled: false,
          knownServerIds: <int>{7},
          contexts: <StartupSavedContext>[_saved],
        )),
        contextActivator: (_) async => ActiveContextResult(
          contextId: '7/42', status: ActiveContextStatus.failed,
          error: StateError('capabilities failed'),
        ),
        shellBuilder: (_, __) => _marker('shell'),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('shell'), findsNothing);
    expect(find.text('重试'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  }, timeout: const Timeout(Duration(seconds: 45)));

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
