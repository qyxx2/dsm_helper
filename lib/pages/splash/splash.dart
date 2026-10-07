import 'package:background_downloader/background_downloader.dart';
import 'package:background_downloader_sql/background_downloader_sql.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:dsm_helper/new_ui/session/active_context_mapping.dart';
import 'package:dsm_helper/new_ui/shell/new_ui_shell.dart';
import 'package:dsm_helper/new_ui/startup/startup_resolver.dart';
import 'package:dsm_helper/pages/server/select_server.dart';
import 'package:dsm_helper/utils/db_utils.dart';
import 'package:dsm_helper/utils/extensions/navigator_ext.dart';
import 'package:dsm_helper/widgets/loading_widget.dart';
import 'package:flutter/material.dart';

import '../server/add_server.dart';

class Splash extends StatefulWidget {
  const Splash({
    required this.launcherSelectionEnabled,
    super.key,
  });

  final bool launcherSelectionEnabled;

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    queryServers();
    initDownloader();
    super.initState();
  }

  void initDownloader() {
    FileDownloader(persistentStorage: SqlitePersistentStorage());
  }

  Future<void> queryServers() async {
    final servers = await DbUtils.db.select(DbUtils.db.servers).get();
    final accounts = await DbUtils.db.select(DbUtils.db.accounts).get();
    if (!mounted) {
      return;
    }

    final decision = StartupResolver.resolve(
      launcherSelectionEnabled: widget.launcherSelectionEnabled,
      serverIds: servers.map((server) => server.id).toSet(),
      accounts: accounts.map(
        (account) => StartupAccountRef(
          id: account.id,
          serverId: account.serverId,
          isDefault: account.isDefault,
        ),
      ),
    );

    switch (decision.destination) {
      case StartupDestination.addServer:
        await context.push(AddServer(), replace: true);
      case StartupDestination.selectAccount:
        await context.push(const SelectServer(), replace: true);
      case StartupDestination.restoreDefault:
        final account = accounts.singleWhere(
          (value) => value.id == decision.accountId,
        );
        final server = servers.singleWhere(
          (value) => value.id == decision.serverId,
        );
        final target = ActiveContextMapping.savedAccount(server, account);
        final result = await ActiveContextCoordinator().restore(target);
        if (!mounted) {
          return;
        }

        if (result.status == ActiveContextStatus.reauthenticationRequired) {
          await context.push(const SelectServer(), replace: true);
          return;
        }

        await context.push(
          NewUiShell(contextLabel: target.label),
          replace: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: LoadingWidget(size: 30),
      ),
    );
  }
}
