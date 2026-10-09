import 'package:dsm_helper/new_ui/dashboard/widgets/device_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({String? hostname, String? uptime, double scale = 1}) =>
      MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: SizedBox(
              width: 320,
              child: DeviceSummary(hostname: hostname, uptime: uptime),
            ),
          ),
        ),
      );

  testWidgets('hostname left and real uptime formatted on the right', (tester) async {
    await tester.pumpWidget(host(hostname: 'NAS-A', uptime: '240:6:24'));
    expect(find.text('NAS-A'), findsOneWidget);
    expect(find.text('10天 00:06:24'), findsOneWidget);
    final left = tester.getTopLeft(find.text('NAS-A'));
    final right = tester.getTopLeft(find.text('10天 00:06:24'));
    expect(left.dx, lessThan(right.dx));
  }, timeout: const Timeout(Duration(seconds: 15)));

  testWidgets('missing uptime or hostname omits its value', (tester) async {
    await tester.pumpWidget(host(hostname: 'NAS-B'));
    expect(find.text('NAS-B'), findsOneWidget);
    expect(find.textContaining('运行时间'), findsNothing);
    await tester.pumpWidget(host(uptime: '2:3:4'));
    expect(find.text('02:03:04'), findsOneWidget);
    expect(find.text('NAS-B'), findsNothing);
    await tester.pumpWidget(host());
    expect(find.text('0'), findsNothing);
    expect(find.text('-'), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 15)));

  testWidgets('large text scaling does not overflow a portrait phone', (tester) async {
    await tester.pumpWidget(host(
      hostname: 'Very-Long-NAS-Hostname-For-A-Device',
      uptime: '240:6:24',
      scale: 2.2,
    ));
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 15)));
}
