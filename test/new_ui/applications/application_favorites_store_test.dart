import 'package:dsm_helper/new_ui/applications/application_favorites_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the frozen application favorites storage key', () {
    expect(
      SpUtilApplicationFavoritesStore.storageKey,
      'modern_ui_application_favorites_v1',
    );
  });

  test('empty persisted value loads as an empty isolated list', () async {
    final backing = <String>[];
    final store = SpUtilApplicationFavoritesStore(
      read: () => backing,
      write: (_) async => true,
    );

    final loaded = await store.load();
    loaded.add('local-only');

    expect(backing, isEmpty);
  });

  test('ordered favorites round-trip without sharing caller list identity',
      () async {
    var backing = <String>[];
    List<String>? writeArgument;
    final store = SpUtilApplicationFavoritesStore(
      read: () => backing,
      write: (ids) async {
        writeArgument = ids;
        backing = List<String>.of(ids);
        return true;
      },
    );

    final source = <String>['storage_manager', 'control_panel', 'log_center'];
    await store.save(source);
    source.add('caller-mutation');

    expect(writeArgument, [
      'storage_manager',
      'control_panel',
      'log_center',
    ]);
    expect(await store.load(), [
      'storage_manager',
      'control_panel',
      'log_center',
    ]);
  });

  test('save throws when persistence reports failure', () async {
    final store = SpUtilApplicationFavoritesStore(
      read: () => const <String>[],
      write: (_) async => false,
    );

    await expectLater(
      store.save(const ['control_panel']),
      throwsA(isA<StateError>()),
    );
  });
}
