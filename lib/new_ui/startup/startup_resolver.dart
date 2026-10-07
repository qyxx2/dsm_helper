enum StartupTarget {
  addServer,
  selectAccount,
  shell,
}

class StartupAccountCandidate {
  const StartupAccountCandidate({
    required this.accountId,
    required this.serverId,
    required this.isDefault,
  });

  final int accountId;
  final int serverId;
  final bool isDefault;
}

class StartupResolution {
  const StartupResolution({
    required this.target,
    this.accountId,
    this.serverId,
  });

  final StartupTarget target;
  final int? accountId;
  final int? serverId;
}

class StartupResolver {
  const StartupResolver._();

  static StartupResolution resolve({
    required bool hasServers,
    required bool launcherSelectionEnabled,
    required List<StartupAccountCandidate> accounts,
    required Set<int> knownServerIds,
  }) {
    if (!hasServers) {
      return const StartupResolution(target: StartupTarget.addServer);
    }

    if (launcherSelectionEnabled) {
      return const StartupResolution(target: StartupTarget.selectAccount);
    }

    final defaults = accounts
        .where((account) =>
            account.isDefault && knownServerIds.contains(account.serverId))
        .toList(growable: false);

    if (defaults.length != 1) {
      return const StartupResolution(target: StartupTarget.selectAccount);
    }

    final selected = defaults.single;
    return StartupResolution(
      target: StartupTarget.shell,
      accountId: selected.accountId,
      serverId: selected.serverId,
    );
  }
}
