import 'package:drift/native.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/new_ui/auth/logout_controller.dart';
import 'package:dsm_helper/new_ui/auth/server_account_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Database db;
  late ServerAccountStore store;
  late int serverId;
  late int accountId;
  late int siblingId;

  setUp(() async {
    db = Database.forTesting(NativeDatabase.memory());
    store = ServerAccountStore(db);
    serverId = await db.into(db.servers).insert(
      ServersCompanion.insert(
        groupId: 1,
        ssl: true,
        qcid: '',
        domain: 'nas.local',
        port: 5001,
        checkSsl: true,
        remark: 'My NAS',
        macAddress: '',
        createTime: 1,
      ),
    );
    accountId = await db.into(db.accounts).insert(
      AccountsCompanion.insert(
        serverId: serverId,
        account: 'alice',
        password: 'keep-password',
        remark: '',
        createTime: 1,
        lastLoginTime: 2,
        isDefault: true,
        deviceId: 'trusted-device',
        sid: 'active-sid',
        ikMessage: 'active-ik',
        synoToken: 'active-token',
      ),
    );
    siblingId = await db.into(db.accounts).insert(
      AccountsCompanion.insert(
        serverId: serverId,
        account: 'bob',
        password: 'other-password',
        remark: '',
        createTime: 1,
        lastLoginTime: 2,
        isDefault: false,
        deviceId: 'other-device',
        sid: 'other-sid',
        ikMessage: 'other-ik',
        synoToken: 'other-token',
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<Account> accountById(int id) =>
      (db.select(db.accounts)..where((a) => a.id.equals(id))).getSingle();

  test('successful logout clears only selected session then exits locally',
      () async {
    final events = <String>[];
    final controller = LogoutController(
      store: store,
      remoteLogout: () async {
        events.add('remote-logout');
        return true;
      },
      remoteForget: () async {
        events.add('forget');
        return true;
      },
      onLocalExit: () => events.add('exit'),
    );

    await controller.logout(accountId: accountId);

    expect(events, ['remote-logout', 'exit']);
    final saved = await accountById(accountId);
    expect(saved.id, accountId);
    expect(saved.serverId, serverId);
    expect(saved.account, 'alice');
    expect(saved.password, 'keep-password');
    expect(saved.isDefault, isTrue);
    expect(saved.deviceId, 'trusted-device');
    expect(saved.sid, isEmpty);
    expect(saved.synoToken, isEmpty);
    expect(saved.ikMessage, isEmpty);
    expect((await accountById(siblingId)).sid, 'other-sid');
    expect(await db.select(db.servers).get(), hasLength(1));
  });

  test('forget requested attempts forget before logout and retains account',
      () async {
    final calls = <String>[];
    final controller = LogoutController(
      store: store,
      remoteForget: () async {
        calls.add('forget');
        return true;
      },
      remoteLogout: () async {
        calls.add('logout');
        return true;
      },
      onLocalExit: () => calls.add('exit'),
    );

    await controller.logout(accountId: accountId, forgetDevice: true);

    expect(calls, ['forget', 'logout', 'exit']);
    expect((await accountById(accountId)).password, 'keep-password');
  });

  test('network failures and remote false never prevent local SID cleanup',
      () async {
    final events = <String>[];
    final controller = LogoutController(
      store: store,
      remoteForget: () async {
        events.add('forget');
        throw Exception('DSM unreachable');
      },
      remoteLogout: () async {
        events.add('logout');
        return false;
      },
      onLocalExit: () => events.add('exit'),
    );
    await controller.logout(accountId: accountId, forgetDevice: true);
    expect(events, ['forget', 'logout', 'exit']);
    expect((await accountById(accountId)).sid, isEmpty);
    expect((await accountById(siblingId)).sid, 'other-sid');
    expect((await accountById(accountId)).isDefault, isTrue);
  });

  test('logout exception still clears session and returns to selector', () async {
    var exited = 0;
    final controller = LogoutController(
      store: store,
      remoteLogout: () async => throw Exception('offline'),
      onLocalExit: () => exited++,
    );
    await controller.logout(accountId: accountId);
    expect(exited, 1);
    expect((await accountById(accountId)).sid, isEmpty);
  });

  test('missing account does not report a successful local exit', () async {
    var exited = 0;
    final controller = LogoutController(
      store: store,
      remoteLogout: () async => true,
      onLocalExit: () => exited++,
    );
    await expectLater(
      controller.logout(accountId: 999999),
      throwsA(isA<StateError>()),
    );
    expect(exited, 0);
    expect((await accountById(accountId)).sid, 'active-sid');
  });

  testWidgets('confirmation forwards opt-in forget and cancel is harmless',
      (tester) async {
    final controller = _RecordingLogoutController(store: store);
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showLogoutConfirmation(
              context,
              controller: controller,
              accountId: accountId,
            ),
            child: const Text('打开登出'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('打开登出'));
    await tester.pumpAndSettle();
    expect(find.text('退出登录'), findsOneWidget);
    expect(find.text('取消记住本设备'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(controller.requests, isEmpty);

    await tester.tap(find.text('打开登出'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消记住本设备'));
    await tester.pump();
    await tester.tap(find.text('退出登录'));
    await tester.pumpAndSettle();
    expect(controller.requests, [(accountId, true)]);
  });
}

class _RecordingLogoutController extends LogoutController {
  _RecordingLogoutController({required super.store})
      : super(remoteLogout: _fakeRemoteLogout);

  final List<(int, bool)> requests = [];

  static Future<bool> _fakeRemoteLogout() async => true;

  @override
  Future<void> logout({
    required int accountId,
    bool forgetDevice = false,
  }) async {
    requests.add((accountId, forgetDevice));
  }
}
