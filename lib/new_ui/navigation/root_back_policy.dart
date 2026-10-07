enum RootBackDecision {
  showExitHint,
  exitApp,
}

class RootBackPolicy {
  RootBackPolicy({
    this.window = const Duration(seconds: 2),
  });

  final Duration window;
  DateTime? _lastAttempt;

  RootBackDecision register(DateTime now) {
    final previous = _lastAttempt;
    _lastAttempt = now;

    if (previous != null && now.difference(previous) <= window) {
      return RootBackDecision.exitApp;
    }
    return RootBackDecision.showExitHint;
  }
}
