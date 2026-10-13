import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dsm_helper/apis/api.dart';
import 'file_operation_contract.dart';

typedef FileOperationEntry = Future<DsmResponse<dynamic>> Function(
  String api,
  String method, {
  required int version,
  required Map<String, dynamic> data,
});

enum FileOperationResultKind { immediate, taskAccepted, linkCreated }
enum FileOperationErrorKind {
  reauthNeeded, offline, permission, conflict, duplicate, server, malformed,
}

class FileOperationContextException implements Exception {
  const FileOperationContextException();
  @override
  String toString() => 'File operation context is no longer active';
}

class FileOperationResult {
  const FileOperationResult(this.kind, {this.taskId, this.link});

  final FileOperationResultKind kind;
  final String? taskId;
  final String? link;
}

class _OperationRequest {
  const _OperationRequest(this.api, this.method, this.version, this.data);

  final String api;
  final String method;
  final int version;
  final Map<String, dynamic> data;
}

/// A detached B1 adapter. There is intentionally no UI caller or background
/// retry; task-start acceptance is not the remote operation's completion.
class FileOperationDataSource {
  FileOperationDataSource({
    required this.contextId,
    required this.isContextCurrent,
    required this.entry,
    this.onReauthNeeded,
  });

  final String contextId;
  final bool Function() isContextCurrent;
  final FileOperationEntry entry;
  final void Function()? onReauthNeeded;

  bool _disposed = false;
  bool _busy = false;
  bool _reauthSignalled = false;

  factory FileOperationDataSource.production({
    required String contextId,
    required bool Function() isContextCurrent,
    void Function()? onReauthNeeded,
  }) {
    // The active DsmApi owns SID, host, SSL and Dio. Never re-enter the
    // Utils.post surface: its mutable globals can belong to another account
    // and its Dio failures are converted into untyped success:false maps.
    final bound = Api.dsm;
    final boundSid = bound.sid;
    final boundHost = bound.baseUrl;
    bool stillBound() =>
        isContextCurrent() && identical(Api.dsm, bound) &&
        bound.sid == boundSid && bound.baseUrl == boundHost;

    return FileOperationDataSource(
      contextId: contextId,
      isContextCurrent: stillBound,
      onReauthNeeded: onReauthNeeded,
      entry: (api, method, {required version, required data}) =>
          bound.entry(api, method, version: version, data: data),
    );
  }

  void invalidate() {
    _disposed = true;
  }

  bool get _isActive => !_disposed && isContextCurrent();

  void _assertCurrent(FileOperationSelection selection) {
    if (!_isActive || selection.contextId != contextId) {
      throw const FileOperationContextException();
    }
  }

  static FileOperationErrorKind classify(Object error) {
    if (error is DioException) return FileOperationErrorKind.offline;
    if (error is DsmException) {
      switch (error.code) {
        case 119:
          return FileOperationErrorKind.reauthNeeded;
        case 403:
          return FileOperationErrorKind.permission;
        case 414:
          return FileOperationErrorKind.conflict;
        case 800:
          return FileOperationErrorKind.duplicate;
        default:
          return FileOperationErrorKind.server;
      }
    }
    if (error is FormatException) return FileOperationErrorKind.malformed;
    return FileOperationErrorKind.server;
  }

