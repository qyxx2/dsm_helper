import 'package:dsm_helper/new_ui/dashboard/overview_widget_config.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_widget_config_controller.dart';
import 'package:flutter/material.dart';

/// Only Task 5-owned DSM extensions can be edited on this page.
class EditOverviewPage extends StatefulWidget {
  const EditOverviewPage({super.key, required this.controller});

  final OverviewWidgetConfigController controller;

  @override
  State<EditOverviewPage> createState() => _EditOverviewPageState();
}

class _EditOverviewPageState extends State<EditOverviewPage> {
  static const _labels = <String, String>{
    'SYNO.SDS.SystemInfoApp.ConnectionLogWidget': '当前连接',
    'SYNO.SDS.TaskScheduler.TaskSchedulerWidget': '计划任务',
  };

  Future<void> _save() async {
    final saved = await widget.controller.save();
    if (!mounted || saved == null) return;
    Navigator.of(context).pop(saved);
  }

  Widget _row(String id, {required bool selected, int? index}) {
    return SwitchListTile(
      key: ValueKey('overview-visible-$id'),
      title: Text(_labels[id] ?? id),
      value: selected,
      onChanged: widget.controller.saving
          ? null
          : (visible) => widget.controller.setVisible(id, visible),
      secondary: selected && index != null
          ? ReorderableDragStartListener(
              key: Key('overview-reorder-$id'),
              index: index,
              enabled: !widget.controller.saving,
              child: const Icon(Icons.drag_handle),
            )
          : const Icon(Icons.extension_outlined),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final selected = widget.controller.selectedOwnedIds;
        final hidden = task5OwnedOverviewWidgetIds
            .where((id) => !selected.contains(id))
            .toList();
        final saving = widget.controller.saving;
        return Scaffold(
          appBar: AppBar(title: const Text('编辑概览')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('扩展组件'),
              const SizedBox(height: 8),
              if (selected.isNotEmpty)
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  itemCount: selected.length,
                  onReorder: widget.controller.reorder,
                  itemBuilder: (context, index) =>
                      _row(selected[index], selected: true, index: index),
                ),
              for (final id in hidden) _row(id, selected: false),
              if (widget.controller.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  '保存失败，请重试',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (saving) ...[
                const SizedBox(height: 12),
                const Center(
                  child: CircularProgressIndicator(
                    key: Key('overview-edit-saving'),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    key: const Key('overview-edit-cancel'),
                    onPressed: saving ? null : () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: const Key('overview-edit-save'),
                    onPressed: saving ? null : _save,
                    child: const Text('保存'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
