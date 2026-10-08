import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/new_ui/startup/legacy_startup_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

Server _server({
  required int id,
  bool ssl = true,
  String domain = 'nas.local',
  int port = 5001,
  bool checkSsl = true,
}) {
  return Server(
    id: id,
    groupId: 1,
    ssl: ssl,
    qcid: '',
    domain: domain,
    port: port,
    checkSsl: checkSsl,
    remark: '',
    macAddress: '',
    createTime: 1,
  );
}

Account _account({
  required int id,
  required int serverId,
  required bool isDefault,
}) {
  return Account(
    id: id,
    serverId: serverId,
    account: 'user-$id',
    password: 'pw',
    remark: '',
    createTime: 1,
    lastLoginTime: 1,
    isDefault: isDefault,
    deviceId: 'device-$id',
    sid: 'sid-$id',
    ikMessage: '',
    synoToken: '',
  );
}

void main() {
  test('maps persisted rows without guessing orphan account relations', () {
    final snapshot = LegacyStartupAdapter.buildSnapshot(
      servers: [
        _server(id: 7),
        _server(
          id: 9,
          ssl: false,
          domain: '10.0.0.9',
          port: 5000,
          checkSsl: false,
        ),
      ],
      accounts: [
        _account(id: 42, serverId: 7, isDefault: true),
        _account(id: 43, serverId: 9, isDefault: false),
        _account(id: 99, serverId: 404, isDefault: true),
      ],
      launcherSelectionEnabled: false,
    );

    expect(snapshot.hasServers, isTrue);
    expect(snapshot.knownServerIds, {7, 9});
    expect(snapshot.contexts, hasLength(2));

    final first = snapshot.contexts.firstWhere((item) => item.accountId == 42);
    expect(first.serverId, 7);
    expect(first.isDefault, isTrue);
    expect(first.baseUrl, 'https://nas.local:5001');
    expect(first.deviceId, 'device-42');
    expect(first.sid, 'sid-42');

    final second = snapshot.contexts.firstWhere((item) => item.accountId == 43);
    expect(second.baseUrl, 'http://10.0.0.9:5000');
    expect(second.checkSsl, isFalse);
    expect(second.request.checkSsl, isFalse);
    expect(snapshot.contexts.any((item) => item.accountId == 99), isFalse);
  });

  test('preserves launcher-selection preference', () {
    final snapshot = LegacyStartupAdapter.buildSnapshot(
      servers: [_server(id: 7)],
      accounts: [_account(id: 42, serverId: 7, isDefault: true)],
      launcherSelectionEnabled: true,
    );

    expect(snapshot.launcherSelectionEnabled, isTrue);
  });
}
