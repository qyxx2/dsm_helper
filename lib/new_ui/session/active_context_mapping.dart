import 'package:dsm_helper/database/table_extension.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';

abstract final class ActiveContextMapping {
  static ActiveContextTarget savedAccount(
    Server server,
    Account account, {
    String? sid,
  }) {
    return ActiveContextTarget(
      baseUrl: server.url,
      deviceId: account.deviceId,
      sid: sid ?? account.sid,
      label: serverLabel(server),
    );
  }

  static String serverLabel(Server server) {
    final hostname = server.hostname?.trim();
    if (hostname != null && hostname.isNotEmpty) {
      return hostname;
    }

    final remark = server.remark.trim();
    if (remark.isNotEmpty) {
      return remark;
    }

    return server.domain;
  }
}
