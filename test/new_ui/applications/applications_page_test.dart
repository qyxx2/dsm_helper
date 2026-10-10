import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/new_ui/applications/application_favorites_controller.dart';
import 'package:dsm_helper/new_ui/applications/application_favorites_store.dart';
import 'package:dsm_helper/new_ui/applications/applications_page.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:dsm_helper/providers/init_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _control = 'SYNO.SDS.AdminCenter.Application';
const _packages = 'SYNO.SDS.PkgManApp.Instance';
const _storage = 'SYNO.SDS.StorageManager.Instance';
const _resource = 'SYNO.SDS.ResourceMonitor.Instance';
const _log = 'SYNO.SDS.LogCenter.Instance';
const _security = 'SYNO.SDS.SecurityScan.Instance';
const _xunlei = 'SYNO.SDS.XLPan.Application';
const _container = 'SYNO.SDS.ContainerManager.Application';
const _download = 'SYNO.SDS.DownloadStation.Application';

class _MemoryFavoritesStore implements ApplicationFavoritesStore {
  _MemoryFavoritesStore({
    List<String> initial = const <String>[],
    this.failSave = false,
  }) : _ids = List<String>.of(initial);

  List<String> _ids;
  final bool failSave;

  List<String> get ids => List<String>.unmodifiable(_ids);

  @override
  Future<List<String>> load() async => List<String>.of(_ids);

  @override
  Future<void> save(List<String> ids) async {
    if (failSave) {
      throw StateError('synthetic favorites write failure');
    }
    _ids = List<String>.of(ids);
  }
}

InitDataModel _loaded(List<String> ids) {
  final desktop = Desktop(validAppviewOrder: ids);
  return InitDataModel(userSettings: UserSettings(desktop: desktop));
}

Widget _host({
  required InitDataModel initData,
  Brightness brightness = Brightness.light,
  String? connectionStatusText = '离线',
  ApplicationFavoritesStore? favoritesStore,
}) {
  final provider = InitDataProvider()..setInitData(initData);
  return ChangeNotifierProvider<InitDataProvider>.value(
    value: provider,
    child: MaterialApp(
      theme: brightness == Brightness.light
          ? NewUiTheme.light()
          : NewUiTheme.dark(),
      home: ApplicationsPage(
        onOpenNotifications: () {},
        onOpenApplication: (_) {},
        connectionStatusText: connectionStatusText,
        favoritesControllerFactory: () => ApplicationFavoritesController(
          store: favoritesStore ?? _MemoryFavoritesStore(),
        ),
      ),
    ),
  );
}

Finder _allApplicationLabel(String label) => find.descendant(
      of: find.byKey(const Key('all-applications-grid')),
      matching: find.text(label),
    );

Finder _favoriteApplicationLabel(String label) => find.descendant(
      of: find.byKey(const Key('favorite-applications-grid')),
      matching: find.text(label),
    );

