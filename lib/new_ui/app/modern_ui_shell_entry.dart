import 'package:dsm_helper/new_ui/app/dsm_new_ui_shell.dart';
import 'package:dsm_helper/new_ui/lifecycle/launch_auth_gate.dart';
import 'package:dsm_helper/new_ui/lifecycle/launch_auth_policy.dart';
import 'package:dsm_helper/pages/login/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:sp_util/sp_util.dart';

class ModernUiShellEntry extends StatelessWidget {
  const ModernUiShellEntry({super.key});

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
      shouldGate: _shouldGate,
      gateBuilder: (_) => AuthPage(launch: false),
      child: const DsmNewUiShell(),
    );
  }
}
