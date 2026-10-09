import 'package:flutter/foundation.dart';

import 'overview_widget_config.dart';

typedef OverviewWidgetModuleSaver = Future<bool?> Function(
  List<String> moduleIds,
);

/// Edits only Task 5 extension IDs. DSM is not updated until [save] succeeds.
class OverviewWidgetConfigController extends ChangeNotifier {
  OverviewWidgetConfigController({
    required List<String> originalModuleIds,
    required OverviewWidgetModuleSaver saveModuleIds,
  })  : _originalModuleIds = List<String>.of(originalModuleIds),
        _saveModuleIds = saveModuleIds,
        _selectedOwnedIds = [
          for (final id in originalModuleIds)
            if (task5OwnedOverviewWidgetIds.contains(id)) id,
        ].toSet().toList();

  List<String> _originalModuleIds;
  final OverviewWidgetModuleSaver _saveModuleIds;
  final List<String> _selectedOwnedIds;
  bool _saving = false;
  bool _disposed = false;
  Object? _error;

  List<String> get selectedOwnedIds => List.unmodifiable(_selectedOwnedIds);
  bool get saving => _saving;
  Object? get error => _error;

  void setVisible(String moduleId, bool visible) {
    if (_saving ||
        _disposed ||
        !task5OwnedOverviewWidgetIds.contains(moduleId)) {
      return;
    }
    final isSelected = _selectedOwnedIds.contains(moduleId);
    if (isSelected == visible) return;
    if (visible) {
      _selectedOwnedIds.add(moduleId);
    } else {
      _selectedOwnedIds.remove(moduleId);
    }
    _error = null;
    notifyListeners();
  }

  /// Uses Flutter's ReorderableListView old/new index convention.
  void reorder(int oldIndex, int newIndex) {
    if (_saving ||
        _disposed ||
        oldIndex < 0 ||
        oldIndex >= _selectedOwnedIds.length ||
        newIndex < 0 ||
        newIndex > _selectedOwnedIds.length) {
      return;
    }
    if (oldIndex < newIndex) newIndex--;
    if (oldIndex == newIndex) return;
    final id = _selectedOwnedIds.removeAt(oldIndex);
    _selectedOwnedIds.insert(newIndex, id);
    _error = null;
    notifyListeners();
  }

  Future<List<String>?> save() async {
    if (_saving || _disposed) return null;
    _saving = true;
    _error = null;
    notifyListeners();

    final merged = mergeTask5OverviewModuleIds(
      originalModuleIds: _originalModuleIds,
      editedOwnedIds: _selectedOwnedIds,
    );
    try {
      final success = await _saveModuleIds(List.unmodifiable(merged));
      if (_disposed) return null;
      if (success != true) {
        _error = StateError('DSM widget configuration save failed');
        return null;
      }
      _originalModuleIds = List<String>.of(merged);
      return List<String>.of(merged);
    } catch (error) {
      if (!_disposed) _error = error;
      return null;
    } finally {
      if (!_disposed) {
        _saving = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
