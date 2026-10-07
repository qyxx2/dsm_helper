import 'package:dsm_helper/new_ui/app/new_ui_app_shell.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _legacy(String label) => Scaffold(
      appBar: AppBar(title: Text('legacy-$label')),
      body: Text('body-$label'),
    );

void main() {
  testWidgets('feature fallback is hosted as legacy and Back returns to same primary tab', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NewUiTheme.light(),
        home: NewUiAppShell(
          notificationBuilder: (_) => _legacy('notifications'),
          destinations: [
            NewUiAppDestination.test(label: '概览', legacyBuilder: (_) => _legacy('overview')),
            NewUiAppDestination.test(label: '文件', legacyBuilder: (_) => _legacy('files')),
            NewUiAppDestination.test(label: '应用', legacyBuilder: (_) => _legacy('apps')),
            NewUiAppDestination.test(label: '任务', legacyBuilder: (_) => _legacy('tasks')),
            NewUiAppDestination.test(label: '我的', legacyBuilder: (_) => _legacy('me')),
          ],
        ),
      ),
    );

    await tester.tap(find.text('文件'));
    await tester.pumpAndSettle();
    expect(find.text('文件'), findsWidgets);

    await tester.tap(find.byKey(const Key('open-legacy-feature')));
    await tester.pumpAndSettle();
    expect(find.text('legacy-files'), findsOneWidget);
    expect(Theme.of(tester.element(find.text('body-files'))).colorScheme.primary,
        isNot(const Color(0xFF00A6FF)));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('文件'), findsWidgets);
  });

  testWidgets('global notification fallback opens from a non-overview tab without resetting tab state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NewUiTheme.light(),
        home: NewUiAppShell(
          notificationBuilder: (_) => _legacy('notifications'),
          destinations: [
            NewUiAppDestination.test(label: '概览', legacyBuilder: (_) => _legacy('overview')),
            NewUiAppDestination.test(label: '文件', legacyBuilder: (_) => _legacy('files')),
            NewUiAppDestination.test(label: '应用', legacyBuilder: (_) => _legacy('apps')),
            NewUiAppDestination.test(label: '任务', legacyBuilder: (_) => _legacy('tasks')),
            NewUiAppDestination.test(label: '我的', legacyBuilder: (_) => _legacy('me')),
          ],
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

    expect(find.text('应用'), findsWidgets);
    final navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navigationBar.selectedIndex, 2);
  });
}
