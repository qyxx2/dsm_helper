import 'package:dsm_helper/new_ui/startup/startup_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const serverIds = {1, 2};

  test('launcher selection forces the legacy selector', () {
    final result = StartupResolver.resolve(
      hasServers: true,
      launcherSelectionEnabled: true,
      accounts: const [
        StartupAccountCandidate(accountId: 10, serverId: 1, isDefault: true),
      ],
      knownServerIds: serverIds,
    );

    expect(result.target, StartupTarget.selectAccount);
  });

  test('exactly one valid default restores the shell candidate', () {
    final result = StartupResolver.resolve(
      hasServers: true,
      launcherSelectionEnabled: false,
      accounts: const [
        StartupAccountCandidate(accountId: 10, serverId: 1, isDefault: true),
        StartupAccountCandidate(accountId: 11, serverId: 2, isDefault: false),
      ],
      knownServerIds: serverIds,
    );

    expect(result.target, StartupTarget.shell);
    expect(result.accountId, 10);
    expect(result.serverId, 1);
  });

  test('zero or multiple defaults never invent a last-used account', () {
    final zero = StartupResolver.resolve(
      hasServers: true,
      launcherSelectionEnabled: false,
      accounts: const [
        StartupAccountCandidate(accountId: 10, serverId: 1, isDefault: false),
      ],
      knownServerIds: serverIds,
    );
    final multiple = StartupResolver.resolve(
      hasServers: true,
      launcherSelectionEnabled: false,
      accounts: const [
        StartupAccountCandidate(accountId: 10, serverId: 1, isDefault: true),
        StartupAccountCandidate(accountId: 11, serverId: 2, isDefault: true),
      ],
      knownServerIds: serverIds,
    );

    expect(zero.target, StartupTarget.selectAccount);
    expect(multiple.target, StartupTarget.selectAccount);
  });

  test('a default account with a missing server relation is not guessed', () {
    final result = StartupResolver.resolve(
      hasServers: true,
      launcherSelectionEnabled: false,
      accounts: const [
        StartupAccountCandidate(accountId: 10, serverId: 99, isDefault: true),
      ],
      knownServerIds: serverIds,
    );

    expect(result.target, StartupTarget.selectAccount);
  });

  test('no saved server routes to add-server fallback', () {
    final result = StartupResolver.resolve(
      hasServers: false,
      launcherSelectionEnabled: false,
      accounts: const [],
      knownServerIds: const {},
    );

    expect(result.target, StartupTarget.addServer);
  });
}
