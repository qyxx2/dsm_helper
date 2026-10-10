import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/new_ui/applications/application_catalog.dart';
import 'package:dsm_helper/new_ui/applications/application_favorites_controller.dart';
import 'package:dsm_helper/new_ui/applications/application_favorites_store.dart';
import 'package:dsm_helper/new_ui/applications/edit_application_favorites_page.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _control = 'SYNO.SDS.AdminCenter.Application';
const _packages = 'SYNO.SDS.PkgManApp.Instance';

class _MemoryFavoritesStore implements ApplicationFavoritesStore {
  _MemoryFavoritesStore({
    required List<String> initial,
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
      throw StateError('synthetic reorder persistence failure');
    }
    _ids = List<String>.of(ids);
  }
}

List<ModernApplicationItem> _catalogItems() {
  final desktop = Desktop(validAppviewOrder: const [_control, _packages]);
  final initData = InitDataModel(
    userSettings: UserSettings(desktop: desktop),
  );
  return const ModernApplicationCatalog().build(initData).items;
}

Future<ApplicationFavoritesController> _controller(
  _MemoryFavoritesStore store,
) async {
  final controller = ApplicationFavoritesController(store: store);
  await controller.load();
  return controller;
}

Widget _host({
  required ApplicationFavoritesController controller,
  required List<ModernApplicationItem> catalogItems,
}) {
  return MaterialApp(
    theme: NewUiTheme.light(),
    home: EditApplicationFavoritesPage(
      controller: controller,
      catalogItems: catalogItems,
    ),
  );
}

void main() {
  testWidgets('Edit favorites uses ReorderableListView and hides unavailable IDs',
      (tester) async {
    final store = _MemoryFavoritesStore(
      initial: const ['control_panel', 'photos', 'package_center'],
    );
    final controller = await _controller(store);
    final catalogItems = _catalogItems();

    await tester.pumpWidget(
      _host(controller: controller, catalogItems: catalogItems),
    );
    await tester.pump();

    expect(find.byType(ReorderableListView), findsOneWidget);
    expect(find.text('控制中心'), findsOneWidget);
    expect(find.text('套件中心'), findsOneWidget);
    expect(find.text('Synology Photos'), findsNothing);

    controller.dispose();
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('Reorder persists displayed IDs through preservation merge',
      (tester) async {
    final store = _MemoryFavoritesStore(
      initial: const ['control_panel', 'photos', 'package_center'],
    );
    final controller = await _controller(store);
    final catalogItems = _catalogItems();

    await tester.pumpWidget(
      _host(controller: controller, catalogItems: catalogItems),
    );
    await tester.pump();

    final list = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    list.onReorder(0, 2);
    await tester.pumpAndSettle();

    expect(
      store.ids,
      const ['package_center', 'photos', 'control_panel'],
    );
    expect(
      controller.visibleFor(catalogItems),
      const [ModernApplicationId.packageCenter, ModernApplicationId.controlPanel],
    );

    controller.dispose();
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('Failed reorder keeps editor order consistent with controller',
      (tester) async {
    final store = _MemoryFavoritesStore(
      initial: const ['control_panel', 'package_center'],
      failSave: true,
    );
    final controller = await _controller(store);
    final catalogItems = _catalogItems();

    await tester.pumpWidget(
      _host(controller: controller, catalogItems: catalogItems),
    );
    await tester.pump();

    final list = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    list.onReorder(0, 2);
    await tester.pumpAndSettle();

    expect(find.text('保存常用应用失败'), findsOneWidget);
    expect(store.ids, const ['control_panel', 'package_center']);
    expect(
      controller.visibleFor(catalogItems),
      const [ModernApplicationId.controlPanel, ModernApplicationId.packageCenter],
    );
    expect(
      tester.getTopLeft(find.text('控制中心')).dy,
      lessThan(tester.getTopLeft(find.text('套件中心')).dy),
    );

    controller.dispose();
  }, timeout: const Timeout(Duration(seconds: 20)));
}
