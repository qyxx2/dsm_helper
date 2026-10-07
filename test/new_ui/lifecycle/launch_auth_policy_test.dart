import 'package:dsm_helper/new_ui/lifecycle/launch_auth_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('launch auth requires the master switch plus one local auth method', () {
    expect(
      LaunchAuthPolicy.shouldGate(
        launchAuth: true,
        passwordEnabled: true,
        biometricsEnabled: false,
      ),
      isTrue,
    );
    expect(
      LaunchAuthPolicy.shouldGate(
        launchAuth: true,
        passwordEnabled: false,
        biometricsEnabled: true,
      ),
      isTrue,
    );
    expect(
      LaunchAuthPolicy.shouldGate(
        launchAuth: false,
        passwordEnabled: true,
        biometricsEnabled: true,
      ),
      isFalse,
    );
    expect(
      LaunchAuthPolicy.shouldGate(
        launchAuth: true,
        passwordEnabled: false,
        biometricsEnabled: false,
      ),
      isFalse,
    );
  });
}
