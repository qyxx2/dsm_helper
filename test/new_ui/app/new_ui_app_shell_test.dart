import 'package:dsm_helper/new_ui/app/new_ui_app_shell.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _legacy(String label) => Scaffold(
      appBar: AppBar(title: Text('legacy-$label')),
      body: Text('body-$label'),
    );

List<NewUiAppDestination> _destinations({
  bool Function()? fileBack,
}) => [
      NewUiAppDestination.test(label: '概览', legacyBuilder: (_) => _legacy('overview')),
      NewUiAppDestination.test(
        label: '文件',
        legacyBuilder: (_) => _legacy('files'),
        onLegacyBack: fileBack,
      ),
      NewUiAppDestination.test(label: '应用', legacyBuilder: (_) => _legacy('apps')),
      NewUiAppDestination.test(label: '任务', legacyBuilder: (_) => _legacy('tasks')),
      NewUiAppDestination.test(label: '我的', legacyBuilder: (_) => _legacy('me')),
    ];

void main() {
  testWidgets('feature fallback is hosted as legacy and Back returns to same primary tab', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NewUiTheme.light(),
        home: NewUiAppShell(
          notificationBuilder: (_) => _legacy('notifications'),
          destinations: _destinations(),
        ),
      ),
    );

    await tester.tap(find.text('文件'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-legacy-feature')));
    await tester.pumpAndSettle();

    expect(find.text('legacy-files'), findsOneWidget);
    expect(Theme.of(tester.element(find.text('body-files'))).colorScheme.primary,
        isNot(const Color(0xFF00A6FF)));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('文件'), findsWidgets);
  });

  testWidgets('destination Back delegate consumes nested feature Back before fallback exits', (tester) async {
    var consume = true;
    var delegated = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: NewUiTheme.light(),
        home: NewUiAppShell(
          notificationBuilder: (_) => _legacy('notifications'),
          destinations: _destinations(
            fileBack: () {
              delegated++;
              if (consume) {
                consume = false;
                return true;
              }
              return false;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('文件'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-legacy-feature')));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('legacy-files'), findsOneWidget);
    expect(delegated, 1);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('legacy-files'), findsNothing);
    expect(delegated, 2);
  });

  testWidgets('global notification fallback opens from a non-overview tab without resetting tab state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NewUiTheme.light(),
        home: NewUiAppShell(
          notificationBuilder: (_) => _legacy('notifications'),
          destinations: _destinations(),
        ),
      ),
    );

    await tester.tap(find.text('应用'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('new-ui-notifications')));
    await tester.pumpAndSettle();
    expect(find.text('legacy-notifications'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    final navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navigationBar.selectedIndex, 2);
  });
  testWidgets('connection status propagates to every primary tab without healthy-state noise', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NewUiTheme.light(),
        home: NewUiAppShell(
          connectionStatusText: '离线',
          notificationBuilder: (_) => _legacy('notifications'),
          destinations: _destinations(),
        ),
      ),
    );

    expect(find.text('离线'), findsOneWidget);

    await tester.tap(find.text('任务'));
    await tester.pumpAndSettle();

    expect(find.text('离线'), findsOneWidget);
    expect(find.byKey(const Key('new-ui-notifications')), findsOneWidget);
  });

  testWidgets(
    'optional Modern root receives global notification and status while other tabs retain legacy fallback',
    (tester) async {
      final destinations = _destinations();
      destinations[0] = NewUiAppDestination(
        label: '概览',
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        legacyBuilder: (_) => _legacy('overview'),
        modernBuilder: (
          _, {
          required VoidCallback onOpenNotifications,
          required String? connectionStatusText,
        }) {
          return Scaffold(
            appBar: AppBar(
              title: Text('modern-status:$connectionStatusText'),
              actions: [
                IconButton(
                  key: const Key('modern-notifications'),
                  onPressed: onOpenNotifications,
                  icon: const Icon(Icons.notifications_outlined),
                ),
              ],
            ),
            body: const Text('modern-overview-root'),
          );
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: NewUiTheme.light(),
          home: NewUiAppShell(
            connectionStatusText: '离线',
            notificationBuilder: (_) => _legacy('notifications'),
            destinations: destinations,
          ),
        ),
      );

      expect(find.text('modern-overview-root'), findsOneWidget);
      expect(find.text('modern-status:离线'), findsOneWidget);
      expect(find.byKey(const Key('open-legacy-feature')), findsNothing);

      await tester.tap(find.byKey(const Key('modern-notifications')));
      await tester.pumpAndSettle();
      expect(find.text('legacy-notifications'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('modern-overview-root'), findsOneWidget);

      for (final tab in ['文件', '应用', '任务', '我的']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('open-legacy-feature')), findsOneWidget);
        await tester.tap(find.byKey(const Key('open-legacy-feature')));
        await tester.pumpAndSettle();
        expect(find.text('legacy-${tab == '文件' ? 'files' : tab == '应用' ? 'apps' : tab == '任务' ? 'tasks' : 'me'}'), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text(tab), findsWidgets);
      }

      await tester.tap(find.text('概览'));
      await tester.pumpAndSettle();
      expect(find.text('modern-overview-root'), findsOneWidget);
      expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex, 0);
    },
    timeout: const Timeout(Duration(seconds: 40)),
  );
}
