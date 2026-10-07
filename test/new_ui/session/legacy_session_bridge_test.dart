import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:dsm_helper/new_ui/session/legacy_session_bridge.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late String oldBaseUrl;
  late String oldSid;

  setUp(() {
    oldBaseUrl = Utils.baseUrl;
    oldSid = Utils.sid;
  });

  tearDown(() {
    Utils.baseUrl = oldBaseUrl;
    Utils.sid = oldSid;
  });

  test('active DSM context is mirrored into legacy File Station session globals', () {
    LegacySessionBridge.bind(
      const ActiveContextRequest(
        contextId: '7/42',
        baseUrl: 'https://nas.local:5001',
        deviceId: 'device-42',
        sid: 'sid-42',
      ),
    );

    expect(Utils.baseUrl, 'https://nas.local:5001');
    expect(Utils.sid, 'sid-42');
  });
}
