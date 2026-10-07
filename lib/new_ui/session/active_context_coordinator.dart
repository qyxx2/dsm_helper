import 'package:dsm_helper/apis/api.dart';
import 'package:dsm_helper/apis/dsm_api/dsm_api.dart';
import 'package:dsm_helper/models/Syno/Core/NormalUser.dart';
import 'package:dsm_helper/models/api_model.dart';

enum ActiveContextStatus {
  authenticated,
  offline,
  reauthNeeded,
  error,
}

class ActiveContextRequest {
  const ActiveContextRequest({
    required this.contextId,
    required this.baseUrl,
    required this.deviceId,
    required this.sid,
  });

  final String contextId;
  final String baseUrl;
  final String deviceId;
  final String sid;
}

class ActiveContextResult {
  const ActiveContextResult({
    required this.contextId,
    required this.status,
  });

  final String contextId;
  final ActiveContextStatus status;
}

class ActiveContextCoordinator {
  ActiveContextCoordinator({
    required this.clearCapabilities,
    required this.bindTransport,
    required this.discoverCapabilities,
    required this.probeSession,
  });

  factory ActiveContextCoordinator.legacy() {
    return ActiveContextCoordinator(
      clearCapabilities: () {
        ApiModel.apiInfo = <String, ApiModel>{};
      },
      bindTransport: (request) {
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
  }

  final void Function() clearCapabilities;
  final void Function(ActiveContextRequest request) bindTransport;
  final Future<void> Function() discoverCapabilities;
  final Future<void> Function() probeSession;

  Future<ActiveContextResult> activate(ActiveContextRequest request) async {
    clearCapabilities();
    bindTransport(request);

    try {
      await discoverCapabilities();
      await probeSession();
      return ActiveContextResult(
        contextId: request.contextId,
        status: ActiveContextStatus.authenticated,
      );
    } on DsmException catch (error) {
      return ActiveContextResult(
        contextId: request.contextId,
        status: error.code == 119
            ? ActiveContextStatus.reauthNeeded
            : ActiveContextStatus.error,
      );
    } catch (_) {
      return ActiveContextResult(
        contextId: request.contextId,
        status: ActiveContextStatus.offline,
      );
    }
  }
}
