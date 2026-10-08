import 'package:drift/native.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/new_ui/auth/server_account_controller.dart';
import 'package:dsm_helper/new_ui/auth/server_account_page.dart';
import 'package:dsm_helper/new_ui/auth/server_account_store.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestSelectorController extends ServerAccountController {
  TestSelectorController({
    required super.store,
    required this.entries,
  });

  final List<ServerAccountItem> entries;
  @override
  List<ServerAccountItem> get items => entries;
  @override
  Future<void> load() async {}
}

void main() {
  late Database db;
  setUp(() => db = Database.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  const nas = Server(
    id: 1, groupId: 1, ssl: true, qcid: '', domain: 'nas.local',
    port: 5001, checkSsl: true, remark: '', macAddress: '', createTime: 1,
    hostname: 'Family NAS',
  );
  const noAccounts = Server(
    id: 2, groupId: 1, ssl: false, qcid: '', domain: 'empty.local',
    port: 5000, checkSsl: true, remark: '', macAddress: '', createTime: 1,
  );
  const alice = Account(
    id: 11, serverId: 1, account: 'alice', password: 'secret',
    remark: '', createTime: 1, lastLoginTime: 1, isDefault: true,
    deviceId: 'd1', sid: 's1', ikMessage: '', synoToken: '',
  );
  const bob = Account(
    id: 12, serverId: 1, account: 'bob', password: 'secret',
    remark: '', createTime: 1, lastLoginTime: 1, isDefault: false,
    deviceId: 'd2', sid: 's2', ikMessage: '', synoToken: '',
  );

  testWidgets('cards preserve exact server/account identities and zero-account item',
      (tester) async {
    final controller = TestSelectorController(
      store: ServerAccountStore(db),
      entries: const [
        ServerAccountItem(server: nas, account: alice),
        ServerAccountItem(server: nas, account: bob),
        ServerAccountItem(server: noAccounts),
      ],
    );
    addTearDown(controller.dispose);
    ServerAccountItem? selected;
    Server? addAccountFor;
    await tester.pumpWidget(MaterialApp(
      theme: NewUiTheme.light(),
      home: ServerAccountPage(
        controller: controller,
        onSelected: (entry) => selected = entry,
        onAddAccount: (server) => addAccountFor = server,
      ),
    ));

    expect(find.text('nas.local:5001'), findsNWidgets(2));
    expect(find.text('alice'), findsOneWidget);
    expect(find.text('bob'), findsOneWidget);
    expect(find.text('未添加账号'), findsOneWidget);
    expect(find.byKey(const Key('server-account-11')), findsOneWidget);
    expect(find.byKey(const Key('server-account-12')), findsOneWidget);
    expect(find.byKey(const Key('server-no-account-2')), findsOneWidget);
    expect(find.textContaining('CPU'), findsNothing);

    await tester.tap(find.byKey(const Key('server-account-12')));
    expect(selected?.server.id, 1);
    expect(selected?.account?.id, 12);

    await tester.tap(find.byKey(const Key('server-no-account-2')));
    expect(selected?.account?.id, 12);
    await tester.tap(find.byKey(const Key('add-account-2')));
    expect(addAccountFor?.id, 2);
  });

  testWidgets('long press exposes server-scoped edit and account actions only',
      (tester) async {
    final controller = TestSelectorController(
      store: ServerAccountStore(db),
      entries: const [
        ServerAccountItem(server: nas, account: alice),
        ServerAccountItem(server: noAccounts),
      ],
    );
    addTearDown(controller.dispose);
    Server? edit;
    await tester.pumpWidget(MaterialApp(
      theme: NewUiTheme.dark(),
      home: ServerAccountPage(
        controller: controller,
        onEditServer: (server) => edit = server,
      ),
    ));

    await tester.longPress(find.byKey(const Key('server-account-11')));
    await tester.pumpAndSettle();
    expect(find.text('编辑服务器'), findsOneWidget);
    expect(find.text('清除默认'), findsOneWidget);
    expect(find.text('删除账号'), findsOneWidget);
    await tester.tap(find.text('编辑服务器'));
    await tester.pumpAndSettle();
    expect(edit?.id, nas.id);

    await tester.longPress(find.byKey(const Key('server-no-account-2')));
    await tester.pumpAndSettle();
    expect(find.text('删除账号'), findsNothing);
    expect(find.text('设置默认'), findsNothing);
    expect(find.text('编辑服务器'), findsOneWidget);
    expect(find.text('删除服务器'), findsOneWidget);
  });
}
