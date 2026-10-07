import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:dsm_helper/utils/utils.dart';

class LegacySessionBridge {
  const LegacySessionBridge._();

  static void bind(ActiveContextRequest request) {
    bindValues(
      baseUrl: request.baseUrl,
      sid: request.sid,
    );
  }

  static void bindValues({
    required String baseUrl,
    required String? sid,
  }) {
    Utils.baseUrl = baseUrl;
    Utils.sid = sid ?? '';
  }
}
