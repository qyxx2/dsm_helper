enum StartupDestination {
  addServer,
  selectAccount,
  restoreDefault,
}

class StartupAccountRef {
  const StartupAccountRef({
    required this.id,
    required this.serverId,
    required this.isDefault,
  });

  final int id;
  final int serverId;
  final bool isDefault;
}

class StartupDecision {
  const StartupDecision._(
    this.destination, {
    this.accountId,
    this.serverId,
  });

  const StartupDecision.addServer()
      : this._(StartupDestination.addServer);

  const StartupDecision.selectAccount()
      : this._(StartupDestination.selectAccount);

  const StartupDecision.restoreDefault({
    required int accountId,
    required int serverId,
  }) : this._(
          StartupDestination.restoreDefault,
          accountId: accountId,
          serverId: serverId,
        );

  final StartupDestination destination;
  final int? accountId;
  final int? serverId;
}

abstract final class StartupResolver {
  static StartupDecision resolve({
    required bool launcherSelectionEnabled,
    required Set<int> serverIds,
    required Iterable<StartupAccountRef> accounts,
  }) {
    if (serverIds.isEmpty) {
      return const StartupDecision.addServer();
    }

    if (launcherSelectionEnabled) {
      return const StartupDecision.selectAccount();
    }

    final defaults = accounts.where((account) => account.isDefault).toList();
    if (defaults.length != 1) {
      return const StartupDecision.selectAccount();
    }

    final account = defaults.single;
    if (!serverIds.contains(account.serverId)) {
      return const StartupDecision.selectAccount();
    }

    return StartupDecision.restoreDefault(
      accountId: account.id,
      serverId: account.serverId,
    );
  }
}
