class LaunchAuthPolicy {
  const LaunchAuthPolicy._();

  static bool shouldGate({
    required bool launchAuth,
    required bool passwordEnabled,
    required bool biometricsEnabled,
  }) {
    return launchAuth && (passwordEnabled || biometricsEnabled);
  }
}
