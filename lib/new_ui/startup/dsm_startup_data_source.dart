import 'package:dsm_helper/database/table_extension.dart';
import 'package:dsm_helper/new_ui/startup/modern_startup.dart';
import 'package:dsm_helper/utils/db_utils.dart';
import 'package:sp_util/sp_util.dart';

class DsmStartupDataSource implements StartupDataSource {
  const DsmStartupDataSource();

  @override
  Future<StartupSnapshot> load() async {
    final servers = await DbUtils.db.select(DbUtils.db.servers).get();
    final accounts = await DbUtils.db.select(DbUtils.db.accounts).get();
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
          );
        })
        .toList(growable: false);

    return StartupSnapshot(
      hasServers: servers.isNotEmpty,
      launcherSelectionEnabled:
          SpUtil.getBool('launch_account_page', defValue: false) ?? false,
      knownServerIds: servers.map((server) => server.id).toSet(),
      contexts: contexts,
    );
  }
}
