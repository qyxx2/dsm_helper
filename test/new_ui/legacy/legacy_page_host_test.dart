import 'package:dsm_helper/new_ui/legacy/legacy_page_host.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LegacyPageHost isolates legacy light theme from the New UI theme',
      (tester) async {
    const shellKey = Key('shell-probe');
    const legacyKey = Key('legacy-probe');

    await tester.pumpWidget(
      MaterialApp(
        theme: NewUiTheme.light(),
        home: Scaffold(
          body: Column(
            children: [
              const SizedBox(key: shellKey),
              LegacyPageHost(
                brightness: Brightness.light,
                child: const SizedBox(key: legacyKey),
              ),
            ],
          ),
        ),
      ),
    );

    final shellTheme = Theme.of(tester.element(find.byKey(shellKey)));
    final legacyTheme = Theme.of(tester.element(find.byKey(legacyKey)));

    expect(shellTheme.colorScheme.primary, const Color(0xFF00A6FF));
    expect(legacyTheme.colorScheme.primary, Colors.black);
    expect(
      legacyTheme.extension<AppTheme>()?.primaryColor,
      const Color(0xFF2A82E4),
    );
    expect(shellTheme.extension<AppTheme>(), isNull);
  });

  testWidgets('LegacyPageHost selects the legacy dark theme explicitly',
      (tester) async {
    const legacyKey = Key('legacy-dark-probe');

    await tester.pumpWidget(
      MaterialApp(
        theme: NewUiTheme.light(),
        home: LegacyPageHost(
          brightness: Brightness.dark,
          child: const SizedBox(key: legacyKey),
        ),
      ),
    );

    final legacyTheme = Theme.of(tester.element(find.byKey(legacyKey)));

    expect(legacyTheme.brightness, Brightness.dark);
    expect(legacyTheme.scaffoldBackgroundColor, const Color(0xFF121212));
    expect(
      legacyTheme.extension<AppTheme>()?.primaryColor,
      const Color(0xFF2A82E4),
    );
  });

  testWidgets('host lets nested legacy navigation consume Back before route exit',
      (tester) async {
    final nestedKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => FilledButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LegacyPageHost(
                    onBackAttempt: () async {
                      final navigator = nestedKey.currentState;
                      if (navigator != null && navigator.canPop()) {
                        navigator.pop();
                        return true;
                      }
                      return false;
                    },
                    child: Navigator(
                      key: nestedKey,
                      onGenerateRoute: (_) => MaterialPageRoute<void>(
                        builder: (context) => Scaffold(
                          body: FilledButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const Scaffold(body: Text('legacy-child')),
                                ),
                              );
                            },
                            child: const Text('legacy-root'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: const Text('open-host'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-host'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('legacy-root'));
    await tester.pumpAndSettle();
    expect(find.text('legacy-child'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('legacy-root'), findsOneWidget);
    expect(find.text('open-host'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('open-host'), findsOneWidget);
  });
}
