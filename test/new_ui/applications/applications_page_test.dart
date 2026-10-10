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

class _MemoryFavoritesStore implements ApplicationFavoritesStore {
  _MemoryFavoritesStore([List<String> initial = const <String>[]])
      : _ids = List<String>.of(initial);

  List<String> _ids;

  @override
  Future<List<String>> load() async => List<String>.of(_ids);

  @override
  Future<void> save(List<String> ids) async {
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
          store: _MemoryFavoritesStore(),
        ),
      ),
    ),
  );
}

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
}
