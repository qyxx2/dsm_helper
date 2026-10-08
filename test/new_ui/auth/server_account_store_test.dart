import 'package:drift/native.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/new_ui/auth/server_account_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Database db;
  late ServerAccountStore store;

  setUp(() {
    db = Database.forTesting(NativeDatabase.memory());
    store = ServerAccountStore(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> insertServer(String domain) {
    return db.into(db.servers).insert(
          ServersCompanion.insert(
            groupId: 0,
            ssl: false,
            qcid: '',
            domain: domain,
            port: 5000,
            checkSsl: true,
            remark: '',
            macAddress: '',
            createTime: 1,
          ),
        );
  }

  Future<int> insertAccount({
    required int serverId,
    required String account,
    bool isDefault = false,
  }) {
    return db.into(db.accounts).insert(
          AccountsCompanion.insert(
            serverId: serverId,
            account: account,
            password: 'password',
            remark: '',
            createTime: 1,
            lastLoginTime: 1,
            isDefault: isDefault,
            deviceId: 'device-$account',
            sid: 'sid-$account',
            ikMessage: '',
            synoToken: '',
          ),
        );
  }

  test('deleteServer removes only accounts owned by the target server', () async {
    final serverA = await insertServer('a.local');
    final serverB = await insertServer('b.local');
    await insertAccount(serverId: serverA, account: 'a1');
    await insertAccount(serverId: serverA, account: 'a2');
    final accountB = await insertAccount(serverId: serverB, account: 'b1');

    await store.deleteServer(serverA);

    final servers = await db.select(db.servers).get();
    final accounts = await db.select(db.accounts).get();

    expect(servers.map((server) => server.id), [serverB]);
    expect(accounts.map((account) => account.id), [accountB]);
    expect(accounts.single.serverId, serverB);
  });

  test('setDefaultAccount clears every other default before setting target', () async {
    final serverA = await insertServer('a.local');
    final serverB = await insertServer('b.local');
    final accountA = await insertAccount(
      serverId: serverA,
      account: 'a',
      isDefault: true,
    );
    final accountB = await insertAccount(
      serverId: serverB,
      account: 'b',
      isDefault: true,
    );

    await store.setDefaultAccount(accountB);

    final accounts = await db.select(db.accounts).get();
    final defaults = accounts.where((account) => account.isDefault).toList();

    expect(defaults, hasLength(1));
    expect(defaults.single.id, accountB);
    expect(
      accounts.singleWhere((account) => account.id == accountA).isDefault,
      isFalse,
    );
  });

  test('clearDefaultAccount permits zero default accounts', () async {
    final server = await insertServer('nas.local');
    final account = await insertAccount(
      serverId: server,
      account: 'user',
      isDefault: true,
    );

    await store.clearDefaultAccount(account);

    final accounts = await db.select(db.accounts).get();
    expect(accounts.where((value) => value.isDefault), isEmpty);
  });

  test('setDefaultAccount rolls back when the target account does not exist', () async {
    final server = await insertServer('nas.local');
    final original = await insertAccount(
      serverId: server,
      account: 'original',
      isDefault: true,
    );

    expect(
      () => store.setDefaultAccount(999999),
      throwsA(isA<StateError>()),
    );

    final accounts = await db.select(db.accounts).get();
    expect(accounts.single.id, original);
    expect(accounts.single.isDefault, isTrue);
  });
}
