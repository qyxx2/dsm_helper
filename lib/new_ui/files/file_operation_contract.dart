import 'package:dsm_helper/models/Syno/FileStation/FileStationList.dart';

/// B1 is an unmounted operation contract; no user-facing mutation is enabled.
enum FileOperationAction {
  rename, createFolder, delete, addFavorite, removeFavorite, shareLink, copy, move,
}

/// Allowed means locally eligible, never a guarantee of DSM server permission.
enum FileOperationEligibility { allowed, requiresServerCheck, denied }

/// A value snapshot: no mutable FileItem or ACL model is retained.
class FileOperationTarget {
  const FileOperationTarget({
    required this.path,
    required this.name,
    required this.isDirectory,
    required this.canRead,
    required this.canWrite,
    required this.canDelete,
  });

  final String path;
  final String? name;
  final bool isDirectory;
  final bool? canRead;
  final bool? canWrite;
  final bool? canDelete;

  /// Remote and virtual path mutation semantics have not been verified.
  bool get isSpecialPath => path.contains('://');
}

/// Only explicitly selected, *loaded* paths in a verified directory are kept.
class FileOperationSelection {
  const FileOperationSelection._({
    required this.contextId,
    required this.folderPath,
    required this.isComplete,
    required this.targets,
  });

  final String contextId;
  final String? folderPath;
  final bool isComplete;
  final List<FileOperationTarget> targets;

  factory FileOperationSelection.capture({
    required String contextId,
    required String? folderPath,
    required bool isComplete,
    required Iterable<FileItem> loadedItems,
    required Set<String> selectedPaths,
  }) {
    final targets = <FileOperationTarget>[];
    final visited = <String>{};
    // The share-list root has no mutable targets. A row representing an
    // individual share is navigation-only even when accidentally selected.
    if (contextId.isNotEmpty && _validFolder(folderPath)) {
      for (final item in loadedItems) {
        final path = item.path;
        if (path == null || path.trim().isEmpty ||
            path == '/' || path == folderPath ||
            !selectedPaths.contains(path) || !visited.add(path)) {
          continue;
        }
        final acl = item.additional?.perm?.acl;
        targets.add(FileOperationTarget(
          path: path,
          name: item.name,
          isDirectory: item.isdir == true,
          canRead: acl?.read,
          canWrite: acl?.write,
          canDelete: acl?.del,
        ));
      }
    }
    return FileOperationSelection._(
      contextId: contextId,
      folderPath: folderPath,
      isComplete: isComplete,
      targets: List<FileOperationTarget>.unmodifiable(targets),
    );
  }

  static bool _validFolder(String? path) =>
      path != null && path.trim().isNotEmpty && path != '/';

  FileOperationEligibility eligibility(FileOperationAction action) {
    if (contextId.isEmpty || !_validFolder(folderPath) ||
        folderPath!.contains('://')) {
      return FileOperationEligibility.denied;
    }

    if (action == FileOperationAction.createFolder) {
      // Current-directory ACL is not part of a selected child-row snapshot.
      // An unselected verified directory must still defer to DSM permission.
      return targets.isEmpty
          ? FileOperationEligibility.requiresServerCheck
          : FileOperationEligibility.denied;
    }

    if (targets.isEmpty || targets.any((target) => target.isSpecialPath)) {
      return FileOperationEligibility.denied;
    }

    if ((action == FileOperationAction.rename ||
            action == FileOperationAction.shareLink ||
            action == FileOperationAction.addFavorite ||
            action == FileOperationAction.removeFavorite) &&
        targets.length != 1) {
      return FileOperationEligibility.denied;
    }

    if (action == FileOperationAction.addFavorite &&
        (targets.single.name == null || targets.single.name!.trim().isEmpty)) {
      return FileOperationEligibility.denied;
    }

    bool? capability(FileOperationTarget target) {
      switch (action) {
        case FileOperationAction.rename:
          return target.canWrite;
        case FileOperationAction.delete:
        case FileOperationAction.move:
          return target.canDelete;
        case FileOperationAction.copy:
        case FileOperationAction.shareLink:
          return target.canRead;
        case FileOperationAction.addFavorite:
        case FileOperationAction.removeFavorite:
          // Favorite membership is server-authoritative, not an ACL grant.
          return null;
        case FileOperationAction.createFolder:
          return null;
      }
    }

    final claims = targets.map(capability).toList();
    if (claims.any((claim) => claim == false)) {
      return FileOperationEligibility.denied;
    }
    if (claims.any((claim) => claim == null)) {
      return FileOperationEligibility.requiresServerCheck;
    }
    return FileOperationEligibility.allowed;
  }
}
