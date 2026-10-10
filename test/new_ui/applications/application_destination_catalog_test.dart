import 'package:dsm_helper/new_ui/applications/application_catalog.dart';
import 'package:dsm_helper/new_ui/applications/application_destination_catalog.dart';
import 'package:dsm_helper/pages/common/browser.dart';
import 'package:dsm_helper/pages/log_center/log_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const destinations = ModernApplicationDestinationCatalog();

  testWidgets('every canonical application has an explicit destination builder',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final context = tester.element(find.byType(SizedBox));

    for (final id in ModernApplicationId.values) {
      final builder = destinations.builderFor(id);
      expect(builder, isNotNull, reason: 'Missing destination for $id');
      expect(builder!(context), isA<Widget>());
    }
  });

  testWidgets('Log Center resolves to the concrete legacy LogCenter page',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final context = tester.element(find.byType(SizedBox));

    final builder = destinations.builderFor(ModernApplicationId.logCenter);

    expect(builder, isNotNull);
    expect(builder!(context), isA<LogCenter>());
  });

  testWidgets('Xunlei uses the explicit remote-device Browser destination',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final context = tester.element(find.byType(SizedBox));

    final builder = destinations.builderFor(ModernApplicationId.xunlei);

    expect(builder, isNotNull);
    final widget = builder!(context);
    expect(widget, isA<Browser>());
    final browser = widget as Browser;
    expect(browser.title, '迅雷-远程设备');
    expect(browser.url, 'https://pan.xunlei.com/yc/?fromApp=paipai');
  });
}
