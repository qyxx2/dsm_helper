import 'package:dsm_helper/new_ui/startup/legacy_startup_adapter.dart';
import 'package:dsm_helper/new_ui/startup/modern_startup.dart';
import 'package:dsm_helper/utils/db_utils.dart';
import 'package:sp_util/sp_util.dart';

class DsmStartupDataSource implements StartupDataSource {
  const DsmStartupDataSource();

  @override
  Future<StartupSnapshot> load() async {
    final servers = await DbUtils.db.select(DbUtils.db.servers).get();
    final accounts = await DbUtils.db.select(DbUtils.db.accounts).get();

    return LegacyStartupAdapter.buildSnapshot(
      servers: servers,
      accounts: accounts,
      launcherSelectionEnabled:
          SpUtil.getBool('launch_account_page', defValue: false) ?? false,
    );
  }
}
