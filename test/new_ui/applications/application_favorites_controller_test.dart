import 'package:dsm_helper/new_ui/applications/application_catalog.dart';
import 'package:dsm_helper/new_ui/applications/application_favorites_controller.dart';
import 'package:dsm_helper/new_ui/applications/application_favorites_store.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeApplicationFavoritesStore implements ApplicationFavoritesStore {
  FakeApplicationFavoritesStore({
    List<String> initial = const <String>[],
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

ModernApplicationItem item(ModernApplicationId id) => ModernApplicationItem(
      id: id,
      sourcePackageName: 'source-\${id.storageKey}',
      label: id.storageKey,
      assetPath: 'assets/\${id.storageKey}.png',
    );

List<ModernApplicationItem> catalogOf(Iterable<ModernApplicationId> ids) =>
    ids.map(item).toList();

void main() {
  test('load restores the exact raw stored order', () async {
    final store = FakeApplicationFavoritesStore(
      initial: const <String>[
        'future_unknown',
        'storage_manager',
        'control_panel',
        'storage_manager',
      ],
    );
    final controller = ApplicationFavoritesController(store: store);

    await controller.load();

    expect(controller.loaded, isTrue);
    expect(controller.storedIds, const <String>[
      'future_unknown',
      'storage_manager',
      'control_panel',
      'storage_manager',
    ]);
  });

  test('unknown and unavailable stored IDs remain stored but invisible',
      () async {
    final store = FakeApplicationFavoritesStore(
      initial: const <String>[
        'future_unknown',
        'storage_manager',
        'control_panel',
      ],
    );
    final controller = ApplicationFavoritesController(store: store);
    await controller.load();

    final visible = controller.visibleFor(
      catalogOf(const <ModernApplicationId>[
        ModernApplicationId.controlPanel,
      ]),
    );

    expect(visible, const <ModernApplicationId>[
      ModernApplicationId.controlPanel,
    ]);
    expect(controller.storedIds, const <String>[
      'future_unknown',
      'storage_manager',
      'control_panel',
    ]);
    expect(store.writes, isEmpty);
  });

  test('visible projection returns first eight eligible distinct favorites',
      () async {
    final ids = ModernApplicationId.values;
    final store = FakeApplicationFavoritesStore(
      initial: <String>[
        ids[0].storageKey,
        'future_unknown',
        ids[1].storageKey,
        ids[2].storageKey,
        ids[2].storageKey,
        ids[3].storageKey,
        ids[4].storageKey,
        ids[5].storageKey,
        ids[6].storageKey,
        ids[7].storageKey,
        ids[8].storageKey,
      ],
    );
    final controller = ApplicationFavoritesController(store: store);
    await controller.load();

    expect(
      controller.visibleFor(catalogOf(ids)),
      ids.take(8).toList(),
    );
    expect(store.writes, isEmpty);
  });

  test('duplicate pin is unchanged and performs no write', () async {
    final store = FakeApplicationFavoritesStore(
      initial: const <String>['control_panel'],
    );
    final controller = ApplicationFavoritesController(store: store);
    await controller.load();

    final outcome = await controller.pin(
      ModernApplicationId.controlPanel,
      catalog: catalogOf(const <ModernApplicationId>[
        ModernApplicationId.controlPanel,
      ]),
    );

    expect(outcome, FavoriteMutationOutcome.unchanged);
    expect(controller.storedIds, const <String>['control_panel']);
    expect(store.writes, isEmpty);
  });

  test('pin is rejected when eight favorites are currently visible', () async {
    final ids = ModernApplicationId.values;
    final store = FakeApplicationFavoritesStore(
      initial: ids.take(8).map((id) => id.storageKey).toList(),
    );
    final controller = ApplicationFavoritesController(store: store);
    await controller.load();

    final outcome = await controller.pin(
      ids[8],
      catalog: catalogOf(ids),
    );

    expect(outcome, FavoriteMutationOutcome.limitReached);
    expect(
      controller.storedIds,
      ids.take(8).map((id) => id.storageKey).toList(),
    );
    expect(store.writes, isEmpty);
  });

  test('pin with fewer than eight visible appends only target canonical ID',
      () async {
    final store = FakeApplicationFavoritesStore(
      initial: const <String>[
        'future_unknown',
        'control_panel',
        'storage_manager',
      ],
    );
    final controller = ApplicationFavoritesController(store: store);
    await controller.load();

    final outcome = await controller.pin(
      ModernApplicationId.packageCenter,
      catalog: catalogOf(const <ModernApplicationId>[
        ModernApplicationId.controlPanel,
        ModernApplicationId.packageCenter,
      ]),
    );

    expect(outcome, FavoriteMutationOutcome.changed);
    expect(controller.storedIds, const <String>[
      'future_unknown',
      'control_panel',
      'storage_manager',
      'package_center',
    ]);
    expect(store.persisted, controller.storedIds);
    expect(store.writes, hasLength(1));
  });

  test('unpin removes only the selected canonical ID', () async {
    final store = FakeApplicationFavoritesStore(
      initial: const <String>[
        'future_unknown',
        'control_panel',
        'storage_manager',
        'package_center',
      ],
    );
    final controller = ApplicationFavoritesController(store: store);
    await controller.load();

    final outcome =
        await controller.unpin(ModernApplicationId.storageManager);

    expect(outcome, FavoriteMutationOutcome.changed);
    expect(controller.storedIds, const <String>[
      'future_unknown',
      'control_panel',
      'package_center',
    ]);
    expect(store.persisted, controller.storedIds);
  });

  test('failed save leaves stored IDs and listeners unchanged', () async {
    final store = FakeApplicationFavoritesStore(
      initial: const <String>['control_panel'],
    );
    final controller = ApplicationFavoritesController(store: store);
    await controller.load();

    var notifications = 0;
    controller.addListener(() => notifications++);
    store.failSave = true;

    await expectLater(
      controller.pin(
        ModernApplicationId.packageCenter,
        catalog: catalogOf(const <ModernApplicationId>[
          ModernApplicationId.controlPanel,
          ModernApplicationId.packageCenter,
        ]),
      ),
      throwsA(isA<StateError>()),
    );

    expect(controller.storedIds, const <String>['control_panel']);
    expect(notifications, 0);
  });
}
