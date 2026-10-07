import 'package:dsm_helper/apis/dsm_api/dsm_exception.dart';
import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('context activation clears old capabilities before discovery and probe', () async {
    final events = <String>[];
    final coordinator = ActiveContextCoordinator(
      clearCapabilities: () => events.add('clear'),
      bindTransport: (_) => events.add('bind'),
      discoverCapabilities: () async => events.add('discover'),
      probeSession: () async => events.add('probe'),
    );

    final result = await coordinator.activate(
      const ActiveContextRequest(
        contextId: 'server-1/account-10',
        baseUrl: 'https://nas:5001',
        deviceId: 'device',
        sid: 'sid',
      ),
    );

    expect(result.status, ActiveContextStatus.authenticated);
    expect(events, ['clear', 'bind', 'discover', 'probe']);
    expect(result.contextId, 'server-1/account-10');
  });

  test('network failure keeps the selected context as offline instead of logging out', () async {
    final coordinator = ActiveContextCoordinator(
      clearCapabilities: () {},
      bindTransport: (_) {},
      discoverCapabilities: () async {
        throw Exception('offline');
      },
      probeSession: () async {},
    );

    final result = await coordinator.activate(
      const ActiveContextRequest(
        contextId: 'server-1/account-10',
        baseUrl: 'https://nas:5001',
        deviceId: 'device',
        sid: 'sid',
      ),
    );

    expect(result.status, ActiveContextStatus.offline);
    expect(result.contextId, 'server-1/account-10');
  });

  test('DSM 119 is classified as reauthentication required', () async {
    final coordinator = ActiveContextCoordinator(
      clearCapabilities: () {},
      bindTransport: (_) {},
      discoverCapabilities: () async {},
      probeSession: () async {
        throw const DsmException(119);
      },
    );

    final result = await coordinator.activate(
      const ActiveContextRequest(
        contextId: 'server-1/account-10',
        baseUrl: 'https://nas:5001',
        deviceId: 'device',
        sid: 'sid',
      ),
    );

    expect(result.status, ActiveContextStatus.reauthNeeded);
  });
}
