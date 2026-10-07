import 'package:dsm_helper/apis/dsm_api/dsm_exception.dart';
import 'package:dsm_helper/models/api_model.dart';
import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const target = ActiveContextTarget(
    baseUrl: 'https://nas.example:5001',
    deviceId: 'device',
    sid: 'sid',
    label: 'NAS A',
  );

  test('online restore binds new authority before publishing new metadata',
      () async {
    final events = <String>[];
    final metadata = {'SYNO.API.Info': ApiModel(maxVersion: 1)};

    final coordinator = ActiveContextCoordinator(
      bindAuthority: (value) => events.add('bind:${value.baseUrl}'),
      clearApiMetadata: () => events.add('clear'),
      discoverApiMetadata: () async {
        events.add('discover');
        return metadata;
      },
      publishApiMetadata: (value) {
        expect(identical(value, metadata), isTrue);
        events.add('publish');
      },
      probeSession: () async => events.add('probe'),
    );

    final result = await coordinator.restore(target);

    expect(result.status, ActiveContextStatus.online);
    expect(result.target, same(target));
    expect(
      events,
      [
        'bind:https://nas.example:5001',
        'clear',
        'discover',
        'publish',
        'probe',
      ],
    );
  });

  test('connectivity failure stays offline and never reuses old metadata',
      () async {
    final events = <String>[];

    final coordinator = ActiveContextCoordinator(
      bindAuthority: (_) => events.add('bind'),
      clearApiMetadata: () => events.add('clear'),
      discoverApiMetadata: () async {
        events.add('discover');
        throw Exception('network unavailable');
      },
      publishApiMetadata: (_) => events.add('publish'),
      probeSession: () async => events.add('probe'),
    );

    final result = await coordinator.restore(target);

    expect(result.status, ActiveContextStatus.offline);
    expect(events, ['bind', 'clear', 'discover']);
  });

  test('DSM auth invalidation 119 enters reauthentication', () async {
    final events = <String>[];

    final coordinator = ActiveContextCoordinator(
      bindAuthority: (_) => events.add('bind'),
      clearApiMetadata: () => events.add('clear'),
      discoverApiMetadata: () async {
        events.add('discover');
        return <String, ApiModel>{};
      },
      publishApiMetadata: (_) => events.add('publish'),
      probeSession: () async {
        events.add('probe');
        throw const DsmException(119);
      },
    );

    final result = await coordinator.restore(target);

    expect(result.status, ActiveContextStatus.reauthenticationRequired);
    expect(events, ['bind', 'clear', 'discover', 'publish', 'probe']);
  });

  test('non-auth probe failure is offline rather than forced logout', () async {
    final coordinator = ActiveContextCoordinator(
      bindAuthority: (_) {},
      clearApiMetadata: () {},
      discoverApiMetadata: () async => <String, ApiModel>{},
      publishApiMetadata: (_) {},
      probeSession: () async => throw Exception('timeout'),
    );

    final result = await coordinator.restore(target);

    expect(result.status, ActiveContextStatus.offline);
  });
}
