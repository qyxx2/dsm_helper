import 'package:dsm_helper/models/Syno/Core/System.dart';
import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';
import 'package:dsm_helper/new_ui/dashboard/widgets/core_resource_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({System? system, Utilization? utilization, Storage? storage,
      double scale = 1}) => MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: SingleChildScrollView(
              child: SizedBox(
                width: 320,
                child: CoreResourceSection(
                  system: system,
                  utilization: utilization,
                  storage: storage,
                ),
              ),
            ),
          ),
        ),
      );

  testWidgets('CPU shows actual 1 5 15 minute loads and system temperature',
      (tester) async {
    await tester.pumpWidget(host(
      system: System(sysTemp: 48),
      utilization: Utilization(
        cpu: Cpu(userLoad: 23, systemLoad: 12,
          minLoad1: 100, minLoad5: 200, minLoad15: 300),
      ),
    ));
    expect(find.text('35%'), findsOneWidget);
    expect(find.textContaining('1 分钟'), findsOneWidget);
    expect(find.textContaining('5 分钟'), findsOneWidget);
    expect(find.textContaining('15 分钟'), findsOneWidget);
    expect(find.textContaining('10 分钟'), findsNothing);
    expect(find.textContaining('系统温度'), findsOneWidget);
    expect(find.textContaining('CPU 温度'), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 15)));

  testWidgets('CPU missing inputs never fabricate a 0 percent', (tester) async {
    await tester.pumpWidget(host(utilization: Utilization(cpu: Cpu())));
    expect(find.text('0%'), findsNothing);
    expect(find.textContaining('分钟'), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 15)));

  testWidgets('memory usage is shown without inventing absolute sizes',
      (tester) async {
    await tester.pumpWidget(host(
      utilization: Utilization(memory: Memory(realUsage: 64)),
    ));
    expect(find.text('64%'), findsOneWidget);
    expect(find.textContaining('GiB'), findsNothing);
    await tester.pumpWidget(host(utilization: Utilization(memory: Memory())));
    expect(find.text('0%'), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 15)));

  testWidgets('each real volume renders its own valid fields only', (tester) async {
    const gib = 1073741824;
    await tester.pumpWidget(host(storage: Storage(volumes: [
      Volumes(id: 'volume_1', status: 'normal',
        size: Size(total: 8 * gib, used: 3 * gib)),
      Volumes(id: 'volume_2', status: 'attention',
        size: Size(total: 4 * gib, used: 1 * gib)),
      Volumes(id: 'volume_3', status: 'unknown',
        size: Size()),
    ])));
    expect(find.text('存储空间 1'), findsOneWidget);
    expect(find.text('存储空间 2'), findsOneWidget);
    expect(find.text('存储空间 3'), findsOneWidget);
    expect(find.text('37.5%'), findsOneWidget);
    expect(find.text('25.0%'), findsOneWidget);
    expect(find.textContaining('已用'), findsNWidgets(2));
    expect(find.textContaining('可用'), findsNWidgets(2));
    expect(find.textContaining('8.0 GiB'), findsOneWidget);
    expect(find.textContaining('警告'), findsOneWidget);
    expect(find.text('0.0%'), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 15)));

  testWidgets('large font and dark scheme remain renderable', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00A6FF), brightness: Brightness.dark)),
      home: Scaffold(body: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.2)),
        child: SingleChildScrollView(child: SizedBox(
          width: 320,
          child: CoreResourceSection(
            utilization: Utilization(cpu: Cpu(userLoad: 20, systemLoad: 10),
              memory: Memory(realUsage: 51)),
            system: System(sysTemp: 50),
            storage: Storage(),
          ),
        )),
      )),
    ));
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 15)));
}
