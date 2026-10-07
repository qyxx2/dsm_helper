enum ExternalIntentKind {
  none,
  torrent,
  upload,
}

class ExternalIntentDecision {
  const ExternalIntentDecision({
    required this.kind,
    required this.paths,
  });

  final ExternalIntentKind kind;
  final List<String> paths;
}

class ExternalIntentRouter {
  const ExternalIntentRouter._();

  static ExternalIntentDecision classify(List<String> paths) {
    final normalized = paths
        .where((path) => path.trim().isNotEmpty)
        .toList(growable: false);

    if (normalized.isEmpty) {
      return const ExternalIntentDecision(
        kind: ExternalIntentKind.none,
        paths: <String>[],
      );
    }

    if (normalized.length == 1 &&
        normalized.single.toLowerCase().endsWith('.torrent')) {
      return ExternalIntentDecision(
        kind: ExternalIntentKind.torrent,
        paths: normalized,
      );
    }

    return ExternalIntentDecision(
      kind: ExternalIntentKind.upload,
      paths: normalized,
    );
  }
}

class ExternalIntentDeduplicator {
  final Set<String> _handledPayloads = <String>{};

  bool shouldHandle(List<String> paths) {
    final key = paths.join('\u0000');
    if (key.isEmpty || _handledPayloads.contains(key)) {
      return false;
    }
    _handledPayloads.add(key);
    return true;
  }
}
