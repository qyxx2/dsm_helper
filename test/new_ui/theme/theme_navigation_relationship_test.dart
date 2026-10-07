import 'package:dsm_helper/new_ui/shell/new_ui_shell.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('changing theme redraws without resetting the active nested route', (tester) async {
    final mode = ValueNotifier<ThemeMode>(ThemeMode.light);

    Widget root(String name) => Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              key: Key('push-$name'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => Scaffold(body: Text('child-$name')),
                ),
              ),
              child: Text(name),
            ),
          ),
        );

    await tester.pumpWidget(
      ValueListenableBuilder<ThemeMode>(
        valueListenable: mode,
        builder: (_, themeMode, __) => MaterialApp(
          theme: NewUiTheme.light(),
          darkTheme: NewUiTheme.dark(),
          themeMode: themeMode,
          home: NewUiShell(
            destinations: [
              NewUiShellDestination.test(label: '概览', root: (_) => root('overview')),
              NewUiShellDestination.test(label: '文件', root: (_) => root('files')),
              NewUiShellDestination.test(label: '应用', root: (_) => root('apps')),
              NewUiShellDestination.test(label: '任务', root: (_) => root('tasks')),
              NewUiShellDestination.test(label: '我的', root: (_) => root('me')),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('push-overview')));
    await tester.pumpAndSettle();
    expect(find.text('child-overview'), findsOneWidget);

    mode.value = ThemeMode.dark;
    await tester.pumpAndSettle();

    expect(find.text('child-overview'), findsOneWidget);
  });
}
