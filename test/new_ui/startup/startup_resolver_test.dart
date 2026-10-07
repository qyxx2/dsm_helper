import 'package:dsm_helper/new_ui/startup/startup_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const serverIds = {10, 20};

  test('no configured server requires server setup', () {
    final decision = StartupResolver.resolve(
      launcherSelectionEnabled: false,
      serverIds: const {},
      accounts: const [],
    );

    expect(decision.destination, StartupDestination.addServer);
  });

  test('launcher selection mode wins over an otherwise restorable default', () {
    final decision = StartupResolver.resolve(
      launcherSelectionEnabled: true,
      serverIds: serverIds,
      accounts: const [
        StartupAccountRef(id: 1, serverId: 10, isDefault: true),
      ],
    );

    expect(decision.destination, StartupDestination.selectAccount);
    expect(decision.accountId, isNull);
  });

  test('zero default accounts opens selector', () {
    final decision = StartupResolver.resolve(
      launcherSelectionEnabled: false,
      serverIds: serverIds,
      accounts: const [
        StartupAccountRef(id: 1, serverId: 10, isDefault: false),
      ],
    );

    expect(decision.destination, StartupDestination.selectAccount);
  });

  test('exactly one valid default restores that account', () {
    final decision = StartupResolver.resolve(
      launcherSelectionEnabled: false,
      serverIds: serverIds,
      accounts: const [
        StartupAccountRef(id: 1, serverId: 10, isDefault: false),
        StartupAccountRef(id: 2, serverId: 20, isDefault: true),
      ],
    );

    expect(decision.destination, StartupDestination.restoreDefault);
    expect(decision.accountId, 2);
    expect(decision.serverId, 20);
  });

  test('multiple defaults are ambiguous and open selector', () {
    final decision = StartupResolver.resolve(
      launcherSelectionEnabled: false,
      serverIds: serverIds,
      accounts: const [
        StartupAccountRef(id: 1, serverId: 10, isDefault: true),
        StartupAccountRef(id: 2, serverId: 20, isDefault: true),
      ],
    );

    expect(decision.destination, StartupDestination.selectAccount);
  });

  test('a default with a broken server relation is not restored', () {
    final decision = StartupResolver.resolve(
      launcherSelectionEnabled: false,
      serverIds: serverIds,
      accounts: const [
        StartupAccountRef(id: 1, serverId: 99, isDefault: true),
      ],
    );

    expect(decision.destination, StartupDestination.selectAccount);
  });
}
