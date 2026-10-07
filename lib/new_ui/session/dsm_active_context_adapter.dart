import 'package:dsm_helper/apis/api.dart';
import 'package:dsm_helper/apis/dsm_api/dsm_api.dart';
import 'package:dsm_helper/models/Syno/Core/NormalUser.dart';
import 'package:dsm_helper/models/api_model.dart';
import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:dsm_helper/new_ui/session/legacy_session_bridge.dart';

class DsmActiveContextAdapter {
  DsmActiveContextAdapter()
      : _coordinator = ActiveContextCoordinator(
          clearCapabilities: () {
            ApiModel.apiInfo = <String, ApiModel>{};
          },
          bindTransport: (request) {
            LegacySessionBridge.bind(request);
            Api.dsm = DsmApi(
              baseUrl: request.baseUrl,
              deviceId: request.deviceId,
              sid: request.sid,
            );
          },
          discoverCapabilities: () async {
            ApiModel.apiInfo = await ApiModel.info();
          },
          probeSession: () async {
            await NormalUser.get();
          },
        );

  final ActiveContextCoordinator _coordinator;

  Future<ActiveContextResult> activate(ActiveContextRequest request) {
    return _coordinator.activate(request);
  }
}
