import 'package:background_downloader/background_downloader.dart';
import 'package:background_downloader_sql/background_downloader_sql.dart';
import 'package:dsm_helper/new_ui/app/dsm_new_ui_shell.dart';
import 'package:dsm_helper/new_ui/lifecycle/launch_auth_gate.dart';
import 'package:dsm_helper/new_ui/lifecycle/launch_auth_policy.dart';
import 'package:dsm_helper/new_ui/session/dsm_active_context_adapter.dart';
import 'package:dsm_helper/new_ui/startup/dsm_startup_data_source.dart';
import 'package:dsm_helper/new_ui/startup/modern_startup.dart';
import 'package:dsm_helper/pages/login/auth_page.dart';
import 'package:dsm_helper/pages/server/add_server.dart';
import 'package:dsm_helper/pages/server/select_server.dart';
import 'package:flutter/material.dart';
import 'package:sp_util/sp_util.dart';

class ModernUiRoot extends StatefulWidget {
  const ModernUiRoot({
    super.key,
    required this.initialAuthRequired,
  });

  final bool initialAuthRequired;

  @override
  State<ModernUiRoot> createState() => _ModernUiRootState();
}

class _ModernUiRootState extends State<ModernUiRoot> {
  final DsmActiveContextAdapter _contextAdapter = DsmActiveContextAdapter();

  @override
  void initState() {
    super.initState();
    FileDownloader(persistentStorage: SqlitePersistentStorage());
  }

  Future<bool> _shouldGate() async {
    return LaunchAuthPolicy.shouldGate(
      launchAuth: SpUtil.getBool('launch_auth', defValue: false) ?? false,
      passwordEnabled:
          SpUtil.getBool('launch_auth_password', defValue: false) ?? false,
      biometricsEnabled:
          SpUtil.getBool('launch_auth_biometrics', defValue: false) ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LaunchAuthGate(
      gateInitially: widget.initialAuthRequired,
      shouldGate: _shouldGate,
      gateBuilder: (_) => AuthPage(launch: false),
      child: ModernStartup(
        dataSource: const DsmStartupDataSource(),
        activateContext: _contextAdapter.activate,
        addServerBuilder: (_) => AddServer(),
        selectAccountBuilder: (_) => const SelectServer(),
        shellBuilder: (_, result) => DsmNewUiShell(
          initialContextStatus: result.status,
          contextId: result.contextId,
        ),
      ),
    );
  }
}
