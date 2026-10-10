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
  }) async {
    final visible = visibleFor(catalog);
    final visibleSet = visible.toSet();
    final editedSet = edited.toSet();

    if (edited.length != visible.length ||
        editedSet.length != edited.length ||
        editedSet.length != visibleSet.length ||
        !editedSet.containsAll(visibleSet)) {
      throw ArgumentError.value(
        edited,
        'edited',
        'Must contain exactly the current visible favorite membership.',
      );
    }

    if (listEquals(edited, visible)) {
      return FavoriteMutationOutcome.unchanged;
    }

    final visibleKeys = <String>{
      for (final id in visible) id.storageKey,
    };
    final editedKeys = edited.map((id) => id.storageKey).iterator;
    final next = <String>[];

    for (final storedId in _storedIds) {
      if (!visibleKeys.contains(storedId)) {
        next.add(storedId);
        continue;
      }

      if (!editedKeys.moveNext()) {
        throw StateError(
          'Stored visible favorite slots do not match the visible projection.',
        );
      }
      next.add(editedKeys.current);
    }

    if (editedKeys.moveNext()) {
      throw StateError(
        'Stored visible favorite slots do not match the visible projection.',
      );
    }

    await _persistAndPublish(next);
    return FavoriteMutationOutcome.changed;
  }

  Future<void> _persistAndPublish(List<String> next) async {
    await _store.save(next);
    _storedIds = List<String>.of(next);
    notifyListeners();
  }
}
