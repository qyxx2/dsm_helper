import 'package:dsm_helper/new_ui/intents/external_intent_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('one torrent routes to Download Station add-task fallback', () {
    final decision = ExternalIntentRouter.classify(
      const ['/tmp/example.torrent'],
    );
    expect(decision.kind, ExternalIntentKind.torrent);
    expect(decision.paths, ['/tmp/example.torrent']);
  });

  test('ordinary shared files route to upload fallback', () {
    final decision = ExternalIntentRouter.classify(
      const ['/tmp/a.jpg', '/tmp/b.pdf'],
    );
    expect(decision.kind, ExternalIntentKind.upload);
  });

  test('empty share payload is ignored', () {
    expect(
      ExternalIntentRouter.classify(const []).kind,
      ExternalIntentKind.none,
    );
  });

  test('same payload is consumed only once', () {
    final deduplicator = ExternalIntentDeduplicator();
    expect(deduplicator.shouldHandle(const ['/tmp/a.jpg']), isTrue);
    expect(deduplicator.shouldHandle(const ['/tmp/a.jpg']), isFalse);
    expect(deduplicator.shouldHandle(const ['/tmp/b.jpg']), isTrue);
  });
}
