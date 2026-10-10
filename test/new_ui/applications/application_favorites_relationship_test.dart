import 'dart:async';
import 'dart:io';

import 'package:dsm_helper/new_ui/applications/application_catalog.dart';
import 'package:dsm_helper/new_ui/applications/application_favorites_controller.dart';
import 'package:dsm_helper/new_ui/applications/application_favorites_store.dart';
import 'package:flutter_test/flutter_test.dart';

class RelationshipFavoritesStore implements ApplicationFavoritesStore {
  RelationshipFavoritesStore({
    required List<String> initial,
    this.failSave = false,
  }) : persisted = List<String>.of(initial);

  List<String> persisted;
  bool failSave;
  final List<List<String>> writes = <List<String>>[];

  @override
  Future<List<String>> load() async => List<String>.of(persisted);

  @override
  Future<void> save(List<String> ids) async {
    writes.add(List<String>.of(ids));
    if (failSave) {
      throw StateError('save failed');
    }
    persisted = List<String>.of(ids);
  }
}

class BlockingRelationshipFavoritesStore
    implements ApplicationFavoritesStore {
  BlockingRelationshipFavoritesStore({
    List<String> initial = const <String>[],
  }) : persisted = List<String>.of(initial);

  List<String> persisted;
  final List<List<String>> writes = <List<String>>[];
  final Completer<void> firstSaveStarted = Completer<void>();
  final Completer<void> releaseFirstSave = Completer<void>();

  @override
  Future<List<String>> load() async => List<String>.of(persisted);

  @override
  Future<void> save(List<String> ids) async {
    writes.add(List<String>.of(ids));
    if (writes.length == 1) {
      firstSaveStarted.complete();
      await releaseFirstSave.future;
    }
    persisted = List<String>.of(ids);
  }
}

ModernApplicationItem relationshipItem(ModernApplicationId id) =>
    ModernApplicationItem(
      id: id,
      sourcePackageName: id.storageKey,
      label: id.storageKey,
      assetPath: 'asset',
    );

List<ModernApplicationItem> relationshipCatalog(
  Iterable<ModernApplicationId> ids,
) =>
    ids.map(relationshipItem).toList();

