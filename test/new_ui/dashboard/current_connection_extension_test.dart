import 'package:dsm_helper/models/Syno/Core/CurrentConnection.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_source_state.dart';
import 'package:dsm_helper/new_ui/dashboard/widgets/current_connection_extension.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(OverviewSourceState<CurrentConnection> state) {
  return MaterialApp(
    theme: NewUiTheme.light(),
    home: Scaffold(
      body: SingleChildScrollView(
        child: CurrentConnectionExtension(state: state),
      ),
    ),
  );
}

void main() {
  testWidgets('successful empty means no current connections', (tester) async {
    await tester.pumpWidget(_host(
      OverviewSourceState<CurrentConnection>(
        phase: OverviewSourcePhase.valid,
        value: CurrentConnection(items: <UserItems>[], total: 0),
      ),
    ));

    expect(find.byKey(const Key('overview-current-connections')), findsOneWidget);
    expect(find.text('当前连接'), findsOneWidget);
    expect(find.text('暂无当前连接'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('compact summary uses real user and source fields', (tester) async {
    await tester.pumpWidget(_host(
      OverviewSourceState<CurrentConnection>(
        phase: OverviewSourcePhase.valid,
        value: CurrentConnection(
          total: 2,
          items: <UserItems>[
            UserItems(who: 'alice', from: '192.168.1.21'),
            UserItems(who: 'bob', from: '10.0.0.8'),
          ],
        ),
      ),
    ));

    expect(find.text('alice'), findsOneWidget);
    expect(find.text('192.168.1.21'), findsOneWidget);
    expect(find.text('bob'), findsOneWidget);
    expect(find.text('10.0.0.8'), findsOneWidget);
    expect(find.textContaining('2'), findsWidgets);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('stale prior data remains readable with explicit stale label',
      (tester) async {
    await tester.pumpWidget(_host(
      OverviewSourceState<CurrentConnection>(
        phase: OverviewSourcePhase.stale,
        value: CurrentConnection(
          total: 1,
          items: <UserItems>[
            UserItems(who: 'last-user', from: '172.16.0.4'),
          ],
        ),
        error: StateError('temporary failure'),
      ),
    ));

    expect(find.text('last-user'), findsOneWidget);
    expect(find.text('172.16.0.4'), findsOneWidget);
    expect(find.textContaining('已过期'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('Modern summary exposes no kick or disconnect mutation control',
      (tester) async {
    await tester.pumpWidget(_host(
      OverviewSourceState<CurrentConnection>(
        phase: OverviewSourcePhase.valid,
        value: CurrentConnection(
          total: 1,
          items: <UserItems>[
            UserItems(
              who: 'operator',
              from: '192.168.1.9',
              canBeKicked: true,
            ),
          ],
        ),
      ),
    ));

    expect(find.textContaining('踢出'), findsNothing);
    expect(find.textContaining('断开'), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(IconButton), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 20)));
}
