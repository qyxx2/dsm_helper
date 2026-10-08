import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:dsm_helper/new_ui/startup/modern_startup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSource implements StartupDataSource {
  _FakeSource(this.snapshot);

  final StartupSnapshot snapshot;

  @override
  Future<StartupSnapshot> load() async => snapshot;
}

Widget _label(String text) => Scaffold(body: Text(text));

void main() {
  testWidgets('no saved server routes to add-server without activating context', (tester) async {
    var activations = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: ModernStartup(
          dataSource: _FakeSource(
            const StartupSnapshot(
              hasServers: false,
              launcherSelectionEnabled: false,
              knownServerIds: <int>{},
              contexts: <StartupSavedContext>[],
            ),
          ),
          activateContext: (_) async {
            activations++;
            throw StateError('must not activate');
          },
          addServerBuilder: (_) => _label('add-server'),
          selectAccountBuilder: (_) => _label('select-account'),
          shellBuilder: (_, __) => _label('shell'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('add-server'), findsOneWidget);
    expect(activations, 0);
  });

  testWidgets('ambiguous defaults route to selector without guessing', (tester) async {
    var activations = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: ModernStartup(
          dataSource: _FakeSource(
            const StartupSnapshot(
              hasServers: true,
              launcherSelectionEnabled: false,
              knownServerIds: <int>{1, 2},
              contexts: <StartupSavedContext>[
                StartupSavedContext(
                  accountId: 10,
                  serverId: 1,
                  isDefault: true,
                  baseUrl: 'https://a',
                  deviceId: 'a-device',
                  sid: 'a-sid',
                ),
                StartupSavedContext(
                  accountId: 20,
                  serverId: 2,
                  isDefault: true,
                  baseUrl: 'https://b',
                  deviceId: 'b-device',
                  sid: 'b-sid',
                ),
              ],
            ),
          ),
          activateContext: (_) async {
            activations++;
            throw StateError('must not activate');
          },
          addServerBuilder: (_) => _label('add-server'),
          selectAccountBuilder: (_) => _label('select-account'),
          shellBuilder: (_, __) => _label('shell'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('select-account'), findsOneWidget);
    expect(activations, 0);
  });

  testWidgets('unique default enters shell even when DSM is temporarily offline', (tester) async {
    ActiveContextRequest? request;

    await tester.pumpWidget(
      MaterialApp(
        home: ModernStartup(
          dataSource: _FakeSource(
            const StartupSnapshot(
              hasServers: true,
              launcherSelectionEnabled: false,
              knownServerIds: <int>{7},
              contexts: <StartupSavedContext>[
                StartupSavedContext(
                  accountId: 42,
                  serverId: 7,
                  isDefault: true,
                  baseUrl: 'https://nas:5001',
                  deviceId: 'device',
                  sid: 'sid',
                ),
              ],
            ),
          ),
          activateContext: (value) async {
            request = value;
            return const ActiveContextResult(
              contextId: '7/42',
              status: ActiveContextStatus.offline,
            );
          },
          addServerBuilder: (_) => _label('add-server'),
          selectAccountBuilder: (_) => _label('select-account'),
          shellBuilder: (_, result) => _label('shell-${result.status.name}'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('shell-offline'), findsOneWidget);
    expect(request?.baseUrl, 'https://nas:5001');
    expect(request?.deviceId, 'device');
    expect(request?.sid, 'sid');
  });

  testWidgets('reauth-needed context sends the exact saved identity to reauth instead of generic selection', (tester) async {
    StartupSavedContext? reauth;
    await tester.pumpWidget(
      MaterialApp(
        home: ModernStartup(
          dataSource: _FakeSource(
            const StartupSnapshot(
              hasServers: true,
              launcherSelectionEnabled: false,
              knownServerIds: <int>{7},
              contexts: <StartupSavedContext>[
                StartupSavedContext(
                  accountId: 42,
                  serverId: 7,
                  isDefault: true,
                  baseUrl: 'https://nas:5001',
                  deviceId: 'device',
                  sid: 'sid',
                ),
              ],
            ),
          ),
          activateContext: (_) async => const ActiveContextResult(
            contextId: '7/42',
            status: ActiveContextStatus.reauthNeeded,
          ),
          addServerBuilder: (_) => _label('add-server'),
          selectAccountBuilder: (_) => _label('select-account'),
          shellBuilder: (_, __) => _label('shell'),
          onReauthNeeded: (value) => reauth = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(reauth?.accountId, 42);
    expect(reauth?.serverId, 7);
    expect(find.text('select-account'), findsNothing);
    expect(find.text('shell'), findsNothing);
  });
}
