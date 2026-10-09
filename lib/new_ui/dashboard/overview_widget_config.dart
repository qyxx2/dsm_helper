/// Task 5 owns only these two DSM widget IDs. All other module IDs remain
/// opaque and must survive an Overview edit unchanged.
const task5OwnedOverviewWidgetIds = <String>[
  'SYNO.SDS.SystemInfoApp.ConnectionLogWidget',
  'SYNO.SDS.TaskScheduler.TaskSchedulerWidget',
];

/// Replaces only the Task 5-owned subsequence, preserving every non-owned
/// module and its relative position. Additional owned modules are placed after
/// the last original owned slot, or appended when there was no owned slot.
List<String> mergeTask5OverviewModuleIds({
  required List<String> originalModuleIds,
  required List<String> editedOwnedIds,
}) {
  final owned = task5OwnedOverviewWidgetIds.toSet();
  final edited = <String>[];
  for (final id in editedOwnedIds) {
    if (owned.contains(id) && !edited.contains(id)) {
      edited.add(id);
    }
  }

  final lastOwnedSlot = originalModuleIds.lastIndexWhere(owned.contains);
  final merged = <String>[];
  var nextEdited = 0;
  for (var i = 0; i < originalModuleIds.length; i++) {
    final id = originalModuleIds[i];
    if (owned.contains(id)) {
      if (nextEdited < edited.length) {
        merged.add(edited[nextEdited++]);
      }
    } else {
      merged.add(id);
    }
    if (i == lastOwnedSlot) {
      while (nextEdited < edited.length) {
        merged.add(edited[nextEdited++]);
      }
    }
  }
  if (lastOwnedSlot == -1) {
    merged.addAll(edited);
  }
  return merged;
}
