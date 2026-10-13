import 'dart:convert';

import 'package:dsm_helper/apis/api.dart';
import 'package:dsm_helper/models/Syno/FileStation/FileStationList.dart';

typedef FileSearchEntry = Future<DsmResponse<dynamic>> Function(
  String api,
  String method, {
  required int version,
  required Map<String, dynamic> data,
});

class FileSearchDataException implements Exception {
  const FileSearchDataException(this.message);
  final String message;

  @override
  String toString() => 'FileSearchDataException: $message';
}

class FileSearchStart {
  const FileSearchStart(this.taskId);
  final String taskId;
}

class FileSearchPage {
  const FileSearchPage({
    required this.offset,
    required this.items,
    required this.finished,
    this.total,
  });

  final int offset;
  final List<FileItem> items;
  final bool finished;
  final int? total;
}

class FileSearchDataSource {
  const FileSearchDataSource({
    required this.contextId,
    required this.isContextCurrent,
    required this.entry,
  });

  factory FileSearchDataSource.production({
    required String contextId,
    required bool Function() isContextCurrent,
  }) {
    final bound = Api.dsm;
    final boundSid = bound.sid;
    final boundHost = bound.baseUrl;

    bool stillBound() =>
        isContextCurrent() &&
        identical(Api.dsm, bound) &&
        bound.sid == boundSid &&
        bound.baseUrl == boundHost;

    return FileSearchDataSource(
      contextId: contextId,
      isContextCurrent: stillBound,
      entry: (api, method, {required version, required data}) =>
          bound.entry(api, method, version: version, data: data),
    );
  }

  final String contextId;
  final bool Function() isContextCurrent;
  final FileSearchEntry entry;

  void _assertCurrent() {
    if (!isContextCurrent()) {
      throw const FileSearchDataException('Inactive DSM context');
    }
  }

  Future<FileSearchStart> startSearch({
    required String folderPath,
    required String pattern,
    bool recursive = true,
    bool searchContent = false,
  }) async {
    _assertCurrent();
    if (folderPath.isEmpty || pattern.trim().isEmpty) {
      throw const FileSearchDataException('Invalid search request');
    }

    final res = await entry(
      'SYNO.FileStation.Search',
      '"start"',
      version: 2,
      data: {
        'folder_path': jsonEncode(<String>[folderPath]),
        'pattern': jsonEncode(pattern.trim()),
        'recursive': recursive,
        'search_content': searchContent,
        'search_type': '"simple"',
      },
    );

    _assertCurrent();
    final data = res.data;
    final taskId = data is Map ? data['taskid'] : null;
    if (res.success != true ||
        taskId is! String ||
        taskId.trim().isEmpty) {
      throw const FileSearchDataException('Missing search task id');
    }
    return FileSearchStart(taskId);
  }

  Future<FileSearchPage> loadPage({
    required String taskId,
    required int offset,
    required int limit,
  }) async {
    _assertCurrent();
    if (taskId.isEmpty || offset < 0 || limit <= 0) {
      throw const FileSearchDataException('Invalid search page request');
    }

    final res = await entry(
      'SYNO.FileStation.Search',
      '"list"',
      version: 2,
      data: {
        'taskid': taskId,
        'offset': offset,
        'limit': limit,
        'filetype': 'all',
        'additional': jsonEncode(<String>[
          'real_path',
          'size',
          'owner',
          'time',
          'perm',
          'type',
        ]),
      },
    );

    _assertCurrent();
    final data = res.data;
    if (res.success != true ||
        data is! Map ||
        data['files'] is! List ||
        data['finished'] is! bool) {
      throw const FileSearchDataException('Malformed search result');
    }

    try {
      return FileSearchPage(
        offset: data['offset'] is int ? data['offset'] as int : offset,
        total: data['total'] is int ? data['total'] as int : null,
        finished: data['finished'] as bool,
        items: (data['files'] as List)
            .map((item) => FileItem.fromJson(item))
            .toList(),
      );
    } catch (error) {
      throw FileSearchDataException('Malformed search file: $error');
    }
  }
}
