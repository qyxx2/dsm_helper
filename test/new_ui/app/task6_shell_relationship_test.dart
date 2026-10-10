import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _shellSource() =>
    File('lib/new_ui/app/dsm_new_ui_shell.dart').readAsStringSync();

String _destination(String source, String label, {String? before}) {
  final start = source.indexOf("label: '$label',");
  expect(start, isNonNegative, reason: 'Missing primary destination $label');
  final end = before == null
      ? source.length
      : source.indexOf("label: '$before',", start + 1);
  expect(end == -1 || end > start, isTrue);
  return source.substring(start, end < 0 ? source.length : end);
}

void main() {
  test('Applications and My are Modern production roots, not placeholder roots', () {
    final source = _shellSource();
    final apps = _destination(source, '应用', before: '任务');
    final my = _destination(source, '我的');

    expect(apps, contains('modernBuilder:'));
    expect(apps, contains('ApplicationsPage('));
    expect(my, contains('modernBuilder:'));
    expect(my, contains('SettingsPage('));
    expect(RegExp(r'modernBuilder\s*:').allMatches(source).length, 3);
  });

  test('Overview, Files, Tasks and both legacy root fallbacks stay wired', () {
    final source = _shellSource();
    expect(_destination(source, '概览', before: '文件'),
        contains('OverviewPage('));
    expect(_destination(source, '文件', before: '应用'),
        contains('FilePage('));
    expect(_destination(source, '任务', before: '我的'),
        contains('Transfer('));
    expect(_destination(source, '应用', before: '任务'),
        contains('legacyBuilder: (_) => Applications()'));
    expect(_destination(source, '我的'),
        contains('legacyBuilder: (_) => Setting('));
  });

  test('Applications and My share notification, context and legacy-host authority', () {
    final source = _shellSource();
    final apps = _destination(source, '应用', before: '任务');
    final my = _destination(source, '我的');

    for (final destination in [apps, my]) {
      expect(destination, contains('onOpenNotifications: onOpenNotifications'));
      expect(destination, contains('connectionStatusText: connectionStatusText'));
    }
    expect(source, contains('ModernApplicationDestinationCatalog('));
    expect(source, contains('LegacyPageHost(builder: builder)'));
    expect(source, contains('providerScope.wrap('));
    expect(source, contains('KeyedSubtree('));
    expect(source, contains("ValueKey(widget.contextId ?? 'legacy-current-context')"));
  });

  test('Only My owns Task 4 account management and logout callbacks', () {
    final source = _shellSource();
    final apps = _destination(source, '应用', before: '任务');
    final my = _destination(source, '我的');

    expect(my, contains('onOpenAccountManagement:'));
    expect(my, contains('onLogout:'));
    expect(apps, isNot(contains('onOpenAccountManagement:')));
    expect(apps, isNot(contains('onLogout:')));
    expect(source, contains('widget.onManageAccounts'));
    expect(source, contains('widget.onLogout'));
  });
}
