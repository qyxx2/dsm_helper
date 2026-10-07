import 'package:dsm_helper/new_ui/legacy/legacy_page_host.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:dsm_helper/providers/system_info_provider.dart';
import 'package:dsm_helper/themes/light.dart' as legacy;
import 'package:dsm_helper/utils/extensions/navigator_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'legacy host resolves registered named routes inside theme provider and Back boundary',
    (tester) async {
      final currentNasSystemInfo = SystemInfoProvider();

      await tester.pumpWidget(
        MaterialApp(
          theme: NewUiTheme.light(),
          home: Builder(
            builder: (outerContext) => Scaffold(
              body: ElevatedButton(
                key: const Key('open-legacy-host'),
                onPressed: () {
                  Navigator.of(outerContext).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: currentNasSystemInfo,
                        child: LegacyPageHost(
                          builder: (context) => Scaffold(
                            body: ElevatedButton(
                              key: const Key('push-legacy-named-route'),
                              onPressed: () =>
                                  context.pushNamed('/control_panel'),
                              child: const Text('legacy-root'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('new-shell-root'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('open-legacy-host')));
      await tester.pumpAndSettle();
      expect(find.text('legacy-root'), findsOneWidget);

      await tester.tap(find.byKey(const Key('push-legacy-named-route')));
      await tester.pumpAndSettle();

      final childTitle = find.text('控制面板');
      expect(childTitle, findsOneWidget);

      final childContext = tester.element(childTitle);
      expect(
        Theme.of(childContext).colorScheme.primary,
        legacy.lightTheme.colorScheme.primary,
      );
      expect(
        childContext.read<SystemInfoProvider>(),
        same(currentNasSystemInfo),
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('控制面板'), findsNothing);
      expect(find.text('legacy-root'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('legacy-root'), findsNothing);
      expect(find.text('new-shell-root'), findsOneWidget);
    },
  );
}
