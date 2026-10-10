import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/new_ui/legacy/legacy_page_host.dart';
import 'package:dsm_helper/new_ui/settings/settings_page.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:dsm_helper/providers/dark_mode.dart';
import 'package:dsm_helper/providers/init_data_provider.dart';
import 'package:dsm_helper/themes/dark.dart' as legacy_dark;
import 'package:dsm_helper/themes/light.dart' as legacy_light;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets('Settings legacy children return to My without account transitions in $brightness',
        (tester) async {
      final initData = InitDataProvider()
        ..setInitData(InitDataModel(
          session: Session(hostname: 'NAS-A', user: 'alice'),
        ));
      final mode = DarkModeProvider(brightness == Brightness.dark ? 1 : 0);
      addTearDown(initData.dispose);
      addTearDown(mode.dispose);
      var accountCalls = 0;
      var logoutCalls = 0;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<InitDataProvider>.value(value: initData),
            ChangeNotifierProvider<DarkModeProvider>.value(value: mode),
          ],
          child: MaterialApp(
            theme: brightness == Brightness.dark
                ? NewUiTheme.dark()
                : NewUiTheme.light(),
            home: Builder(
              builder: (rootContext) {
                void openChild(String label) {
                  Navigator.of(rootContext).push<void>(
                    MaterialPageRoute(
                      builder: (_) => LegacyPageHost(
                        builder: (legacyContext) => Scaffold(
                          appBar: AppBar(title: Text('legacy-$label')),
                          body: Text(
                            'child-$label:${legacyContext.read<InitDataProvider>().initData.session?.hostname}',
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return SettingsPage(
                  onOpenNotifications: () {},
                  onOpenAccountManagement: () => accountCalls++,
                  onLogout: () => logoutCalls++,
                  onOpenUserSettings: () => openChild('user'),
                  onOpenHelperSettings: () => openChild('helper'),
                  onOpenAbout: () => openChild('about'),
                  onOpenLegacySettings: () => openChild('compatibility'),
                );
              },
            ),
          ),
        ),
      );

      for (final entry in [
        ('个人设置', 'user'),
        ('助手设置', 'helper'),
        ('关于', 'about'),
        ('更多现有设置', 'compatibility'),
      ]) {
        final row = find.widgetWithText(ListTile, entry.$1);
        await tester.scrollUntilVisible(
          row, 120, scrollable: find.byType(Scrollable).first,
        );
        await tester.pump();
        await tester.tap(row);
        await tester.pumpAndSettle();

        final childLabel = 'child-${entry.$2}:NAS-A';
        expect(find.text(childLabel), findsOneWidget);
        expect(find.text('legacy-${entry.$2}'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        final theme = Theme.of(tester.element(find.text(childLabel)));
        final expectedTheme = brightness == Brightness.dark
            ? legacy_dark.darkTheme
            : legacy_light.lightTheme;
        expect(theme.colorScheme.primary, expectedTheme.colorScheme.primary);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text(childLabel), findsNothing);
        expect(find.text('我的'), findsOneWidget);
        expect(accountCalls, 0);
        expect(logoutCalls, 0);
      }
    }, timeout: const Timeout(Duration(seconds: 50)));
  }
}
