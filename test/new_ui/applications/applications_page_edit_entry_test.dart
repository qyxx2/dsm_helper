import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/new_ui/applications/applications_page.dart';
import 'package:dsm_helper/new_ui/applications/application_favorites_controller.dart';
import 'package:dsm_helper/new_ui/applications/application_favorites_store.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:dsm_helper/providers/init_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _Store implements ApplicationFavoritesStore {
  @override
  Future<List<String>> load() async => const [
        'control_panel',
        'package_center',
      ];

  @override
  Future<void> save(List<String> ids) async {}
}

void main() {
  testWidgets('Common section does not expose a persistent edit action',
      (tester) async {
    final provider = InitDataProvider()
      ..setInitData(InitDataModel());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          theme: NewUiTheme.light(),
          home: ApplicationsPage(
            onOpenNotifications: () {},
            onOpenApplication: (_) {},
            favoritesControllerFactory: () =>
                ApplicationFavoritesController(store: _Store()),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('edit-common-applications')), findsNothing);
    expect(find.text('编辑'), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 20)));
}
