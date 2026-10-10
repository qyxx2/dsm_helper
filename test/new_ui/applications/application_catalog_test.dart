import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/new_ui/applications/application_catalog.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';

const control = 'SYNO.SDS.AdminCenter.Application';
const packages = 'SYNO.SDS.PkgManApp.Instance';
const resource = 'SYNO.SDS.ResourceMonitor.Instance';
const storage = 'SYNO.SDS.StorageManager.Instance';
const logInstance = 'SYNO.SDS.LogCenter.Instance';
const logBuiltIn = 'SYNO.SDS.LogCenter.BuiltIn';
const security = 'SYNO.SDS.SecurityScan.Instance';
const xunlei = 'SYNO.SDS.XLPan.Application';
const docker = 'SYNO.SDS.Docker.Application';
const containerManager = 'SYNO.SDS.ContainerManager.Application';
const downloadStation = 'SYNO.SDS.DownloadStation.Application';
const moments = 'SYNO.Photo.AppInstance';
const photos = 'SYNO.Foto.AppInstance';
const virtualMachine = 'SYNO.SDS.Virtualization.Application';

InitDataModel _loaded({
  List<String> valid = const [],
  List<String> fallback = const [],
}) {
  final desktop = Desktop(validAppviewOrder: valid)
    ..appviewOrder = fallback;
  return InitDataModel(
    userSettings: UserSettings(desktop: desktop),
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

  test('Log Center aliases canonicalize to one launcher item', () {
    final snapshot = catalog.build(
      _loaded(valid: [logInstance, logBuiltIn]),
    );

    expect(
      snapshot.items.map((item) => item.id).toList(),
      [ModernApplicationId.logCenter],
    );
  });

  test('Docker and Container Manager aliases canonicalize to one product', () {
    final snapshot = catalog.build(
      _loaded(valid: [docker, containerManager]),
    );

    expect(
      snapshot.items.map((item) => item.id).toList(),
      [ModernApplicationId.containerManager],
    );
  });

  test('first alias occurrence defines the canonical product position', () {
    final snapshot = catalog.build(
      _loaded(valid: [docker, storage, containerManager, control]),
    );

    expect(
      snapshot.items.map((item) => item.id).toList(),
      [
        ModernApplicationId.containerManager,
        ModernApplicationId.storageManager,
        ModernApplicationId.controlPanel,
      ],
    );
  });

  test('Container Manager presentation wins when that package is available', () {
    final snapshot = catalog.build(
      _loaded(valid: [docker, containerManager]),
    );

    expect(snapshot.items, hasLength(1));
    expect(snapshot.items.single.id, ModernApplicationId.containerManager);
    expect(snapshot.items.single.sourcePackageName, containerManager);
    expect(snapshot.items.single.label, 'Container Manager');
    expect(
      snapshot.items.single.assetPath,
      'assets/applications/container_manager.png',
    );
  });

  test('canonicalization preserves neighboring supported DSM order', () {
    final snapshot = catalog.build(
      _loaded(
        valid: [resource, docker, storage, containerManager, control],
      ),
    );

    expect(
      snapshot.items.map((item) => item.id).toList(),
      [
        ModernApplicationId.resourceMonitor,
        ModernApplicationId.containerManager,
        ModernApplicationId.storageManager,
        ModernApplicationId.controlPanel,
      ],
    );
  });

  test('all remaining supported one-to-one DSM applications resolve', () {
    final snapshot = catalog.build(
      _loaded(
        valid: [
          security,
          xunlei,
          downloadStation,
          moments,
          photos,
          virtualMachine,
        ],
      ),
    );

    expect(
      snapshot.items.map((item) => item.id).toList(),
      [
        ModernApplicationId.securityAdvisor,
        ModernApplicationId.xunlei,
        ModernApplicationId.downloadStation,
        ModernApplicationId.moments,
        ModernApplicationId.photos,
        ModernApplicationId.virtualMachineManager,
      ],
    );
  });

  test('versioned legacy application assets follow the active DSM version', () {
    final previousVersion = Utils.version;
    addTearDown(() => Utils.version = previousVersion);
    Utils.version = 6;

    final snapshot = catalog.build(_loaded(valid: [control]));

    expect(snapshot.items.single.assetPath, 'assets/applications/6/control_panel.png');
  });
}