  Future<FileOperationResult> execute({
    required FileOperationSelection selection,
    required FileOperationAction action,
    String? name,
    String? destination,
  }) async {
    _assertCurrent(selection);
    if (_busy) throw StateError('File operation already pending');
    if (selection.eligibility(action) == FileOperationEligibility.denied) {
      throw StateError('File operation is not eligible for these targets');
    }

    final request = _request(selection, action, name, destination);
    _busy = true;
    try {
      final response = await entry(
        request.api, request.method,
        version: request.version, data: request.data,
      );
      // A request already sent to A cannot be undone. Its late result
      // must never be published or used to refresh context B.
      _assertCurrent(selection);
      if (response.success != true) {
        final code = response.error?['code'];
        if (code is int) throw DsmException(code);
        throw const FormatException('Invalid File Station operation response');
      }

      switch (action) {
        case FileOperationAction.delete:
        case FileOperationAction.copy:
        case FileOperationAction.move:
          final data = response.data;
          final taskId = data is Map ? data['taskid'] : null;
          if (taskId is! String || taskId.trim().isEmpty) {
            throw const FormatException('Missing File Station task ID');
          }
          return FileOperationResult(
            FileOperationResultKind.taskAccepted, taskId: taskId,
          );
        case FileOperationAction.shareLink:
          final data = response.data;
          final links = data is Map ? data['links'] : null;
          final first = links is List && links.isNotEmpty ? links.first : null;
          final url = first is Map ? first['url'] : null;
          if (url is! String || url.trim().isEmpty) {
            throw const FormatException('Missing DSM-created sharing link');
          }
          return FileOperationResult(
            FileOperationResultKind.linkCreated, link: url,
          );
        case FileOperationAction.rename:
        case FileOperationAction.createFolder:
        case FileOperationAction.addFavorite:
        case FileOperationAction.removeFavorite:
          return const FileOperationResult(FileOperationResultKind.immediate);
      }
    } on DsmException catch (error) {
      if (error.code == 119 && _isActive && !_reauthSignalled) {
        _reauthSignalled = true;
        onReauthNeeded?.call();
      }
      rethrow;
    } finally {
      _busy = false;
    }
  }

  _OperationRequest _request(
    FileOperationSelection selection,
    FileOperationAction action,
    String? name,
    String? destination,
  ) {
    String validatedName() {
      if (name == null || name.trim().isEmpty) {
        throw StateError('File operation requires a nonempty name');
      }
      return name;
    }

    final paths = selection.targets.map((target) => target.path).toList();
    switch (action) {
      case FileOperationAction.rename:
        return _OperationRequest(
          'SYNO.FileStation.Rename', 'rename', 2,
          {'path': '"${paths.single}"', 'name': '"${validatedName()}"'},
        );
      case FileOperationAction.createFolder:
        return _OperationRequest(
          'SYNO.FileStation.CreateFolder', 'create', 2,
          {'force_parent': 'false',
           'folder_path': '"${selection.folderPath}"',
           'name': '"${validatedName()}"'},
        );
      case FileOperationAction.delete:
        return _OperationRequest(
          'SYNO.FileStation.Delete', 'start', 2,
          {'path': jsonEncode(paths), 'accurate_progress': 'true'},
        );
      case FileOperationAction.addFavorite:
        final target = selection.targets.single;
        final pathElements = target.path.split('/');
        if (pathElements.length < 3 || pathElements[1].isEmpty ||
            target.name == null || target.name!.trim().isEmpty) {
          throw StateError('File Station favorite needs a named share item');
        }
        return _OperationRequest(
          'SYNO.FileStation.Favorite', 'add', 2,
          {'path': target.path,
           'name': target.name! + ' - ' + pathElements[1]},
        );
      case FileOperationAction.removeFavorite:
        return _OperationRequest(
          'SYNO.FileStation.Favorite', 'delete', 2,
          {'path': paths.single},
        );
      case FileOperationAction.shareLink:
        return _OperationRequest(
          'SYNO.FileStation.Sharing', 'create', 3,
          {'path': jsonEncode(paths)},
        );
      case FileOperationAction.copy:
      case FileOperationAction.move:
        if (destination == null || destination.trim().isEmpty ||
            destination.contains('://') ||
            paths.any((path) => destination == path ||
                destination.startsWith(path + '/'))) {
          throw StateError('Unverified or invalid File Station destination');
        }
        // A seam only. No B1 UI is enabled; B5 requires a separately
        // approved overwrite policy before any live CopyMove dispatch.
        return _OperationRequest(
          'SYNO.FileStation.CopyMove', '"start"', 3,
          {'overwrite': 'true', 'dest_folder_path': destination,
           'remove_src': action == FileOperationAction.move,
           'accurate_progress': 'true', 'path': jsonEncode(paths)},
        );
    }
  }
}
