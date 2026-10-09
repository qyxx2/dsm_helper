import 'package:dsm_helper/models/Syno/Core/System.dart';
import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';
import 'package:dsm_helper/new_ui/dashboard/widgets/core_resource_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({System? system, Utilization? utilization, Storage? storage,
      double scale = 1, double width = 320, bool dark = false}) => MaterialApp(
        theme: dark ? ThemeData.dark() : null,
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: SingleChildScrollView(
              child: SizedBox(
                width: width,
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
    expect(find.text('5 分钟 200'), findsOneWidget);
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


  testWidgets('one HDD uses unused upper-right header and never adds an empty slot',
      (tester) async {
    const gib = 1073741824;
    final volume = Volumes(id: 'volume_1', poolPath: 'pool_one',
        status: 'normal', size: Size(total: 8 * gib, used: 3 * gib));
    final baseline = Storage(volumes: [volume]);
    await tester.pumpWidget(host(storage: baseline));
    final percentY = tester.getTopLeft(find.text('37.5%')).dy;

    await tester.pumpWidget(host(storage: Storage(
      volumes: [volume],
      storagePools: [StoragePools(id: 'pool_one', disks: ['sda'])],
      disks: [
        Disks(id: 'sda', isSsd: false, temp: 40),
        Disks(id: 'unrelated', isSsd: true, temp: 78),
      ],
    )));
    final disk = find.text('HDD 40℃');
    expect(disk, findsOneWidget);
    expect(find.textContaining('SSD'), findsNothing);
    expect(find.textContaining('HDD 1'), findsNothing);
    expect(find.text('37.5%'), findsOneWidget);
    expect(find.textContaining('已用'), findsOneWidget);
    expect(find.textContaining('可用'), findsOneWidget);
    expect(tester.getTopLeft(find.text('37.5%')).dy, percentY);
    expect(tester.getTopLeft(disk).dx,
        greaterThan(tester.getTopLeft(find.text('存储空间 1')).dx));
    expect(tester.getTopLeft(disk).dy,
        lessThan(tester.getTopLeft(find.text('37.5%')).dy));
  }, timeout: const Timeout(Duration(seconds: 15)));

  testWidgets('four mixed disks follow pool membership and occupy two upper-right columns',
      (tester) async {
    await tester.pumpWidget(host(storage: Storage(
      volumes: [Volumes(id: 'volume_1', poolPath: 'reuse_1',
          size: Size(total: 1000, used: 350), status: 'normal')],
      storagePools: [
        StoragePools(id: 'reuse_1', disks: ['h1', 's1', 'h2', 's2']),
      ],
      disks: [
        Disks(id: 's2', isSsd: true, temp: 39),
        Disks(id: 'h2', isSsd: false, temp: 42),
        Disks(id: 's1', isSsd: true, temp: 38),
        Disks(id: 'h1', isSsd: false, temp: 40),
      ],
    )));
    final h1 = find.text('HDD 1 40℃');
    final s1 = find.text('SSD 1 38℃');
    final h2 = find.text('HDD 2 42℃');
    final s2 = find.text('SSD 2 39℃');
    for (final label in [h1, s1, h2, s2]) {
      expect(label, findsOneWidget);
      expect(tester.getTopLeft(label).dy,
          lessThan(tester.getTopLeft(find.text('35.0%')).dy));
    }
    expect(tester.getTopLeft(h1).dx, lessThan(tester.getTopLeft(s1).dx));
    expect(tester.getTopLeft(h2).dx, lessThan(tester.getTopLeft(s2).dx));
    expect(tester.getTopLeft(h1).dy, lessThan(tester.getTopLeft(h2).dy));
    expect(find.text('正常'), findsOneWidget);
    expect(find.textContaining('已用'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 15)));

  testWidgets('five or more eligible disks cap at four without extra placeholders',
      (tester) async {
    await tester.pumpWidget(host(storage: Storage(
      volumes: [Volumes(id: 'volume_1', poolPath: 'p')],
      storagePools: [
        StoragePools(id: 'p', disks: ['a', 'b', 'c', 'd', 'e', 'f']),
      ],
      disks: [
        Disks(id: 'a', isSsd: false, temp: 40),
        Disks(id: 'b', isSsd: false, temp: 41),
        Disks(id: 'c', isSsd: true, temp: 36),
        Disks(id: 'd', isSsd: true, temp: 37),
        Disks(id: 'e', isSsd: true, temp: 50),
        Disks(id: 'f', isSsd: false, temp: 51),
      ],
    )));
    for (final label in [
      'HDD 1 40℃', 'HDD 2 41℃', 'SSD 1 36℃', 'SSD 2 37℃',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.textContaining('50℃'), findsNothing);
    expect(find.textContaining('51℃'), findsNothing);
    expect(find.textContaining('HDD 3'), findsNothing);
    expect(find.textContaining('SSD 3'), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 15)));

  testWidgets('volume-to-pool identity is exact, isolated and permits shared pools',
      (tester) async {
    await tester.pumpWidget(host(storage: Storage(
      volumes: [
        Volumes(id: 'volume_1', poolPath: 'pool_a'),
        Volumes(id: 'volume_2', poolPath: 'pool_b'),
        Volumes(id: 'volume_3', poolPath: 'pool_a'),
        Volumes(id: 'volume_4', poolPath: 'missing'),
      ],
      storagePools: [
        StoragePools(id: 'pool_a', disks: ['a']),
        StoragePools(poolPath: 'pool_b', disks: ['b']),
      ],
      disks: [
        Disks(id: 'a', isSsd: false, temp: 40),
        Disks(id: 'b', isSsd: true, temp: 38),
        Disks(id: 'orphan', isSsd: false, temp: 66),
      ],
    )));
    final hdd = find.text('HDD 40℃');
    final ssd = find.text('SSD 38℃');
    expect(hdd, findsNWidgets(2));
    expect(ssd, findsOneWidget);
    expect(find.textContaining('66℃'), findsNothing);
    expect(tester.getTopLeft(hdd.at(0)).dy,
        lessThan(tester.getTopLeft(ssd).dy));
    expect(tester.getTopLeft(ssd).dy,
        lessThan(tester.getTopLeft(hdd.at(1)).dy));
  }, timeout: const Timeout(Duration(seconds: 15)));

  testWidgets('ambiguous pool relation, unknown type and invalid temperatures are omitted',
      (tester) async {
    await tester.pumpWidget(host(storage: Storage(
      volumes: [
        Volumes(id: 'volume_1', poolPath: 'ambiguous'),
        Volumes(id: 'volume_2', poolPath: 'safe'),
      ],
      storagePools: [
        StoragePools(id: 'ambiguous', disks: ['a']),
        StoragePools(poolPath: 'ambiguous', disks: ['b']),
        StoragePools(id: 'safe', disks: ['n', 'z', 'nan', 'inf', 'negative',
          'type_unknown', 'ok']),
      ],
      disks: [
        Disks(id: 'a', temp: 42, isSsd: false),
        Disks(id: 'b', temp: 44, isSsd: true),
        Disks(id: 'n', temp: null, isSsd: false),
        Disks(id: 'z', temp: 0, isSsd: true),
        Disks(id: 'nan', temp: double.nan, isSsd: false),
        Disks(id: 'inf', temp: double.infinity, isSsd: false),
        Disks(id: 'negative', temp: -3, isSsd: false),
        Disks(id: 'type_unknown', temp: 36, diskType: 'nvme', isSsd: null),
        Disks(id: 'ok', temp: 39.5, isSsd: true),
      ],
    )));
    expect(find.text('SSD 39.5℃'), findsOneWidget);
    expect(find.textContaining('42℃'), findsNothing);
    expect(find.textContaining('44℃'), findsNothing);
    expect(find.textContaining('36℃'), findsNothing);
    expect(find.textContaining('NaN'), findsNothing);
    expect(find.textContaining('Infinity'), findsNothing);
    expect(find.textContaining('0℃'), findsNothing);
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 15)));

  testWidgets('unique usedBy fallback remains same-pool and missing relation stays empty',
      (tester) async {
    await tester.pumpWidget(host(storage: Storage(
      volumes: [
        Volumes(id: 'volume_1', poolPath: 'same'),
        Volumes(id: 'volume_2', poolPath: 'unmatched'),
      ],
      storagePools: [
        StoragePools(id: 'same'),
      ],
      disks: [
        Disks(id: 'fallback', usedBy: 'same', isSsd: false, temp: 41),
        Disks(id: 'wrong', usedBy: 'other', isSsd: true, temp: 49),
      ],
    )));
    expect(find.text('HDD 41℃'), findsOneWidget);
    expect(find.textContaining('49℃'), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 15)));

  testWidgets('mixed temperatures stay readable at narrow portrait large dark text',
      (tester) async {
    await tester.pumpWidget(host(width: 260, scale: 2.2, dark: true,
      storage: Storage(
        volumes: [Volumes(id: 'volume_1', poolPath: 'p',
            status: 'normal', size: Size(total: 100, used: 50))],
        storagePools: [StoragePools(id: 'p', disks: ['a', 'b', 'c', 'd'])],
        disks: [
          Disks(id: 'a', isSsd: false, temp: 40),
          Disks(id: 'b', isSsd: true, temp: 38),
          Disks(id: 'c', isSsd: false, temp: 42),
          Disks(id: 'd', isSsd: true, temp: 39),
        ],
      ),
    ));
    expect(find.text('HDD 1 40℃'), findsOneWidget);
    expect(find.text('SSD 2 39℃'), findsOneWidget);
    expect(find.text('50.0%'), findsOneWidget);
    expect(find.textContaining('已用'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
