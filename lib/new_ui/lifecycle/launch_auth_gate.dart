import 'package:dsm_helper/new_ui/legacy/legacy_page_host.dart';
import 'package:dsm_helper/pages/login/auth_page.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:sp_util/sp_util.dart';

abstract final class LaunchAuthGate {
  static bool isEnabled() {
    final launchAuth = SpUtil.getBool('launch_auth', defValue: false) ?? false;
    final password =
        SpUtil.getBool('launch_auth_password', defValue: false) ?? false;
    final biometrics =
        SpUtil.getBool('launch_auth_biometrics', defValue: false) ?? false;
    return !Utils.isAuthPage && launchAuth && (password || biometrics);
  }

  static Widget build(BuildContext context) {
    return const LegacyPageHost(
      child: _AuthPageAdapter(),
    );
  }
}

class _AuthPageAdapter extends StatelessWidget {
  const _AuthPageAdapter();

  @override
  Widget build(BuildContext context) {
    return AuthPage(launch: false);
  }
}
