import 'package:drift/native.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/models/Syno/Api/auth.dart';
import 'package:dsm_helper/new_ui/auth/auth_flow_controller.dart';
import 'package:dsm_helper/new_ui/auth/login_page.dart';
import 'support/fake_server_account_store.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Server> makeServer(Database db) async {
  final id = await db.into(db.servers).insert(
    ServersCompanion.insert(
      groupId: 0, ssl: true, qcid: '', domain: 'nas.local',
      port: 5001, checkSsl: true, remark: '', macAddress: '',
      createTime: 1,
    ),
  );
  return (db.select(db.servers)..where((t) => t.id.equals(id))).getSingle();
}

Auth successfulLogin() => Auth(
  account: 'user', deviceId: 'device',
  sid: 'new-sid', ikMessage: '', synotoken: 'token',
);

void main() {
  late Database db;
  late Server server;

  setUp(() async {
    db = Database.forTesting(NativeDatabase.memory());
    server = await makeServer(db);
  });
  tearDown(() async => db.close());

  testWidgets('Stage 1 exposes compact fields, password toggle, default and primary action', (tester) async {
    String? submittedAccount;
    String? submittedPassword;
    final store = FakeServerAccountStore(db);
    final controller = AuthFlowController(
      server: server,
      store: store,
      login: ({required account, required password, optCode}) async {
        submittedAccount = account;
        submittedPassword = password;
        return successfulLogin();
      },
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(MaterialApp(
      theme: NewUiTheme.light(),
      home: LoginPage(controller: controller),
    ));
    expect(find.byKey(const Key('auth-account')), findsOneWidget);
    expect(find.byKey(const Key('auth-password')), findsOneWidget);
    expect(find.byKey(const Key('auth-default')), findsOneWidget);
    expect(find.byKey(const Key('auth-submit')), findsOneWidget);
    expect(find.byKey(const Key('auth-toggle-password')), findsOneWidget);
    expect(tester.widget<TextField>(find.byKey(const Key('auth-password'))).obscureText, isTrue);

    await tester.tap(find.byKey(const Key('auth-toggle-password')));
    await tester.pump();
    expect(tester.widget<TextField>(find.byKey(const Key('auth-password'))).obscureText, isFalse);
    await tester.enterText(find.byKey(const Key('auth-account')), 'user');
    await tester.enterText(find.byKey(const Key('auth-password')), 'new-password');
    await tester.tap(find.byKey(const Key('auth-default')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle(timeout: const Duration(seconds: 10));

    expect(submittedAccount, 'user');
    expect(submittedPassword, 'new-password');
    expect(store.savedAccounts, hasLength(1));
    expect(store.savedAccounts.single.isDefault, isTrue);
    expect(controller.state.authenticatedAccount?.id, store.savedAccounts.single.id);
    expect(controller.isSubmitting, isFalse);
    expect(tester.getSize(find.byKey(const Key('auth-submit'))).height,
        greaterThanOrEqualTo(48));
  });

  testWidgets('saved reauthentication keeps account identity and updates its row', (tester) async {
    final saved = Account(
      id: 1, serverId: server.id, account: 'user', password: 'old',
      remark: '', createTime: 1, lastLoginTime: 1,
      isDefault: false, deviceId: 'device',
      sid: 'old-sid', ikMessage: '', synoToken: 'token',
    );
    final store = FakeServerAccountStore(db, existingAccount: saved);
    final controller = AuthFlowController(
      server: server,
      existingAccount: saved,
      store: store,
      login: ({required account, required password, optCode}) async => successfulLogin(),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(MaterialApp(
      theme: NewUiTheme.dark(),
      home: LoginPage(controller: controller),
    ));
    final identity = tester.widget<TextField>(find.byKey(const Key('auth-account')));
    expect(identity.controller?.text, 'user');
    expect(identity.readOnly, isTrue);
    expect(tester.widget<TextField>(find.byKey(const Key('auth-password'))).controller?.text, 'old');

    await tester.enterText(find.byKey(const Key('auth-password')), 'replacement');
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle(timeout: const Duration(seconds: 10));

    expect(store.savedAccounts, hasLength(1));
    expect(store.savedAccounts.single.id, saved.id);
    expect(store.savedAccounts.single.sid, 'new-sid');
    expect(store.savedAccounts.single.password, 'replacement');
    expect(controller.isSubmitting, isFalse);
  });
}
