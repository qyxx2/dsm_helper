import 'dart:async';

import 'package:dsm_helper/new_ui/intents/external_intent_router.dart';
import 'package:flutter/widgets.dart';

abstract class ExternalIntentSource {
  Future<List<String>> getInitialPaths();

  Stream<List<String>> get pathStream;
}

typedef ExternalIntentHandler = void Function(ExternalIntentDecision decision);

class ExternalIntentListener extends StatefulWidget {
  const ExternalIntentListener({
    super.key,
    required this.source,
    required this.onDecision,
    required this.child,
  });

  final ExternalIntentSource source;
  final ExternalIntentHandler onDecision;
  final Widget child;

  @override
  State<ExternalIntentListener> createState() => _ExternalIntentListenerState();
}

class _ExternalIntentListenerState extends State<ExternalIntentListener> {
  final ExternalIntentDeduplicator _deduplicator = ExternalIntentDeduplicator();
  StreamSubscription<List<String>>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.source.pathStream.listen(_handlePaths);
    unawaited(_loadInitialPaths());
  }

  Future<void> _loadInitialPaths() async {
    final paths = await widget.source.getInitialPaths();
    if (mounted) {
      _handlePaths(paths);
    }
  }

  void _handlePaths(List<String> paths) {
    if (!_deduplicator.shouldHandle(paths)) {
      return;
    }
    final decision = ExternalIntentRouter.classify(paths);
    if (decision.kind != ExternalIntentKind.none) {
      widget.onDecision(decision);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
