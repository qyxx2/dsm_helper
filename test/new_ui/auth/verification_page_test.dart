import 'package:drift/native.dart';
import 'package:dsm_helper/apis/dsm_api/dsm_exception.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/models/Syno/Api/auth.dart';
import 'package:dsm_helper/new_ui/auth/auth_flow_controller.dart';
import 'package:dsm_helper/new_ui/auth/auth_flow_models.dart';
import 'package:dsm_helper/new_ui/auth/login_page.dart';
import 'support/fake_server_account_store.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Database db;
  late Server server;

  setUp(() async {
    db = Database.forTesting(NativeDatabase.memory());
    final id = await db.into(db.servers).insert(ServersCompanion.insert(
      groupId: 0, ssl: true, qcid: '', domain: 'nas.local',
      port: 5001, checkSsl: true, remark: '', macAddress: '', createTime: 1,
    ));
    server = await (db.select(db.servers)..where((t) => t.id.equals(id))).getSingle();
  });
  tearDown(() async => db.close());

  testWidgets('OTP failure stays in Stage 2; retry forwards code and persists only success', (tester) async {
    final codes = <String?>[];
    final store = FakeServerAccountStore(db);
    final controller = AuthFlowController(
      server: server,
      store: store,
      login: ({required account, required password, optCode}) async {
        codes.add(optCode);
        if (codes.length == 1) throw const DsmException(403);
        if (codes.length == 2) throw const DsmException(404);
        return Auth(
          account: account, deviceId: 'device', sid: 'new-sid',
          ikMessage: '', synotoken: 'token',
        );
      },
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      theme: NewUiTheme.light(), home: LoginPage(controller: controller),
    ));
    await tester.enterText(find.byKey(const Key('auth-account')), 'user');
    await tester.enterText(find.byKey(const Key('auth-password')), 'password');
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle(timeout: const Duration(seconds: 10));

    expect(controller.state.stage, AuthFlowStage.verification);
    expect(find.byKey(const Key('auth-verification-code')), findsOneWidget);
    expect(store.savedAccounts, isEmpty);
    await tester.enterText(find.byKey(const Key('auth-verification-code')), '000000');
    await tester.tap(find.byKey(const Key('auth-verify-submit')));
    await tester.pumpAndSettle(timeout: const Duration(seconds: 10));
    expect(find.textContaining('错误的验证码'), findsOneWidget);
    expect(find.byKey(const Key('auth-verification-code')), findsOneWidget);
    expect(store.savedAccounts, isEmpty);

    await tester.enterText(find.byKey(const Key('auth-verification-code')), '123456');
    await tester.tap(find.byKey(const Key('auth-verify-submit')));
    await tester.pumpAndSettle(timeout: const Duration(seconds: 10));
    expect(codes, <String?>[null, '000000', '123456']);
    expect(controller.state.stage, AuthFlowStage.authenticated);
    expect(store.savedAccounts, hasLength(1));
    expect(controller.state.authenticatedAccount?.id, store.savedAccounts.single.id);
  });

  testWidgets('email verification retains context; back keeps Stage 1 values', (tester) async {
    final store = FakeServerAccountStore(db);
    final controller = AuthFlowController(
      server: server,
      store: store,
      login: ({required account, required password, optCode}) async {
        throw const DsmException(414, '', {
          'errors': {'email': 'user@example.com'}
        });
      },
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      theme: NewUiTheme.dark(), home: LoginPage(controller: controller),
    ));
    await tester.enterText(find.byKey(const Key('auth-account')), 'user');
    await tester.enterText(find.byKey(const Key('auth-password')), 'secret');
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle(timeout: const Duration(seconds: 10));

    expect(find.textContaining('user@example.com'), findsOneWidget);
    await tester.tap(find.byKey(const Key('auth-verification-back')));
    await tester.pumpAndSettle(timeout: const Duration(seconds: 10));
    expect(controller.state.stage, AuthFlowStage.credentials);
    expect(tester.widget<TextField>(find.byKey(const Key('auth-account'))).controller?.text, 'user');
    expect(tester.widget<TextField>(find.byKey(const Key('auth-password'))).controller?.text, 'secret');
    expect(store.savedAccounts, isEmpty);
  });
}
