import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_shortcuts.dart';
import 'package:dsm_helper/pages/common/browser.dart';
import 'package:dsm_helper/pages/docker/container_detail/container_detail.dart';
import 'package:dsm_helper/pages/docker/docker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const pkg = 'SYNO.SDS.PkgManApp.Instance';
const control = 'SYNO.SDS.AdminCenter.Application';
const storage = 'SYNO.SDS.StorageManager.Instance';
const resource = 'SYNO.SDS.ResourceMonitor.Instance';
const docker = 'SYNO.SDS.Docker.Application';
const container = 'SYNO.SDS.ContainerManager.Application';
const detail = 'SYNO.SDS.Docker.ContainerDetail.Instance';

InitDataModel fixture(List<ShortcutItems> shortcuts, List<String> available) =>
    InitDataModel(
      userSettings: UserSettings(
        desktop: Desktop(
          shortcutItems: shortcuts,
          validAppviewOrder: available,
        ),
      ),
    );

ShortcutItems shortcut(String name) => ShortcutItems(className: name);

void main() {
  const catalog = OverviewShortcutCatalog();

  test('filters unsupported/unavailable and preserves DSM shortcut order', () {
    final entries = catalog.build(fixture([
      shortcut('unsupported.application'),
      shortcut(storage),
      shortcut(control),
      shortcut(pkg),
      shortcut(resource),
    ], [storage, control, pkg]));
    expect(entries.map((e) => e.label).toList(),
        ['存储空间管理员', '控制面板', '套件中心']);
    expect(entries.every((e) => e.assetPath.isNotEmpty), isTrue);
    expect(entries.every((e) => e.routeName.isNotEmpty), isTrue);
  });

  test('first four eligible entries only, without frequency sorting', () {
    final entries = catalog.build(fixture([
      shortcut(pkg), shortcut(control), shortcut(storage),
      shortcut(resource), shortcut(docker),
    ], [pkg, control, storage, resource, docker]));
    expect(entries.length, 4);
    expect(entries.map((e) => e.label).toList(),
        ['套件中心', '控制面板', '存储空间管理员', '资源监控']);
  });

  testWidgets('Docker and Container Manager follow actual DSM availability', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    final context = tester.element(find.byType(Scaffold));
    final oldDocker = catalog.build(fixture(
        [shortcut(docker)], [docker])).single;
    final newDocker = catalog.build(fixture(
        [shortcut(docker)], [container])).single;
    expect(oldDocker.routeName, '/docker');
    expect(newDocker.routeName, '/container_manager');
    expect(oldDocker.legacyBuilder(context).runtimeType, Docker);
    expect(newDocker.legacyBuilder(context).runtimeType, Docker);
    expect((oldDocker.legacyBuilder(context) as Docker).isContainer, isNot(true));
    expect((newDocker.legacyBuilder(context) as Docker).isContainer, isTrue);
    expect(catalog.build(fixture([shortcut(docker)], [])), isEmpty);
  });

  testWidgets('URL shortcut preserves exact URL and container name', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    final context = tester.element(find.byType(Scaffold));
    const target = 'http://nas.example:9096/?path=a%2Fb';
    final entries = catalog.build(fixture([
      ShortcutItems(
        className: detail,
        type: 'url',
        url: target,
        param: Param(data: Data(name: 'my-container')),
      ),
    ], [container]));
    expect(entries.single.label, 'my-container');
    expect(entries.single.routeName, '/browser');
    final browser = entries.single.legacyBuilder(context) as Browser;
    expect(browser.url, target);
  });

  testWidgets('named container detail retains exact name rather than URL fallback', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    final context = tester.element(find.byType(Scaffold));
    final entries = catalog.build(fixture([
      ShortcutItems(
        className: detail,
        param: Param(data: Data(name: 'jellyfin')),
      ),
    ], [docker]));
    expect(entries.single.routeName, '/docker_container_detail');
    expect(entries.single.label, 'jellyfin');
    expect(entries.single.legacyBuilder(context), isA<ContainerDetail>());
  });

  test('missing URL/name, empty capability and unknown entries stay excluded', () {
    expect(catalog.build(fixture([
      ShortcutItems(className: detail, type: 'url', url: ''),
      ShortcutItems(className: detail, param: Param(data: Data())),
      shortcut('unknown'),
      shortcut(pkg),
    ], [])), isEmpty);
    expect(catalog.build(InitDataModel()), isEmpty);
  });
}
