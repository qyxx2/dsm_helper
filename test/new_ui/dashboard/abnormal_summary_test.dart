import 'dart:ui' as ui;

import 'package:dsm_helper/new_ui/dashboard/overview_alerts.dart';
import 'package:dsm_helper/new_ui/dashboard/widgets/abnormal_summary.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const errorAlert = OverviewAlert(
  id: 'notification:failure',
  title: 'DSM 错误事件',
  severity: OverviewAlertSeverity.error,
  destination: OverviewAlertDestination.notifications,
);
const warningAlert = OverviewAlert(
  id: 'storage:volume_1',
  title: '存储空间 1 · 警告',
  severity: OverviewAlertSeverity.warning,
  destination: OverviewAlertDestination.storageManager,
);

Widget host(
  List<OverviewAlert> alerts, {
  ValueChanged<OverviewAlertDestination>? onOpen,
  bool notificationsStale = false,
  Brightness brightness = Brightness.light,
  double scale = 1,
}) {
  return MaterialApp(
    theme: brightness == Brightness.light
        ? NewUiTheme.light()
        : NewUiTheme.dark(),
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: Scaffold(
        body: SingleChildScrollView(
          child: AbnormalSummary(
            alerts: alerts,
            onOpenDestination: onOpen,
            notificationsStale: notificationsStale,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('healthy states have no abnormal heading or empty-normal card',
      (tester) async {
    await tester.pumpWidget(host(const []));
    expect(find.text('异常提醒'), findsNothing);
    expect(find.textContaining('一切正常'), findsNothing);
    expect(find.byKey(const Key('overview-abnormal-summary')), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('warning and error have readable labels and distinct icons',
      (tester) async {
    await tester.pumpWidget(host(const [errorAlert, warningAlert]));
    expect(find.text('异常提醒'), findsOneWidget);
    expect(find.text('DSM 错误事件'), findsOneWidget);
    expect(find.text('存储空间 1 · 警告'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Icon && widget.semanticLabel == '错误',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Icon && widget.semanticLabel == '警告',
      ),
      findsOneWidget,
    );
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('each tap forwards the precise destination, not a guessed route',
      (tester) async {
    final destinations = <OverviewAlertDestination>[];
    await tester.pumpWidget(host(
      const [errorAlert, warningAlert],
      onOpen: destinations.add,
    ));
    await tester.tap(find.text('DSM 错误事件'));
    await tester.tap(find.text('存储空间 1 · 警告'));
    expect(destinations, [
      OverviewAlertDestination.notifications,
      OverviewAlertDestination.storageManager,
    ]);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('stale notifications preserve the alert and show textual state',
      (tester) async {
    await tester.pumpWidget(host(
      const [errorAlert],
      notificationsStale: true,
    ));
    expect(find.text('DSM 错误事件'), findsOneWidget);
    expect(find.text('通知数据已过期'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('Light/Dark and large system text do not overflow',
      (tester) async {
    tester.view.physicalSize = const ui.Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final brightness in [Brightness.light, Brightness.dark]) {
      await tester.pumpWidget(host(
        const [errorAlert, warningAlert],
        brightness: brightness,
        scale: 2.2,
      ));
      expect(tester.takeException(), isNull);
    }
  }, timeout: const Timeout(Duration(seconds: 25)));
}
