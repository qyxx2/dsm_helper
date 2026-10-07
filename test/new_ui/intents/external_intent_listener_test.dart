import 'dart:async';

import 'package:dsm_helper/new_ui/intents/external_intent_listener.dart';
import 'package:dsm_helper/new_ui/intents/external_intent_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSource implements ExternalIntentSource {
  _FakeSource(this.initial);

  final List<String> initial;
  final controller = StreamController<List<String>>.broadcast();

  @override
  Future<List<String>> getInitialPaths() async => initial;

  @override
  Stream<List<String>> get pathStream => controller.stream;

  Future<void> dispose() => controller.close();
}

void main() {
  testWidgets('initial and warm duplicate payloads hand off exactly once', (tester) async {
    final source = _FakeSource(const ['/tmp/a.jpg']);
    final decisions = <ExternalIntentDecision>[];

    await tester.pumpWidget(
      MaterialApp(
        home: ExternalIntentListener(
          source: source,
          onDecision: decisions.add,
          child: const SizedBox(),
        ),
      ),
    );
    await tester.pump();

    source.controller.add(const ['/tmp/a.jpg']);
    await tester.pump();
    source.controller.add(const ['/tmp/b.torrent']);
    await tester.pump();

    expect(decisions.map((e) => e.kind).toList(), [
      ExternalIntentKind.upload,
      ExternalIntentKind.torrent,
    ]);

    await source.dispose();
  });
}
