import 'package:dsm_helper/new_ui/applications/application_catalog.dart';
import 'package:dsm_helper/new_ui/applications/application_favorites_store.dart';
import 'package:flutter/foundation.dart';

enum FavoriteMutationOutcome {
  changed,
  unchanged,
  limitReached,
}

class ApplicationFavoritesController extends ChangeNotifier {
  ApplicationFavoritesController({
    required ApplicationFavoritesStore store,
  }) : _store = store;

  final ApplicationFavoritesStore _store;
  List<String> _storedIds = const <String>[];
  bool _loaded = false;

  bool get loaded => _loaded;

  List<String> get storedIds => List<String>.unmodifiable(_storedIds);

  bool isPinned(ModernApplicationId id) =>
      _storedIds.contains(id.storageKey);

  Future<void> load() async {
    final loadedIds = await _store.load();
    _storedIds = List<String>.of(loadedIds);
    _loaded = true;
    notifyListeners();
  }

  List<ModernApplicationId> visibleFor(
    List<ModernApplicationItem> catalog,
  ) {
    final available = <ModernApplicationId>{
      for (final item in catalog) item.id,
    };
    final byStorageKey = <String, ModernApplicationId>{
      for (final id in ModernApplicationId.values) id.storageKey: id,
    };

    final visible = <ModernApplicationId>[];
    final seen = <ModernApplicationId>{};

    for (final storedId in _storedIds) {
      final id = byStorageKey[storedId];
      if (id == null || !available.contains(id) || !seen.add(id)) {
        continue;
      }

      visible.add(id);
      if (visible.length == 8) {
        break;
      }
    }

    return List<ModernApplicationId>.unmodifiable(visible);
  }

  Future<FavoriteMutationOutcome> pin(
    ModernApplicationId id, {
    required List<ModernApplicationItem> catalog,
  }) async {
    if (isPinned(id)) {
      return FavoriteMutationOutcome.unchanged;
    }
    if (visibleFor(catalog).length >= 8) {
      return FavoriteMutationOutcome.limitReached;
    }

    final next = List<String>.of(_storedIds)..add(id.storageKey);
    await _persistAndPublish(next);
    return FavoriteMutationOutcome.changed;
  }

  Future<FavoriteMutationOutcome> unpin(
    ModernApplicationId id,
  ) async {
    if (!isPinned(id)) {
      return FavoriteMutationOutcome.unchanged;
    }

    final next = _storedIds
        .where((storedId) => storedId != id.storageKey)
        .toList(growable: false);
    await _persistAndPublish(next);
    return FavoriteMutationOutcome.changed;
  }

  Future<FavoriteMutationOutcome> reorderVisible(
    List<ModernApplicationId> edited, {
    required List<ModernApplicationItem> catalog,
  }) {
    throw UnimplementedError('Implemented in Task 6 Batch 2 Task 2.3.');
  }

  Future<void> _persistAndPublish(List<String> next) async {
    await _store.save(next);
    _storedIds = List<String>.of(next);
    notifyListeners();
  }
}
