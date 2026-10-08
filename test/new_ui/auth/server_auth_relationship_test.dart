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
    // RED on Task 3 startup: it currently loses the exact account and
    // displays the generic selector. Batch 5 supplies an identity handoff.
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
}
