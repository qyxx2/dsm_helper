import 'package:dsm_helper/apis/api.dart';
import 'package:dsm_helper/apis/dsm_api/dsm_api.dart';
import 'package:dsm_helper/models/Syno/Core/NormalUser.dart';
import 'package:dsm_helper/models/api_model.dart';

enum ActiveContextStatus {
  online,
  offline,
  reauthenticationRequired,
}

class ActiveContextTarget {
  const ActiveContextTarget({
    required this.baseUrl,
    required this.deviceId,
    required this.sid,
    required this.label,
  });

  final String baseUrl;
  final String deviceId;
  final String sid;
  final String label;
}

class ActiveContextResult {
  const ActiveContextResult({
    required this.status,
    required this.target,
  });

  final ActiveContextStatus status;
  final ActiveContextTarget target;
}

typedef BindAuthority = void Function(ActiveContextTarget target);
typedef ClearApiMetadata = void Function();
typedef DiscoverApiMetadata = Future<Map<String, ApiModel>> Function();
typedef PublishApiMetadata = void Function(Map<String, ApiModel> metadata);
typedef ProbeSession = Future<void> Function();

class ActiveContextCoordinator {
  ActiveContextCoordinator({
    BindAuthority? bindAuthority,
    ClearApiMetadata? clearApiMetadata,
    DiscoverApiMetadata? discoverApiMetadata,
    PublishApiMetadata? publishApiMetadata,
    ProbeSession? probeSession,
  })  : _bindAuthority = bindAuthority ?? _bindDefaultAuthority,
        _clearApiMetadata = clearApiMetadata ?? _clearDefaultApiMetadata,
        _discoverApiMetadata = discoverApiMetadata ?? ApiModel.info,
        _publishApiMetadata =
            publishApiMetadata ?? _publishDefaultApiMetadata,
        _probeSession = probeSession ?? _probeDefaultSession;

  final BindAuthority _bindAuthority;
  final ClearApiMetadata _clearApiMetadata;
  final DiscoverApiMetadata _discoverApiMetadata;
  final PublishApiMetadata _publishApiMetadata;
  final ProbeSession _probeSession;

  Future<ActiveContextResult> restore(ActiveContextTarget target) async {
    _bindAuthority(target);
    _clearApiMetadata();

    try {
      final metadata = await _discoverApiMetadata();
      _publishApiMetadata(metadata);
      await _probeSession();
      return ActiveContextResult(
        status: ActiveContextStatus.online,
        target: target,
      );
    } on DsmException catch (error) {
      return ActiveContextResult(
        status: error.code == 119
            ? ActiveContextStatus.reauthenticationRequired
            : ActiveContextStatus.offline,
        target: target,
      );
    } catch (_) {
      return ActiveContextResult(
        status: ActiveContextStatus.offline,
        target: target,
      );
    }
  }

  static void _bindDefaultAuthority(ActiveContextTarget target) {
    Api.dsm = DsmApi(
      baseUrl: target.baseUrl,
      deviceId: target.deviceId,
      sid: target.sid,
    );
  }

  static void _clearDefaultApiMetadata() {
    ApiModel.apiInfo = {};
  }

  static void _publishDefaultApiMetadata(Map<String, ApiModel> metadata) {
    ApiModel.apiInfo = metadata;
  }

  static Future<void> _probeDefaultSession() async {
    await NormalUser.get();
  }
}
