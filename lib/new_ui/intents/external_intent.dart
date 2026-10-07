import 'dart:async';

import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';

enum ExternalIntentKind {
  torrent,
  files,
}

class ExternalIntentPayload {
  ExternalIntentPayload._({
    required this.kind,
    required List<String> paths,
  }) : paths = List.unmodifiable(paths);

  final ExternalIntentKind kind;
  final List<String> paths;

  static ExternalIntentPayload? fromPaths(Iterable<String> sourcePaths) {
    final paths = sourcePaths.where((path) => path.trim().isNotEmpty).toList();
    if (paths.isEmpty) {
      return null;
    }

    final isSingleTorrent =
        paths.length == 1 && paths.single.toLowerCase().endsWith('.torrent');
    return ExternalIntentPayload._(
      kind:
          isSingleTorrent ? ExternalIntentKind.torrent : ExternalIntentKind.files,
      paths: paths,
    );
  }

  String get fingerprint {
    final normalized = [...paths]..sort();
    return '${kind.name}:${normalized.join('|')}';
  }
}

abstract interface class ExternalIntentSource {
  Future<List<String>> initialPaths();
  Stream<List<String>> get pathStream;
}

class FlutterSharingIntentSource implements ExternalIntentSource {
  const FlutterSharingIntentSource();

  @override
  Future<List<String>> initialPaths() async {
    final files = await FlutterSharingIntent.instance.getInitialSharing();
    return _paths(files);
  }

  @override
  Stream<List<String>> get pathStream {
    return FlutterSharingIntent.instance.getMediaStream().map(_paths);
  }

  static List<String> _paths(List<SharedFile> files) {
    return files
        .map((file) => file.path)
        .whereType<String>()
        .where((path) => path.isNotEmpty)
        .toList();
  }
}

class ExternalIntentController {
  ExternalIntentController({
    required this.source,
    required this.onIntent,
    DateTime Function()? now,
    this.duplicateWindow = const Duration(seconds: 2),
  }) : _now = now ?? DateTime.now;

  final ExternalIntentSource source;
  final Future<void> Function(ExternalIntentPayload payload) onIntent;
  final DateTime Function() _now;
  final Duration duplicateWindow;

  StreamSubscription<List<String>>? _subscription;
  bool _started = false;
  String? _lastFingerprint;
  DateTime? _lastHandledAt;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;

    _subscription = source.pathStream.listen((paths) {
      unawaited(_dispatch(paths));
    });

    final initial = await source.initialPaths();
    await _dispatch(initial);
  }

  Future<void> _dispatch(List<String> paths) async {
    final payload = ExternalIntentPayload.fromPaths(paths);
    if (payload == null) {
      return;
    }

    final now = _now();
    final lastHandledAt = _lastHandledAt;
    final isRecentDuplicate = _lastFingerprint == payload.fingerprint &&
        lastHandledAt != null &&
        now.difference(lastHandledAt) <= duplicateWindow;
    if (isRecentDuplicate) {
      return;
    }

    _lastFingerprint = payload.fingerprint;
    _lastHandledAt = now;
    await onIntent(payload);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
