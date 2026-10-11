import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/new_ui/applications/application_favorites_controller.dart';
import 'package:dsm_helper/new_ui/applications/application_favorites_store.dart';
import 'package:dsm_helper/new_ui/applications/applications_page.dart';
import 'package:dsm_helper/new_ui/applications/edit_application_favorites_page.dart';
import 'package:dsm_helper/new_ui/settings/settings_page.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:dsm_helper/providers/dark_mode.dart';
import 'package:dsm_helper/providers/init_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _Favorites implements ApplicationFavoritesStore {
  @override
  Future<List<String>> load() async =>
      <String>['control_panel', 'package_center'];

  @override
  Future<void> save(List<String> ids) async {}
}

InitDataModel _catalog() => InitDataModel.fromJson({
      'Session': {'majorversion': '7'},
      'UserSettings': {
        'Desktop': {
          'valid_appview_order': [
            'SYNO.SDS.AdminCenter.Application',
            'SYNO.SDS.PkgManApp.Instance',
            'SYNO.SDS.StorageManager.Instance',
          ],
        },
      },
    });

Widget _appHost(Brightness brightness) {
  final init = InitDataProvider()..setInitData(_catalog());
  return ChangeNotifierProvider<InitDataProvider>.value(
    value: init,
    child: MaterialApp(
      theme: brightness == Brightness.dark
          ? NewUiTheme.dark()
          : NewUiTheme.light(),
      home: ApplicationsPage(
        onOpenNotifications: () {},
        onOpenApplication: (_) {},
        favoritesControllerFactory: () =>
            ApplicationFavoritesController(store: _Favorites()),
      ),
    ),
  );
}

Widget _settingsHost(Brightness brightness, List<String> events) {
  final init = InitDataProvider()
    ..setInitData(InitDataModel(
      session: Session(hostname: 'NAS-A', user: 'alice'),
    ));
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<InitDataProvider>.value(value: init),
      ChangeNotifierProvider(create: (_) =>
          DarkModeProvider(brightness == Brightness.dark ? 1 : 0)),
    ],
    child: MaterialApp(
      theme: brightness == Brightness.dark
          ? NewUiTheme.dark()
          : NewUiTheme.light(),
      home: SettingsPage(
        onOpenNotifications: () {},
        onOpenAccountManagement: () => events.add('accounts'),
        onLogout: () => events.add('logout'),
        onOpenUserSettings: () => events.add('user'),
        onOpenHelperSettings: () => events.add('helper'),
        onOpenAbout: () => events.add('about'),
        onOpenLegacySettings: () => events.add('legacy'),
      ),
    ),
  );
}

void main() {
  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets('B5 visual correction: no persistent edit; Common long press retains reorder in $brightness',
        (tester) async {
      await tester.pumpWidget(_appHost(brightness));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('edit-common-applications')), findsNothing);
      expect(find.text('编辑'), findsNothing);

      final common = find.byKey(const Key('favorite-applications-grid'));
      await tester.longPress(find.descendant(
        of: common, matching: find.text('控制中心'),
      ));
      await tester.pumpAndSettle();

      final bottomSheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
      final expectedSurface = brightness == Brightness.dark
          ? NewUiTheme.dark().navigationBarTheme.backgroundColor
          : NewUiTheme.light().navigationBarTheme.backgroundColor;
      expect(bottomSheet.backgroundColor, expectedSurface);
      expect(find.text('调整常用顺序'), findsOneWidget);
      await tester.tap(find.text('调整常用顺序'));
      await tester.pumpAndSettle();
      expect(find.byType(EditApplicationFavoritesPage), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 35)));

    testWidgets('B5 visual correction: adding favorite sheet matches nav color in $brightness',
        (tester) async {
      await tester.pumpWidget(_appHost(brightness));
      await tester.pumpAndSettle();

      final all = find.byKey(const Key('all-applications-grid'));
      await tester.longPress(find.descendant(
        of: all, matching: find.text('存储管理器'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('添加到常用'), findsOneWidget);

      final bottomSheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
      expect(
        bottomSheet.backgroundColor,
        brightness == Brightness.dark
            ? NewUiTheme.dark().navigationBarTheme.backgroundColor
            : NewUiTheme.light().navigationBarTheme.backgroundColor,
      );
    }, timeout: const Timeout(Duration(seconds: 35)));

    testWidgets('B5 visual correction: My uses compact device card, icon actions and uniform ungrouped rows in $brightness',
        (tester) async {
      final events = <String>[];
      await tester.pumpWidget(_settingsHost(brightness, events));
      await tester.pumpAndSettle();

      expect(find.text('当前设备与账号'), findsNothing);
      expect(find.text('外观'), findsNothing);
      expect(find.text('应用设置'), findsNothing);
      final card = find.byKey(const Key('current-device-account-card'));
      expect(card, findsOneWidget);
      expect(tester.getSize(card).height, lessThanOrEqualTo(120));
      expect(find.text('NAS-A'), findsOneWidget);
      expect(find.text('alice'), findsOneWidget);
      expect(find.byTooltip('个人设置'), findsOneWidget);
      expect(find.byTooltip('退出登录'), findsOneWidget);

      for (final label in [
        '服务器与账号管理', '主题模式', '助手设置',
        '更多现有设置', '关于',
      ]) {
        final row = tester.widget<ListTile>(find.widgetWithText(ListTile, label));
        expect(row.leading, isNull);
      }

      await tester.tap(find.byTooltip('个人设置'));
      await tester.tap(find.byTooltip('退出登录'));
      await tester.tap(find.text('服务器与账号管理'));
      expect(events, ['user', 'logout', 'accounts']);
    }, timeout: const Timeout(Duration(seconds: 35)));
  }
}
