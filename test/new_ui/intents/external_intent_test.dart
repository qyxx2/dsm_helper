import 'dart:async';

import 'package:dsm_helper/new_ui/intents/external_intent.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSource implements ExternalIntentSource {
  _FakeSource(this.initial);

  final List<String> initial;
  final controller = StreamController<List<String>>.broadcast();
  int initialCalls = 0;
  int streamListenCount = 0;

  @override
  Future<List<String>> initialPaths() async {
    initialCalls += 1;
    return initial;
  }

  @override
  Stream<List<String>> get pathStream {
    return controller.stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          streamListenCount += 1;
          sink.add(data);
        },
      ),
    );
  }

  Future<void> close() => controller.close();
}

void main() {
  test('single torrent is distinct from ordinary or multiple shared files', () {
    expect(
      ExternalIntentPayload.fromPaths(['/tmp/a.torrent'])?.kind,
      ExternalIntentKind.torrent,
    );
    expect(
      ExternalIntentPayload.fromPaths(['/tmp/a.jpg'])?.kind,
      ExternalIntentKind.files,
    );
    expect(
      ExternalIntentPayload.fromPaths(['/tmp/a.torrent', '/tmp/b.txt'])?.kind,
      ExternalIntentKind.files,
    );
    expect(ExternalIntentPayload.fromPaths(['', '']) , isNull);
  });

  test('controller consumes cold and warm events once without duplicate start',
      () async {
    var now = DateTime(2026, 10, 7, 12);
    final source = _FakeSource(['/tmp/a.torrent']);
    addTearDown(source.close);
    final received = <ExternalIntentPayload>[];

    final controller = ExternalIntentController(
      source: source,
      onIntent: (payload) async => received.add(payload),
      now: () => now,
      duplicateWindow: const Duration(seconds: 2),
    );
    addTearDown(controller.dispose);

    await controller.start();
    await controller.start();

    expect(source.initialCalls, 1);
    expect(received.length, 1);
    expect(received.single.kind, ExternalIntentKind.torrent);

    source.controller.add(['/tmp/a.torrent']);
    await Future<void>.delayed(Duration.zero);
    expect(received.length, 1);

    now = now.add(const Duration(seconds: 3));
    source.controller.add(['/tmp/a.torrent']);
    await Future<void>.delayed(Duration.zero);
    expect(received.length, 2);

    source.controller.add(['/tmp/file.txt']);
    await Future<void>.delayed(Duration.zero);
    expect(received.length, 3);
    expect(received.last.kind, ExternalIntentKind.files);
  });
}
