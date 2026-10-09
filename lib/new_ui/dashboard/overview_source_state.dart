enum OverviewSourcePhase {
  initial,
  loading,
  valid,
  refreshing,
  stale,
  error,
  unavailable,
}

class OverviewSourceState<T> {
  const OverviewSourceState({
    required this.phase,
    this.value,
    this.error,
    this.updatedAt,
  });

  final OverviewSourcePhase phase;
  final T? value;
  final Object? error;
  final DateTime? updatedAt;

  bool get hasValue => value != null;
}
