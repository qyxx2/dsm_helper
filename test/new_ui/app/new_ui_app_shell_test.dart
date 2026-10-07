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
}
