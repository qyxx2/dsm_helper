import 'package:dsm_helper/new_ui/navigation/root_back_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('root back requires a second press inside the exit window', () {
    final policy = RootBackPolicy(window: const Duration(seconds: 2));
    final now = DateTime(2026, 10, 7, 12);

    expect(policy.register(now), RootBackDecision.showExitHint);
    expect(
      policy.register(now.add(const Duration(seconds: 1))),
      RootBackDecision.exitApp,
    );

    final later = now.add(const Duration(seconds: 10));
    expect(policy.register(later), RootBackDecision.showExitHint);
  });
}
