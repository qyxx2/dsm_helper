import 'dart:async';

typedef AppServiceEndpointProbe = Future<String?> Function(String endpoint);

class AppServiceEndpointResolver {
  const AppServiceEndpointResolver._();

  static Future<String?> resolve(
    List<String> endpoints, {
    required AppServiceEndpointProbe probe,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    if (endpoints.isEmpty) {
      return null;
    }

    final completer = Completer<String?>();
    var remaining = endpoints.length;

    void completeFailedProbe() {
      remaining -= 1;
      if (remaining == 0 && !completer.isCompleted) {
        completer.complete(null);
      }
    }

    for (final endpoint in endpoints) {
      Future<void>(() async {
        try {
          final resolved = await probe(endpoint);
          if (resolved != null && resolved.isNotEmpty) {
            if (!completer.isCompleted) {
              completer.complete(resolved);
            }
          } else {
            completeFailedProbe();
          }
        } catch (_) {
          completeFailedProbe();
        }
      });
    }

    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });

    try {
      return await completer.future;
    } finally {
      timer.cancel();
    }
  }
}
