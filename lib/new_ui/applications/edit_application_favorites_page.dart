import 'dart:async';

import 'package:dsm_helper/new_ui/applications/application_catalog.dart';
import 'package:dsm_helper/new_ui/applications/application_favorites_controller.dart';
import 'package:flutter/material.dart';

class EditApplicationFavoritesPage extends StatelessWidget {
  const EditApplicationFavoritesPage({
    super.key,
    required this.controller,
    required this.catalogItems,
  });

  final ApplicationFavoritesController controller;
  final List<ModernApplicationItem> catalogItems;

  Future<void> _reorder(
    BuildContext context,
    List<ModernApplicationId> visible,
    int oldIndex,
    int newIndex,
  ) async {
    var targetIndex = newIndex;
    if (targetIndex > oldIndex) {
      targetIndex -= 1;
    }

    final edited = List<ModernApplicationId>.of(visible);
    final moved = edited.removeAt(oldIndex);
    edited.insert(targetIndex, moved);

    try {
      await controller.reorderVisible(
        edited,
        catalog: catalogItems,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('保存常用应用失败'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final visible = controller.visibleFor(catalogItems);
        final byId = <ModernApplicationId, ModernApplicationItem>{
          for (final item in catalogItems) item.id: item,
        };

        return Scaffold(
          appBar: AppBar(
            title: const Text('编辑常用'),
          ),
          body: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            buildDefaultDragHandles: false,
            itemCount: visible.length,
            onReorder: (oldIndex, newIndex) {
              unawaited(
                _reorder(
                  context,
                  visible,
                  oldIndex,
                  newIndex,
                ),
              );
            },
            itemBuilder: (context, index) {
              final id = visible[index];
              final item = byId[id]!;
              return ListTile(
                key: ValueKey('favorite-edit-${id.storageKey}'),
                leading: SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.asset(
                    item.assetPath,
                    fit: BoxFit.contain,
                  ),
                ),
                title: Text(item.label),
                trailing: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
