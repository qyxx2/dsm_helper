import 'package:dsm_helper/new_ui/dashboard/overview_source_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OverviewSourceState', () {
    test('initial has no value, error or timestamp', () {
      const state = OverviewSourceState<String>(
        phase: OverviewSourcePhase.initial,
      );
      expect(state.phase, OverviewSourcePhase.initial);
      expect(state.hasValue, isFalse);
      expect(state.value, isNull);
      expect(state.error, isNull);
      expect(state.updatedAt, isNull);
    });

    test('valid holds the actual value and update timestamp', () {
      final at = DateTime.utc(2026, 10, 9);
      final state = OverviewSourceState<String>(
        phase: OverviewSourcePhase.valid,
        value: 'V1',
        updatedAt: at,
      );
      expect(state.hasValue, isTrue);
      expect(state.value, 'V1');
      expect(state.updatedAt, at);
      expect(state.error, isNull);
    });

    test('refreshing retains last valid value and timestamp', () {
      final at = DateTime.utc(2026, 10, 9);
      final state = OverviewSourceState<String>(
        phase: OverviewSourcePhase.refreshing,
        value: 'V1',
        updatedAt: at,
      );
      expect(state.hasValue, isTrue);
      expect(state.value, 'V1');
      expect(state.updatedAt, at);
    });

    test('stale keeps V1, its timestamp and the failure', () {
      final at = DateTime.utc(2026, 10, 9);
      final error = StateError('transport failure');
      final state = OverviewSourceState<String>(
        phase: OverviewSourcePhase.stale,
        value: 'V1',
        updatedAt: at,
        error: error,
      );
      expect(state.hasValue, isTrue);
      expect(state.value, 'V1');
      expect(state.updatedAt, at);
      expect(identical(state.error, error), isTrue);
    });

    test('initial error has no fabricated value', () {
      final error = Exception('cannot load');
      final state = OverviewSourceState<String>(
        phase: OverviewSourcePhase.error,
        error: error,
      );
      expect(state.hasValue, isFalse);
      expect(state.value, isNull);
      expect(identical(state.error, error), isTrue);
    });

    test('unavailable capability differs from valid empty and error', () {
      const unavailable = OverviewSourceState<String>(
        phase: OverviewSourcePhase.unavailable,
      );
      const empty = OverviewSourceState<String>(
        phase: OverviewSourcePhase.valid,
        value: '',
      );
      expect(unavailable.phase, isNot(OverviewSourcePhase.error));
      expect(unavailable.phase, isNot(empty.phase));
      expect(unavailable.hasValue, isFalse);
      expect(empty.hasValue, isTrue);
      expect(empty.value, isEmpty);
      expect(unavailable.error, isNull);
    });
  });
}
