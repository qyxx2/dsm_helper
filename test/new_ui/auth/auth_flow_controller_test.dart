import 'package:drift/native.dart';
import 'package:dsm_helper/apis/dsm_api/dsm_exception.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/models/Syno/Api/auth.dart';
import 'package:dsm_helper/new_ui/auth/auth_flow_controller.dart';
import 'package:dsm_helper/new_ui/auth/auth_flow_models.dart';
import 'package:dsm_helper/new_ui/auth/server_account_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Database db;
  late ServerAccountStore store;
  late Server server;

  setUp(() async {
    db = Database.forTesting(NativeDatabase.memory());
    store = ServerAccountStore(db);
    final serverId = await db.into(db.servers).insert(
          ServersCompanion.insert(
            groupId: 0,
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
    server = (await (db.select(db.servers)
          ..where((table) => table.id.equals(serverId)))
        .getSingle());
  });

  tearDown(() async {
    await db.close();
  });

  Auth successAuth({
    String account = 'user',
    String sid = 'sid-new',
  }) {
    return Auth(
      account: account,
      deviceId: 'device-new',
      ikMessage: 'ik',
      sid: sid,
      synotoken: 'token-new',
    );
  }

  Future<Account> insertAccount({
    String account = 'user',
    String password = 'saved-password',
    bool isDefault = false,
    String sid = 'sid-old',
  }) async {
    final id = await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            serverId: server.id,
            account: account,
            password: password,
            remark: '',
            createTime: 10,
            lastLoginTime: 10,
            isDefault: isDefault,
            deviceId: 'device-old',
            sid: sid,
            ikMessage: 'ik-old',
            synoToken: 'token-old',
          ),
        );
    return (db.select(db.accounts)..where((table) => table.id.equals(id)))
        .getSingle();
  }

  test('400 stays on credentials and does not persist an account', () async {
    final controller = AuthFlowController(
      server: server,
      store: store,
      login: ({required account, required password, optCode}) async {
        throw const DsmException(400);
      },
      nowEpochSeconds: () => 100,
    );

    await controller.submitCredentials(
      account: 'user',
      password: 'wrong',
      isDefault: false,
    );

    expect(controller.state.stage, AuthFlowStage.credentials);
    expect(controller.state.message, '用户名/密码有误');
    expect(await db.select(db.accounts).get(), isEmpty);
  });

  test('403 enters OTP verification without persisting an account', () async {
    final controller = AuthFlowController(
      server: server,
      store: store,
      login: ({required account, required password, optCode}) async {
        throw const DsmException(403);
      },
      nowEpochSeconds: () => 100,
    );

    await controller.submitCredentials(
      account: 'user',
      password: 'password',
      isDefault: false,
    );

    expect(controller.state.stage, AuthFlowStage.verification);
    expect(controller.state.verificationKind, AuthVerificationKind.otp);
    expect(await db.select(db.accounts).get(), isEmpty);
  });

  test('404 remains on verification and reports rejected code', () async {
    var calls = 0;
    final controller = AuthFlowController(
      server: server,
      store: store,
      login: ({required account, required password, optCode}) async {
        calls++;
        throw DsmException(calls == 1 ? 403 : 404);
      },
      nowEpochSeconds: () => 100,
    );

    await controller.submitCredentials(
      account: 'user',
      password: 'password',
      isDefault: false,
    );
    await controller.submitVerification('000000');

    expect(controller.state.stage, AuthFlowStage.verification);
    expect(controller.state.verificationKind, AuthVerificationKind.otp);
    expect(controller.state.message, '错误的验证码。请再试一次');
    expect(await db.select(db.accounts).get(), isEmpty);
  });

  test('414 enters email verification and keeps returned email context', () async {
    final controller = AuthFlowController(
      server: server,
      store: store,
      login: ({required account, required password, optCode}) async {
        throw const DsmException(
          414,
          '',
          {
            'errors': {'email': 'user@example.com'},
          },
        );
      },
      nowEpochSeconds: () => 100,
    );

    await controller.submitCredentials(
      account: 'user',
      password: 'password',
      isDefault: false,
    );

    expect(controller.state.stage, AuthFlowStage.verification);
    expect(controller.state.verificationKind, AuthVerificationKind.email);
    expect(controller.state.verificationEmail, 'user@example.com');
  });

  test('verification retry forwards optCode and persists only final success', () async {
    final optCodes = <String?>[];
    var calls = 0;
    final controller = AuthFlowController(
      server: server,
      store: store,
      login: ({required account, required password, optCode}) async {
        optCodes.add(optCode);
        calls++;
        if (calls == 1) {
          throw const DsmException(403);
        }
        return successAuth(account: account);
      },
      nowEpochSeconds: () => 100,
    );

    await controller.submitCredentials(
      account: 'user',
      password: 'password',
      isDefault: true,
    );
    expect(await db.select(db.accounts).get(), isEmpty);

    await controller.submitVerification('123456');

    expect(optCodes, [null, '123456']);
    expect(controller.state.stage, AuthFlowStage.authenticated);
    expect(controller.state.authenticatedAccount, isNotNull);
    expect(await db.select(db.accounts).get(), hasLength(1));
  });

  test('successful new login creates exactly one account', () async {
    final controller = AuthFlowController(
      server: server,
      store: store,
      login: ({required account, required password, optCode}) async {
        return successAuth(account: account);
      },
      nowEpochSeconds: () => 100,
    );

    await controller.submitCredentials(
      account: 'new-user',
      password: 'new-password',
      isDefault: true,
    );

    final accounts = await db.select(db.accounts).get();
    expect(accounts, hasLength(1));
    expect(accounts.single.account, 'new-user');
    expect(accounts.single.password, 'new-password');
    expect(accounts.single.sid, 'sid-new');
    expect(accounts.single.isDefault, isTrue);
    expect(controller.state.authenticatedAccount?.id, accounts.single.id);
  });

  test('successful login for same server and username updates instead of duplicating', () async {
    final existing = await insertAccount();
    final controller = AuthFlowController(
      server: server,
      store: store,
      login: ({required account, required password, optCode}) async {
        return successAuth(account: account, sid: 'sid-replaced');
      },
      nowEpochSeconds: () => 200,
    );

    await controller.submitCredentials(
      account: existing.account,
      password: 'new-password',
      isDefault: existing.isDefault,
    );

    final accounts = await db.select(db.accounts).get();
    expect(accounts, hasLength(1));
    expect(accounts.single.id, existing.id);
    expect(accounts.single.password, 'new-password');
    expect(accounts.single.sid, 'sid-replaced');
    expect(accounts.single.lastLoginTime, 200);
  });

  test('saved-account reauth first reuses persisted username and password', () async {
    final existing = await insertAccount(
      account: 'saved-user',
      password: 'saved-password',
      isDefault: true,
    );
    String? capturedAccount;
    String? capturedPassword;

    final controller = AuthFlowController(
      server: server,
      existingAccount: existing,
      store: store,
      login: ({required account, required password, optCode}) async {
        capturedAccount = account;
        capturedPassword = password;
        return successAuth(account: account);
      },
      nowEpochSeconds: () => 300,
    );

    await controller.reauthenticateSavedAccount();

    expect(capturedAccount, 'saved-user');
    expect(capturedPassword, 'saved-password');
    expect(controller.state.stage, AuthFlowStage.authenticated);
    expect((await db.select(db.accounts).get()), hasLength(1));
  });

  test('saved credential rejection exposes credentials stage for same account identity', () async {
    final existing = await insertAccount(account: 'saved-user');

    final controller = AuthFlowController(
      server: server,
      existingAccount: existing,
      store: store,
      login: ({required account, required password, optCode}) async {
        throw const DsmException(400);
      },
      nowEpochSeconds: () => 300,
    );

    await controller.reauthenticateSavedAccount();

    expect(controller.state.stage, AuthFlowStage.credentials);
    expect(controller.state.account, 'saved-user');
    expect(controller.state.password, existing.password);
    expect((await db.select(db.accounts).get()), hasLength(1));
  });
}
