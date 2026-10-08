import 'package:drift/native.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/new_ui/auth/server_account_controller.dart';
import 'package:dsm_helper/new_ui/auth/server_account_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Database db;
  late ServerAccountController controller;

  setUp(() {
    db = Database.forTesting(NativeDatabase.memory());
    controller = ServerAccountController(store: ServerAccountStore(db));
  });
  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  Future<int> addServer(String host) => db.into(db.servers).insert(
        ServersCompanion.insert(
          groupId: 1,
          ssl: true,
          qcid: '',
          domain: host,
          port: 5001,
          checkSsl: true,
          remark: '',
          macAddress: '',
          createTime: 1,
        ),
      );

  Future<int> addAccount(int serverId, String user, {bool isDefault = false}) =>
      db.into(db.accounts).insert(
        AccountsCompanion.insert(
          serverId: serverId,
          account: user,
          password: 'secret-$user',
          remark: '',
          createTime: 1,
          lastLoginTime: 1,
          isDefault: isDefault,
          deviceId: 'device-$user',
          sid: 'sid-$user',
          ikMessage: 'ik-$user',
          synoToken: 'token-$user',
        ),
      );

  test('joined identities: two users give two exact contexts and one address',
      () async {
    final nas = await addServer('nas.local');
    final a = await addAccount(nas, 'alice');
    final b = await addAccount(nas, 'bob');
    final empty = await addServer('empty.local');

    await controller.load();

    expect(controller.items, hasLength(3));
    final joined = controller.items.where((item) => item.server.id == nas).toList();
    expect(joined.map((item) => item.account?.id), [a, b]);
    expect(joined.map((item) => item.account?.account), ['alice', 'bob']);
    expect(joined.map((item) => item.server.domain), ['nas.local', 'nas.local']);
    expect(joined.every((item) => item.canEnter), isTrue);
    final emptyItem = controller.items.singleWhere((item) => item.server.id == empty);
    expect(emptyItem.account, isNull);
    expect(emptyItem.canEnter, isFalse);
    expect(await db.select(db.accounts).get(), hasLength(2));
  });

  test('default selection is global and clearing allows zero defaults',
      () async {
    final aServer = await addServer('a.local');
    final bServer = await addServer('b.local');
    final a = await addAccount(aServer, 'alice', isDefault: true);
    final b = await addAccount(bServer, 'bob');

    await controller.setDefaultAccount(b);
    var all = await db.select(db.accounts).get();
    expect(all.where((account) => account.isDefault).map((a) => a.id), [b]);
    expect(all.singleWhere((account) => account.id == a).password, 'secret-alice');

    await controller.clearDefaultAccount(b);
    all = await db.select(db.accounts).get();
    expect(all.where((account) => account.isDefault), isEmpty);
    expect(all.map((account) => account.sid), ['sid-alice', 'sid-bob']);
  });

  test('deleting the last Account keeps its Server as no-account item',
      () async {
    final server = await addServer('nas.local');
    final account = await addAccount(server, 'alice');
    await controller.deleteAccount(account);
    await controller.load();

    expect(await db.select(db.servers).get(), hasLength(1));
    expect(await db.select(db.accounts).get(), isEmpty);
    expect(controller.items.single.server.id, server);
    expect(controller.items.single.account, isNull);
  });

  test('deleting Server removes only its own Accounts and preserves others',
      () async {
    final a = await addServer('a.local');
    final b = await addServer('b.local');
    await addAccount(a, 'alice');
    await addAccount(a, 'alex');
    final survivor = await addAccount(b, 'bob');

    await controller.deleteServer(a);
    await controller.load();
    expect((await db.select(db.servers).get()).map((s) => s.id), [b]);
    final accounts = await db.select(db.accounts).get();
    expect(accounts.map((account) => account.id), [survivor]);
    expect(controller.items.single.account?.id, survivor);
  });
}
