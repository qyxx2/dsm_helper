import 'package:dsm_helper/new_ui/shell/new_ui_shell.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _root(String name) {
  return Builder(
    builder: (context) => Scaffold(
      body: Column(
        children: [
          Text('root-$name'),
          ElevatedButton(
            key: Key('push-$name'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => Scaffold(body: Text('child-$name')),
                ),
              );
            },
            child: const Text('push'),
          ),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('primary tabs preserve independent navigator stacks', (tester) async {
    final key = GlobalKey<NewUiShellState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: NewUiTheme.light(),
        home: NewUiShell(
          key: key,
          destinations: [
            NewUiShellDestination.test(label: '概览', root: (_) => _root('overview')),
            NewUiShellDestination.test(label: '文件', root: (_) => _root('files')),
            NewUiShellDestination.test(label: '应用', root: (_) => _root('apps')),
            NewUiShellDestination.test(label: '任务', root: (_) => _root('tasks')),
            NewUiShellDestination.test(label: '我的', root: (_) => _root('me')),
          ],
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('push-overview')));
    await tester.pumpAndSettle();
    expect(find.text('child-overview'), findsOneWidget);

    await tester.tap(find.text('文件'));
    await tester.pumpAndSettle();
    expect(find.text('root-files'), findsOneWidget);
    await tester.tap(find.byKey(const Key('push-files')));
    await tester.pumpAndSettle();
    expect(find.text('child-files'), findsOneWidget);

    await tester.tap(find.text('概览'));
    await tester.pumpAndSettle();
    expect(find.text('child-overview'), findsOneWidget);

    final popped = await key.currentState!.popCurrentTab();
    await tester.pumpAndSettle();
    expect(popped, isTrue);
    expect(find.text('root-overview'), findsOneWidget);

    await tester.tap(find.text('文件'));
    await tester.pumpAndSettle();
    expect(find.text('child-files'), findsOneWidget);
  });

  testWidgets('all five destinations keep icon and label visible', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NewUiTheme.light(),
        home: NewUiShell(
          destinations: [
            NewUiShellDestination.test(label: '概览', root: (_) => _root('overview')),
            NewUiShellDestination.test(label: '文件', root: (_) => _root('files')),
            NewUiShellDestination.test(label: '应用', root: (_) => _root('apps')),
            NewUiShellDestination.test(label: '任务', root: (_) => _root('tasks')),
            NewUiShellDestination.test(label: '我的', root: (_) => _root('me')),
          ],
        ),
      ),
    );

    for (final label in ['概览', '文件', '应用', '任务', '我的']) {
      expect(find.text(label), findsOneWidget);
    }
  });
}


testWidgets('context switch reset returns every tab to root and selects overview', (tester) async {
  final key = GlobalKey<NewUiShellState>();
  await tester.pumpWidget(
    MaterialApp(
      theme: NewUiTheme.light(),
      home: NewUiShell(
        key: key,
        destinations: [
          NewUiShellDestination.test(label: '概览', root: (_) => _root('overview')),
          NewUiShellDestination.test(label: '文件', root: (_) => _root('files')),
          NewUiShellDestination.test(label: '应用', root: (_) => _root('apps')),
          NewUiShellDestination.test(label: '任务', root: (_) => _root('tasks')),
          NewUiShellDestination.test(label: '我的', root: (_) => _root('me')),
        ],
      ),
    ),
  );

  await tester.tap(find.byKey(const Key('push-overview')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('文件'));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('push-files')));
  await tester.pumpAndSettle();

  await key.currentState!.resetForContextSwitch();
  await tester.pumpAndSettle();

  expect(find.text('root-overview'), findsOneWidget);
  await tester.tap(find.text('文件'));
  await tester.pumpAndSettle();
  expect(find.text('root-files'), findsOneWidget);
});
