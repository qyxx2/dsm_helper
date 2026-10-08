import 'package:dsm_helper/database/table_extension.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/new_ui/startup/modern_startup.dart';

class LegacyStartupAdapter {
  const LegacyStartupAdapter._();

  static StartupSnapshot buildSnapshot({
    required List<Server> servers,
    required List<Account> accounts,
    required bool launcherSelectionEnabled,
  }) {
    final serversById = {for (final server in servers) server.id: server};

    final contexts = accounts
        .where((account) => serversById.containsKey(account.serverId))
        .map((account) {
          final server = serversById[account.serverId]!;
          return StartupSavedContext(
            accountId: account.id,
            serverId: account.serverId,
            isDefault: account.isDefault,
            baseUrl: server.url,
            deviceId: account.deviceId,
            sid: account.sid,
            checkSsl: server.checkSsl,
          );
        })
        .toList(growable: false);

    return StartupSnapshot(
      hasServers: servers.isNotEmpty,
      launcherSelectionEnabled: launcherSelectionEnabled,
      knownServerIds: servers.map((server) => server.id).toSet(),
      contexts: contexts,
    );
  }
}