void main() {
  testWidgets('Applications app bar shows title connection status and notification action',
      (tester) async {
    await tester.pumpWidget(_host(initData: _loaded(const [_control])));
    await tester.pump();

    expect(find.text('应用'), findsOneWidget);
    expect(find.text('离线'), findsOneWidget);
    expect(find.byKey(const Key('new-ui-notifications')), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('Common precedes All applications and empty Common does not hide catalog',
      (tester) async {
    await tester.pumpWidget(
      _host(initData: _loaded(const [_control, _packages])),
    );
    await tester.pump();

    expect(find.text('常用'), findsOneWidget);
    expect(find.text('暂无常用应用'), findsOneWidget);
    expect(find.text('全部应用'), findsOneWidget);
    expect(find.text('控制中心'), findsOneWidget);
    expect(find.text('套件中心'), findsOneWidget);

    final commonTop = tester.getTopLeft(find.text('常用')).dy;
    final allTop = tester.getTopLeft(find.text('全部应用')).dy;
    expect(commonTop, lessThan(allTop));
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('All applications uses exactly four columns without Cards',
      (tester) async {
    await tester.pumpWidget(
      _host(
        initData: _loaded(
          const [_control, _packages, _storage, _resource],
        ),
      ),
    );
    await tester.pump();

    final grid = tester.widget<GridView>(
      find.byKey(const Key('all-applications-grid')),
    );
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 4);

    expect(
      find.descendant(
        of: find.byKey(const Key('all-applications-grid')),
        matching: find.byType(Card),
      ),
      findsNothing,
    );
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('Launcher labels are limited to two lines',
      (tester) async {
    await tester.pumpWidget(
      _host(initData: _loaded(const [_storage, _resource])),
    );
    await tester.pump();

    final labels = <String>['存储管理器', '资源监控'];
    for (final label in labels) {
      final text = tester.widget<Text>(find.text(label));
      expect(text.maxLines, 2);
      expect(text.overflow, TextOverflow.ellipsis);
    }
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('Loaded empty and unavailable application sources are distinct',
      (tester) async {
    await tester.pumpWidget(
      _host(initData: _loaded(const ['com.example.unsupported'])),
    );
    await tester.pump();

    expect(find.text('没有可用应用'), findsOneWidget);
    expect(find.text('应用数据暂不可用'), findsNothing);

    await tester.pumpWidget(_host(initData: InitDataModel()));
    await tester.pump();

    expect(find.text('应用数据暂不可用'), findsOneWidget);
    expect(find.text('没有可用应用'), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 20)));
  testWidgets('Long press unpinned application offers add to Common',
      (tester) async {
    final store = _MemoryFavoritesStore();
    await tester.pumpWidget(
      _host(
        initData: _loaded(const [_control, _packages]),
        favoritesStore: store,
      ),
    );
    await tester.pump();

    await tester.longPress(_allApplicationLabel('控制中心'));
    await tester.pumpAndSettle();

    expect(find.text('添加到常用'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('Long press pinned application offers removal from Common',
      (tester) async {
    final store = _MemoryFavoritesStore(initial: const ['control_panel']);
    await tester.pumpWidget(
      _host(
        initData: _loaded(const [_control, _packages]),
        favoritesStore: store,
      ),
    );
    await tester.pump();

    await tester.longPress(_allApplicationLabel('控制中心'));
    await tester.pumpAndSettle();

    expect(find.text('从常用移除'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('Favorite limit shows local feedback and leaves Common unchanged',
      (tester) async {
    final store = _MemoryFavoritesStore(initial: const [
      'control_panel',
      'package_center',
      'resource_monitor',
      'storage_manager',
      'log_center',
      'security_advisor',
      'xunlei',
      'container_manager',
    ]);
    await tester.pumpWidget(
      _host(
        initData: _loaded(const [
          _control,
          _packages,
          _resource,
          _storage,
          _log,
          _security,
          _xunlei,
          _container,
          _download,
        ]),
        favoritesStore: store,
      ),
    );
    await tester.pump();

    await tester.ensureVisible(_allApplicationLabel('Download Station'));
    await tester.pumpAndSettle();
    await tester.longPress(_allApplicationLabel('Download Station'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加到常用'));
    await tester.pumpAndSettle();

    expect(find.text('最多可添加 8 个常用应用'), findsOneWidget);
    expect(store.ids, hasLength(8));
    expect(store.ids, isNot(contains('download_station')));
    expect(_favoriteApplicationLabel('Download Station'), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('Favorite write failure shows feedback and retains prior Common',
      (tester) async {
    final store = _MemoryFavoritesStore(
      initial: const ['control_panel'],
      failSave: true,
    );
    await tester.pumpWidget(
      _host(
        initData: _loaded(const [_control, _packages]),
        favoritesStore: store,
      ),
    );
    await tester.pump();

    expect(_favoriteApplicationLabel('控制中心'), findsOneWidget);

    await tester.longPress(_allApplicationLabel('套件中心'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加到常用'));
    await tester.pumpAndSettle();

    expect(find.text('保存常用应用失败'), findsOneWidget);
    expect(store.ids, const ['control_panel']);
    expect(_favoriteApplicationLabel('控制中心'), findsOneWidget);
    expect(_favoriteApplicationLabel('套件中心'), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('Successful favorite mutation updates Common immediately',
      (tester) async {
    final store = _MemoryFavoritesStore();
    await tester.pumpWidget(
      _host(
        initData: _loaded(const [_control, _packages]),
        favoritesStore: store,
      ),
    );
    await tester.pump();

    expect(_favoriteApplicationLabel('控制中心'), findsNothing);

    await tester.longPress(_allApplicationLabel('控制中心'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加到常用'));
    await tester.pumpAndSettle();

    expect(store.ids, const ['control_panel']);
    expect(_favoriteApplicationLabel('控制中心'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 20)));

}
