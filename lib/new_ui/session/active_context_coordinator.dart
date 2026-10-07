import 'package:dsm_helper/apis/dsm_api/dsm_exception.dart';

enum ActiveContextStatus {
  authenticated,
  offline,
  reauthNeeded,
  failed,
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
    this.error,
  });

  final String contextId;
  final ActiveContextStatus status;
  final Object? error;
}

typedef ActiveContextClear = void Function();
typedef ActiveContextBind = void Function(ActiveContextRequest request);
typedef ActiveContextAsyncAction = Future<void> Function();

class ActiveContextCoordinator {
  const ActiveContextCoordinator({
    required this.clearCapabilities,
    required this.bindTransport,
    required this.discoverCapabilities,
    required this.probeSession,
  });

  final ActiveContextClear clearCapabilities;
  final ActiveContextBind bindTransport;
  final ActiveContextAsyncAction discoverCapabilities;
  final ActiveContextAsyncAction probeSession;

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
      if (error.code == 119) {
        return ActiveContextResult(
          contextId: request.contextId,
          status: ActiveContextStatus.reauthNeeded,
          error: error,
        );
      }
      return ActiveContextResult(
        contextId: request.contextId,
        status: ActiveContextStatus.failed,
        error: error,
      );
    } catch (error) {
      return ActiveContextResult(
        contextId: request.contextId,
        status: ActiveContextStatus.offline,
        error: error,
      );
    }
  }
}
