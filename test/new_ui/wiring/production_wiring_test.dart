import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('main boots the Modern UI root instead of legacy Splash/Home', () {
    final main = _read('lib/main.dart');

    expect(main, contains("package:dsm_helper/new_ui/app/modern_ui_root.dart"));
    expect(main, contains('home: ModernUiRoot('));
    expect(main, isNot(contains('home: Splash()')));
    expect(main, isNot(contains('"/home": (BuildContext context) => Home()')));
  });

  test('legacy login success hands off to the New UI shell, not legacy Home', () {
    final login = _read('lib/pages/login/login.dart');

    expect(login, contains("package:dsm_helper/new_ui/app/modern_ui_shell_entry.dart"));
    expect(login, contains('ModernUiShellEntry()'));
    expect(login, isNot(contains('context.push(Home(), replace: true)')));
  });

  test('saved-account success hands off to the New UI shell, not legacy Home', () {
    final selector = _read('lib/pages/server/select_server.dart');

    expect(selector, contains("package:dsm_helper/new_ui/app/modern_ui_shell_entry.dart"));
    expect(selector, contains('ModernUiShellEntry()'));
    expect(selector, isNot(contains('context.push(Home(), replace: true)')));
  });

  test('concrete shell owns five legacy fallbacks and shell-global adapters', () {
    final shell = _read('lib/new_ui/app/dsm_new_ui_shell.dart');

    for (final token in [
      'Dashboard(',
      'FilePage(',
      'Applications(',
      'Transfer(',
      'Setting(',
      'LegacyNotificationEntry(',
      'ExternalIntentListener(',
      'FlutterSharingIntentSource(',
    ]) {
      expect(shell, contains(token), reason: 'missing concrete wiring: $token');
    }
  });

  test('Modern UI root owns cold-start persistence, context activation and launch-auth gate', () {
    final root = _read('lib/new_ui/app/modern_ui_root.dart');

    for (final token in [
      'ModernStartup(',
      'DsmStartupDataSource(',
      'DsmActiveContextAdapter(',
      'LaunchAuthGate(',
      'AuthPage(launch: false)',
      'FileDownloader(',
      'SqlitePersistentStorage(',
    ]) {
      expect(root, contains(token), reason: 'missing startup wiring: $token');
    }
  });
  test('cold-start activation result is forwarded into the concrete shell', () {
    final root = _read('lib/new_ui/app/modern_ui_root.dart');

    expect(root, contains('shellBuilder: (_, result)'));
    expect(root, contains('initialContextStatus: result.status'));
  });
  test('startup uses bounded optional app-service endpoint resolution', () {
    final main = _read('lib/main.dart');

    expect(main, contains('AppServiceEndpointResolver.resolve('));
  });

  test('DSM context bind synchronizes the legacy File Station session bridge', () {
    final adapter = _read('lib/new_ui/session/dsm_active_context_adapter.dart');

    expect(adapter, contains('LegacySessionBridge.bind(request)'));
  });
  test('legacy login and account selection synchronize File Station session before shell handoff', () {
    final login = _read('lib/pages/login/login.dart');
    final selector = _read('lib/pages/server/select_server.dart');

    expect(login, contains('LegacySessionBridge.bindValues('));
    expect(
      RegExp(r'LegacySessionBridge\.bindValues\(').allMatches(selector).length,
      greaterThanOrEqualTo(2),
    );
  });
}