void main() {
  test('reorder replaces only current visible slots and preserves hidden data',
      () async {
    final original = <String>[
      'control_panel',
      'future_unknown',
      'package_center',
      'storage_manager',
      'resource_monitor',
      'log_center',
      'security_advisor',
      'xunlei',
      'container_manager',
      'download_station',
      'moments',
      'photos',
    ];
    final store = RelationshipFavoritesStore(initial: original);
    final controller = ApplicationFavoritesController(store: store);
    await controller.load();

    final catalog = relationshipCatalog(const <ModernApplicationId>[
      ModernApplicationId.controlPanel,
      ModernApplicationId.packageCenter,
      ModernApplicationId.resourceMonitor,
      ModernApplicationId.logCenter,
      ModernApplicationId.securityAdvisor,
      ModernApplicationId.xunlei,
      ModernApplicationId.containerManager,
      ModernApplicationId.downloadStation,
      ModernApplicationId.moments,
      ModernApplicationId.photos,
    ]);

    expect(
      controller.visibleFor(catalog),
      const <ModernApplicationId>[
        ModernApplicationId.controlPanel,
        ModernApplicationId.packageCenter,
        ModernApplicationId.resourceMonitor,
        ModernApplicationId.logCenter,
        ModernApplicationId.securityAdvisor,
        ModernApplicationId.xunlei,
        ModernApplicationId.containerManager,
        ModernApplicationId.downloadStation,
      ],
    );

    final outcome = await controller.reorderVisible(
      const <ModernApplicationId>[
        ModernApplicationId.downloadStation,
        ModernApplicationId.containerManager,
        ModernApplicationId.xunlei,
        ModernApplicationId.securityAdvisor,
        ModernApplicationId.logCenter,
        ModernApplicationId.resourceMonitor,
        ModernApplicationId.packageCenter,
        ModernApplicationId.controlPanel,
      ],
      catalog: catalog,
    );

    expect(outcome, FavoriteMutationOutcome.changed);
    expect(controller.storedIds, const <String>[
      'download_station',
      'future_unknown',
      'container_manager',
      'storage_manager',
      'xunlei',
      'security_advisor',
      'log_center',
      'resource_monitor',
      'package_center',
      'control_panel',
      'moments',
      'photos',
    ]);
    expect(store.persisted, controller.storedIds);
    expect(store.writes, hasLength(1));
  });

  test('reorder rejects changed membership without writing or publishing',
      () async {
    final original = <String>[
      'control_panel',
      'future_unknown',
      'package_center',
      'storage_manager',
      'resource_monitor',
    ];
    final store = RelationshipFavoritesStore(initial: original);
    final controller = ApplicationFavoritesController(store: store);
    await controller.load();

    var notifications = 0;
    controller.addListener(() => notifications++);

    final catalog = relationshipCatalog(const <ModernApplicationId>[
      ModernApplicationId.controlPanel,
      ModernApplicationId.packageCenter,
      ModernApplicationId.resourceMonitor,
    ]);

    await expectLater(
      controller.reorderVisible(
        const <ModernApplicationId>[
          ModernApplicationId.packageCenter,
          ModernApplicationId.controlPanel,
          ModernApplicationId.logCenter,
        ],
        catalog: catalog,
      ),
      throwsArgumentError,
    );

    expect(controller.storedIds, original);
    expect(store.persisted, original);
    expect(store.writes, isEmpty);
    expect(notifications, 0);
  });

  test('failed reorder persistence retains prior state and publishes nothing',
      () async {
    final original = <String>[
      'control_panel',
      'future_unknown',
      'package_center',
      'storage_manager',
      'resource_monitor',
    ];
    final store = RelationshipFavoritesStore(
      initial: original,
      failSave: true,
    );
    final controller = ApplicationFavoritesController(store: store);
    await controller.load();

    var notifications = 0;
    controller.addListener(() => notifications++);

    final catalog = relationshipCatalog(const <ModernApplicationId>[
      ModernApplicationId.controlPanel,
      ModernApplicationId.packageCenter,
      ModernApplicationId.resourceMonitor,
    ]);

    await expectLater(
      controller.reorderVisible(
        const <ModernApplicationId>[
          ModernApplicationId.resourceMonitor,
          ModernApplicationId.packageCenter,
          ModernApplicationId.controlPanel,
        ],
        catalog: catalog,
      ),
      throwsA(isA<StateError>()),
    );

    expect(controller.storedIds, original);
    expect(store.persisted, original);
    expect(store.writes, hasLength(1));
    expect(notifications, 0);
  });

  test('favorites authority is independent from DSM and Task 5 shortcut writes',
      () {
    final controllerSource = File(
      'lib/new_ui/applications/application_favorites_controller.dart',
    ).readAsStringSync();
    final storeSource = File(
      'lib/new_ui/applications/application_favorites_store.dart',
    ).readAsStringSync();
    final combined = '$controllerSource\n$storeSource';

    for (final forbidden in const <String>[
      'UserSettings.apply',
      'showShortcut',
      'shortcutItems',
      'validAppviewOrder',
      'appviewOrder',
      'models/Syno/Core/Desktop',
      'overview_shortcuts',
    ]) {
      expect(combined, isNot(contains(forbidden)), reason: forbidden);
    }
  });

  test('catalog context projection never rewrites the global stored list',
      () async {
    final original = <String>[
      'future_unknown',
      'control_panel',
      'storage_manager',
      'package_center',
      'photos',
    ];
    final store = RelationshipFavoritesStore(initial: original);
    final controller = ApplicationFavoritesController(store: store);
    await controller.load();

    final contextA = relationshipCatalog(const <ModernApplicationId>[
      ModernApplicationId.controlPanel,
      ModernApplicationId.packageCenter,
    ]);
    final contextB = relationshipCatalog(const <ModernApplicationId>[
      ModernApplicationId.storageManager,
      ModernApplicationId.photos,
    ]);

    expect(
      controller.visibleFor(contextA),
      const <ModernApplicationId>[
        ModernApplicationId.controlPanel,
        ModernApplicationId.packageCenter,
      ],
    );
    expect(
      controller.visibleFor(contextB),
      const <ModernApplicationId>[
        ModernApplicationId.storageManager,
        ModernApplicationId.photos,
      ],
    );
    expect(controller.storedIds, original);
    expect(store.persisted, original);
    expect(store.writes, isEmpty);
  });

  test('rapid duplicate pin publishes one change and performs one write',
      () async {
    final store = BlockingRelationshipFavoritesStore(
      initial: const <String>['control_panel'],
    );
    final controller = ApplicationFavoritesController(store: store);
    await controller.load();

    var notifications = 0;
    controller.addListener(() => notifications++);
    final catalog = relationshipCatalog(const <ModernApplicationId>[
      ModernApplicationId.controlPanel,
      ModernApplicationId.packageCenter,
    ]);

    final first = controller.pin(
      ModernApplicationId.packageCenter,
      catalog: catalog,
    );
    await store.firstSaveStarted.future;

    final second = controller.pin(
      ModernApplicationId.packageCenter,
      catalog: catalog,
    );
    await Future<void>.delayed(Duration.zero);
    final writesBeforeRelease = store.writes.length;
    store.releaseFirstSave.complete();

    final outcomes = await Future.wait(<Future<FavoriteMutationOutcome>>[
      first,
      second,
    ]);

    expect(writesBeforeRelease, 1);
    expect(outcomes, const <FavoriteMutationOutcome>[
      FavoriteMutationOutcome.changed,
      FavoriteMutationOutcome.unchanged,
    ]);
    expect(controller.storedIds, const <String>[
      'control_panel',
      'package_center',
    ]);
    expect(store.writes, hasLength(1));
    expect(notifications, 1);
  });

  test('rapid pin then unpin is applied in invocation order', () async {
    final store = BlockingRelationshipFavoritesStore(
      initial: const <String>['control_panel'],
    );
    final controller = ApplicationFavoritesController(store: store);
    await controller.load();

    var notifications = 0;
    controller.addListener(() => notifications++);
    final catalog = relationshipCatalog(const <ModernApplicationId>[
      ModernApplicationId.controlPanel,
      ModernApplicationId.packageCenter,
    ]);

    final pin = controller.pin(
      ModernApplicationId.packageCenter,
      catalog: catalog,
    );
    await store.firstSaveStarted.future;

    final unpin = controller.unpin(ModernApplicationId.packageCenter);
    await Future<void>.delayed(Duration.zero);
    store.releaseFirstSave.complete();

    final outcomes = await Future.wait(<Future<FavoriteMutationOutcome>>[
      pin,
      unpin,
    ]);

    expect(outcomes, const <FavoriteMutationOutcome>[
      FavoriteMutationOutcome.changed,
      FavoriteMutationOutcome.changed,
    ]);
    expect(controller.storedIds, const <String>['control_panel']);
    expect(store.persisted, controller.storedIds);
    expect(store.writes, hasLength(2));
    expect(notifications, 2);
  });
}
