import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:dsm_helper/utils/utils.dart';

class LegacySessionBridge {
  const LegacySessionBridge._();

  static void bind(ActiveContextRequest request) {
    Utils.baseUrl = request.baseUrl;
    Utils.sid = request.sid;
  }
}
