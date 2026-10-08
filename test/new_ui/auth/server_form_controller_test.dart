import 'package:drift/native.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/models/api_model.dart';
import 'package:dsm_helper/new_ui/auth/server_form_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Database db;
  late Server server;
  setUp(() async {
    db = Database.forTesting(NativeDatabase.memory());
    final id = await db.into(db.servers).insert(
      ServersCompanion.insert(
        groupId: 1, ssl: true, qcid: '', domain: 'old.example.com',
        port: 5001, checkSsl: false, remark: 'before',
        macAddress: '', createTime: 10,
      ),
    );
    server = await (db.select(db.servers)..where((t) => t.id.equals(id))).getSingle();
    await db.into(db.accounts).insert(
      AccountsCompanion.insert(
        serverId: id, account: 'saved', password: 'secret',
        remark: '', createTime: 10, lastLoginTime: 10,
        isDefault: true, deviceId: 'device', sid: 'sid',
        ikMessage: 'ik', synoToken: 'token',
      ),
    );
  });
  tearDown(() async => db.close());

  test('HTTP and HTTPS domain use respective default ports', () {
    final http = ServerFormController.parseEndpoint(
      https: false, host: 'nas.example.com', port: '',
    );
    final https = ServerFormController.parseEndpoint(
      https: true, host: 'nas.example.com', port: '',
    );
    expect(http.baseUrl, 'http://nas.example.com:5000');
    expect(https.baseUrl, 'https://nas.example.com:5001');
    expect(http.port, 5000);
    expect(https.port, 5001);
  });

  test('explicit port overrides scheme default and IPv4 is accepted', () {
    final endpoint = ServerFormController.parseEndpoint(
      https: true, host: '192.168.0.100', port: '5443',
    );
    expect(endpoint.host, '192.168.0.100');
    expect(endpoint.port, 5443);
    expect(endpoint.baseUrl, 'https://192.168.0.100:5443');
  });

  test('bracketed IPv6 is parsed without losing address brackets', () {
    final endpoint = ServerFormController.parseEndpoint(
      https: false, host: '[2001:db8::10]', port: '8000',
    );
    expect(endpoint.host, '[2001:db8::10]');
    expect(endpoint.baseUrl, 'http://[2001:db8::10]:8000');
  });

  test('single-label LAN hostname stays ordinary host, not QuickConnect', () {
    final endpoint = ServerFormController.parseEndpoint(
      https: false, host: 'diskstation', port: '',
    );
    expect(endpoint.host, 'diskstation');
    expect(endpoint.baseUrl, 'http://diskstation:5000');
  });

  test('invalid hosts and ports fail locally', () {
    for (final host in ['', ' ', 'https://nas.example.com', 'nas.example.com/path',
      'bad host', '[invalid::ip]', '999.999.999.999', 'a..b', 'user@host']) {
      expect(() => ServerFormController.parseEndpoint(
        https: false, host: host, port: '',
      ), throwsFormatException, reason: host);
    }
    for (final port in ['-1', '0', '65536', 'not-a-port', '5000.1']) {
      expect(() => ServerFormController.parseEndpoint(
        https: false, host: 'nas.local', port: port,
      ), throwsFormatException, reason: port);
    }
  });

  test('probe precedes persistence and receives exact TLS endpoint policy', () async {
    final calls = <String>[];
    final controller = ServerFormController(
      db: db,
      nowEpochSeconds: () => 20,
      probe: ({required baseUrl, required checkSsl}) async {
        calls.add(baseUrl);
        expect(checkSsl, isFalse);
        expect(await db.select(db.servers).get(), hasLength(1));
        return {'SYNO.API.Info': ApiModel(maxVersion: 1)};
      },
    );
    addTearDown(controller.dispose);
    final saved = await controller.submit(
      https: true, host: 'nas.local', port: '8443',
      checkSsl: false, remark: 'new',
    );
    expect(calls, ['https://nas.local:8443']);
    expect(saved, isNotNull);
    expect(saved!.domain, 'nas.local');
    expect(saved.port, 8443);
    expect(saved.ssl, isTrue);
    expect(saved.checkSsl, isFalse);
    expect(saved.remark, 'new');
    expect(await db.select(db.accounts).get(), hasLength(1));
    expect(await db.select(db.servers).get(), hasLength(2));
  });

  test('new Server can persist without inventing an Account', () async {
    final controller = ServerFormController(
      db: db,
      probe: ({required baseUrl, required checkSsl}) async => {
        'SYNO.API.Info': ApiModel(maxVersion: 1),
      },
    );
    addTearDown(controller.dispose);
    final saved = await controller.submit(
      https: false, host: 'new.example.com', port: '',
      checkSsl: true, remark: '',
    );
    expect(saved, isNotNull);
    expect(saved!.port, 5000);
    expect((await db.select(db.accounts).get()).where((a) => a.serverId == saved.id), isEmpty);
  });

  test('failed probe and empty discovery do not save a new Server', () async {
    var fail = true;
    final controller = ServerFormController(
      db: db,
      probe: ({required baseUrl, required checkSsl}) async {
        if (fail) throw StateError('offline');
        return <String, ApiModel>{};
      },
    );
    addTearDown(controller.dispose);
    expect(await controller.submit(
      https: true, host: 'fail.example.com', port: '',
      checkSsl: true, remark: '',
    ), isNull);
    fail = false;
    expect(await controller.submit(
      https: true, host: 'fail.example.com', port: '',
      checkSsl: true, remark: '',
    ), isNull);
    expect(await db.select(db.servers).get(), hasLength(1));
    expect(controller.errorMessage, isNotNull);
  });

  test('invalid input is rejected before any network request or write', () async {
    var probes = 0;
    final controller = ServerFormController(
      db: db,
      probe: ({required baseUrl, required checkSsl}) async {
        probes++;
        return {};
      },
    );
    addTearDown(controller.dispose);
    expect(await controller.submit(
      https: false, host: 'invalid/host', port: '',
      checkSsl: true, remark: '',
    ), isNull);
    expect(probes, 0);
    expect(await db.select(db.servers).get(), hasLength(1));
  });

  test('edit validates first then updates same Server and preserves linked Accounts', () async {
    final controller = ServerFormController(
      db: db, existingServer: server,
      probe: ({required baseUrl, required checkSsl}) async => {
        'SYNO.API.Info': ApiModel(maxVersion: 1),
      },
    );
    addTearDown(controller.dispose);
    final saved = await controller.submit(
      https: false, host: 'changed.example.com', port: '5100',
      checkSsl: true, remark: 'after',
    );
    expect(saved!.id, server.id);
    expect(saved.domain, 'changed.example.com');
    expect(saved.port, 5100);
    expect(saved.ssl, isFalse);
    expect(saved.checkSsl, isTrue);
    expect(saved.remark, 'after');
    final accounts = await db.select(db.accounts).get();
    expect(accounts, hasLength(1));
    expect(accounts.single.serverId, server.id);
    expect(accounts.single.password, 'secret');
    expect(accounts.single.sid, 'sid');
    expect(accounts.single.isDefault, isTrue);
    expect(await db.select(db.servers).get(), hasLength(1));
  });

  test('failed edit probe leaves Server and Accounts unchanged', () async {
    final controller = ServerFormController(
      db: db, existingServer: server,
      probe: ({required baseUrl, required checkSsl}) async => throw StateError('offline'),
    );
    addTearDown(controller.dispose);
    expect(await controller.submit(
      https: false, host: 'new.example.com', port: '',
      checkSsl: true, remark: 'new',
    ), isNull);
    expect((await db.select(db.servers).get()).single, server);
    expect((await db.select(db.accounts).get()).single.sid, 'sid');
  });
}
