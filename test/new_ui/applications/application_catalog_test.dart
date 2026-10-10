import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/new_ui/applications/application_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

const control = 'SYNO.SDS.AdminCenter.Application';
const packages = 'SYNO.SDS.PkgManApp.Instance';
const resource = 'SYNO.SDS.ResourceMonitor.Instance';
const storage = 'SYNO.SDS.StorageManager.Instance';

InitDataModel _loaded({
  List<String> valid = const [],
  List<String> fallback = const [],
}) {
  return InitDataModel(
    userSettings: UserSettings(
      desktop: Desktop(
        validAppviewOrder: valid,
        appviewOrder: fallback,
      ),
    ),
  );
}

void main() {
  const catalog = ModernApplicationCatalog();

  test('non-empty valid application order is authoritative', () {
    final snapshot = catalog.build(
      _loaded(
        valid: [storage, control, packages],
        fallback: [resource, packages, control],
      ),
    );

    expect(snapshot.availability, ApplicationCatalogAvailability.available);
    expect(
      snapshot.items.map((item) => item.id).toList(),
      [
        ModernApplicationId.storageManager,
        ModernApplicationId.controlPanel,
        ModernApplicationId.packageCenter,
      ],
    );
  });

  test('empty valid application order falls back to appview order', () {
    final snapshot = catalog.build(
      _loaded(
        valid: const [],
        fallback: [resource, packages, control],
      ),
    );

    expect(snapshot.availability, ApplicationCatalogAvailability.available);
    expect(
      snapshot.items.map((item) => item.id).toList(),
      [
        ModernApplicationId.resourceMonitor,
        ModernApplicationId.packageCenter,
        ModernApplicationId.controlPanel,
      ],
    );
  });

  test('missing InitData source is unavailable rather than loaded empty', () {
    final snapshot = catalog.build(InitDataModel());

    expect(snapshot.availability, ApplicationCatalogAvailability.unavailable);
    expect(snapshot.items, isEmpty);
  });

  test('loaded source with no supported applications is available and empty', () {
    final snapshot = catalog.build(
      _loaded(valid: const ['com.example.unsupported']),
    );

    expect(snapshot.availability, ApplicationCatalogAvailability.available);
    expect(snapshot.items, isEmpty);
  });

  test('unknown DSM IDs are skipped without moving recognized neighbors', () {
    final snapshot = catalog.build(
      _loaded(
        valid: [
          control,
          'com.example.unknown.first',
          storage,
          'com.example.unknown.second',
          resource,
        ],
      ),
    );

    expect(
      snapshot.items.map((item) => item.id).toList(),
      [
        ModernApplicationId.controlPanel,
        ModernApplicationId.storageManager,
        ModernApplicationId.resourceMonitor,
      ],
    );
  });
}
