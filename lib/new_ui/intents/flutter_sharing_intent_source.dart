import 'package:dsm_helper/new_ui/intents/external_intent_listener.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';

class FlutterSharingIntentSource implements ExternalIntentSource {
  const FlutterSharingIntentSource();

  @override
  Future<List<String>> getInitialPaths() async {
    final files = await FlutterSharingIntent.instance.getInitialSharing();
    return files
        .map((file) => file.path ?? '')
        .where((path) => path.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Stream<List<String>> get pathStream {
    return FlutterSharingIntent.instance.getMediaStream().map(
          (files) => files
              .map((file) => file.path ?? '')
              .where((path) => path.isNotEmpty)
              .toList(growable: false),
        );
  }
}
