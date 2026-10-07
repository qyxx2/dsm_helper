import 'dart:async';

import 'package:dsm_helper/new_ui/startup/app_service_endpoint_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all failed probes resolve to null instead of blocking startup', () async {
    final result = await AppServiceEndpointResolver.resolve(
      const ['a', 'b'],
      probe: (endpoint) async => throw StateError(endpoint),
      timeout: const Duration(milliseconds: 20),
    );

    expect(result, isNull);
  });

  test('a successful probe wins even when another probe never completes', () async {
    final never = Completer<String?>();

    final result = await AppServiceEndpointResolver.resolve(
      const ['stuck', 'good'],
      probe: (endpoint) {
        if (endpoint == 'stuck') {
          return never.future;
        }
        return Future<String?>.value('http://resolved');
      },
      timeout: const Duration(milliseconds: 20),
    );

    expect(result, 'http://resolved');
  });
}
