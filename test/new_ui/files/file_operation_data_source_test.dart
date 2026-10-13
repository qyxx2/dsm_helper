import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dsm_helper/apis/api.dart';
import 'package:dsm_helper/apis/dsm_api/dsm_api.dart';
import 'package:dsm_helper/models/Syno/FileStation/FileStationList.dart';
import 'package:dsm_helper/new_ui/files/file_operation_contract.dart';
import 'package:dsm_helper/new_ui/files/file_operation_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

class _Call {
  _Call(this.api, this.method, this.version, this.data);
  final String api;
  final String method;
  final int version;
  final Map<String, dynamic> data;
}

FileOperationSelection picked({String context = 'A', String? path = '/share',
  List<FileItem>? items, Set<String>? selected}) =>
  FileOperationSelection.capture(
    contextId: context, folderPath: path, isComplete: false,
    loadedItems: items ?? [FileItem(path: '/share/a', name: 'a', isdir: false)],
    selectedPaths: selected ?? {'/share/a'},
  );

DsmResponse<dynamic> ok([dynamic data]) =>
    DsmResponse<dynamic>(success: true, data: data ?? <String, dynamic>{});

class _RecordingApi extends DsmApi {
  _RecordingApi(String sid) : super(baseUrl: 'https://nas.invalid', sid: sid);
  final List<_Call> calls = [];
  @override
  Future<DsmResponse> entry<T>(
    String api, String method, {bool post = true, dynamic data, String? path,
    int? version, Map<String, dynamic>? parameters, Options? options,
    T Function(dynamic)? parser,
  }) async {
    calls.add(_Call(api, method, version!, Map<String, dynamic>.from(data as Map)));
    return DsmResponse(success: true, data: {'taskid': 'job-1'});
  }
}

void main() {
  test('immediate rename/create keep existing v2 protocol, quoted fields and active SID ownership', () async {
    final calls = <_Call>[];
    final source = FileOperationDataSource(
      contextId: 'A', isContextCurrent: () => true,
      entry: (api, method, {required version, required data}) async {
        calls.add(_Call(api, method, version, data));
        return ok();
      },
    );
    final renamed = await source.execute(selection: picked(),
      action: FileOperationAction.rename, name: '新 名称');
    expect(renamed.kind, FileOperationResultKind.immediate);
    expect(calls.single.api, 'SYNO.FileStation.Rename');
    expect(calls.single.method, 'rename');
    expect(calls.single.version, 2);
    expect(calls.single.data, {'path': '"/share/a"', 'name': '"新 名称"'});
    calls.clear();
    final made = await source.execute(
      selection: picked(items: [], selected: {}),
      action: FileOperationAction.createFolder, name: 'new');
    expect(made.kind, FileOperationResultKind.immediate);
    expect(calls.single.api, 'SYNO.FileStation.CreateFolder');
    expect(calls.single.method, 'create');
    expect(calls.single.version, 2);
    expect(calls.single.data, {'force_parent': 'false',
      'folder_path': '"/share"', 'name': '"new"'});
  });

  test('favorite and ordinary Sharing v3 preserve identity and literal fields', () async {
    final calls = <_Call>[];
    final source = FileOperationDataSource(
      contextId: 'A', isContextCurrent: () => true,
      entry: (api, method, {required version, required data}) async {
        calls.add(_Call(api, method, version, data));
        return api == 'SYNO.FileStation.Sharing'
          ? ok({'links': <Map<String, String>>[{'url': 'https://example.invalid/l'}]})
          : ok();
      },
    );
    await source.execute(selection: picked(), action: FileOperationAction.addFavorite);
    expect(calls.last.api, 'SYNO.FileStation.Favorite');
    expect(calls.last.method, 'add');
    expect(calls.last.version, 2);
    expect(calls.last.data, {'path': '/share/a', 'name': 'a - share'});
    await source.execute(selection: picked(), action: FileOperationAction.removeFavorite);
    expect(calls.last.method, 'delete');
    expect(calls.last.data, {'path': '/share/a'});
    final linked = await source.execute(selection: picked(),
      action: FileOperationAction.shareLink);
    expect(linked.kind, FileOperationResultKind.linkCreated);
    expect(linked.link, 'https://example.invalid/l');
    expect(calls.last.api, 'SYNO.FileStation.Sharing');
    expect(calls.last.method, 'create');
    expect(calls.last.version, 3);
    expect(calls.last.data, {'path': '["/share/a"]'});
  });

  test('delete task and copy/move preserve v2/v3 task-start semantics and polarity', () async {
    final calls = <_Call>[];
    final source = FileOperationDataSource(
      contextId: 'A', isContextCurrent: () => true,
      entry: (api, method, {required version, required data}) async {
        calls.add(_Call(api, method, version, data));
        return ok({'taskid': 'job-1'});
      },
    );
    for (final action in [FileOperationAction.delete,
      FileOperationAction.copy, FileOperationAction.move]) {
      final result = await source.execute(selection: picked(), action: action,
        destination: '/share/destination');
      expect(result.kind, FileOperationResultKind.taskAccepted);
      expect(result.taskId, 'job-1');
    }
    expect(calls[0].api, 'SYNO.FileStation.Delete');
    expect(calls[0].method, 'start');
    expect(calls[0].version, 2);
    expect(calls[0].data, {'path': '["/share/a"]',
      'accurate_progress': 'true'});
    for (var i = 1; i <= 2; i++) {
      expect(calls[i].api, 'SYNO.FileStation.CopyMove');
      expect(calls[i].method, '"start"');
      expect(calls[i].version, 3);
      expect(calls[i].data, {
        'overwrite': 'true', 'dest_folder_path': '/share/destination',
        'remove_src': i == 2, 'accurate_progress': 'true',
        'path': '["/share/a"]',
      });
    }
  });

  test('no write for mismatched context, empty/invalid selection or disposed route', () async {
    var calls = 0;
    var current = true;
    final source = FileOperationDataSource(
      contextId: 'A', isContextCurrent: () => current,
      entry: (api, method, {required version, required data}) async {
        calls++;
        return ok();
      },
    );
    await expectLater(source.execute(
      selection: picked(context: 'B'), action: FileOperationAction.rename,
      name: 'new'), throwsA(isA<FileOperationContextException>()));
    await expectLater(source.execute(selection: picked(items: [], selected: {}),
      action: FileOperationAction.delete), throwsStateError);
    current = false;
    await expectLater(source.execute(selection: picked(),
      action: FileOperationAction.rename, name: 'new'),
      throwsA(isA<FileOperationContextException>()));
    current = true;
    source.invalidate();
    await expectLater(source.execute(selection: picked(),
      action: FileOperationAction.rename, name: 'new'),
      throwsA(isA<FileOperationContextException>()));
    expect(calls, 0);
  });

  test('production binds canonical DsmApi instance not mutable Utils.post globals', () async {
    final original = Api.dsm;
    final a = _RecordingApi('sid-A');
    final b = _RecordingApi('sid-B');
    try {
      Api.dsm = a;
      var active = true;
      final source = FileOperationDataSource.production(
        contextId: 'A', isContextCurrent: () => active);
      final result = await source.execute(
        selection: picked(), action: FileOperationAction.delete);
      expect(result.kind, FileOperationResultKind.taskAccepted);
      expect(a.calls, hasLength(1));
      expect(a.calls.single.api, 'SYNO.FileStation.Delete');
      active = false;
      Api.dsm = b;
      await expectLater(source.execute(selection: picked(),
        action: FileOperationAction.delete),
        throwsA(isA<FileOperationContextException>()));
      expect(b.calls, isEmpty);
      expect(a.calls, hasLength(1));
    } finally {
      Api.dsm = original;
    }
  });

  test('late completion after route disposal is discarded, never applied to account B', () async {
    final pending = Completer<DsmResponse<dynamic>>();
    final source = FileOperationDataSource(
      contextId: 'A', isContextCurrent: () => true,
      entry: (api, method, {required version, required data}) => pending.future,
    );
    final task = source.execute(selection: picked(), action: FileOperationAction.delete);
    source.invalidate();
    pending.complete(ok({'taskid': 'job-A'}));
    await expectLater(task, throwsA(isA<FileOperationContextException>()));
  });

  test('119 callback once, original DSM and Dio exceptions not hidden', () async {
    var signals = 0;
    Object failure = const DsmException(119);
    final source = FileOperationDataSource(
      contextId: 'A', isContextCurrent: () => true,
      onReauthNeeded: () => signals++,
      entry: (api, method, {required version, required data}) async {
        throw failure;
      },
    );
    for (var i = 0; i < 2; i++) {
      await expectLater(source.execute(selection: picked(),
        action: FileOperationAction.delete), throwsA(isA<DsmException>()));
    }
    expect(signals, 1);
    failure = DioException(requestOptions: RequestOptions(path: '/webapi/entry.cgi'));
    await expectLater(source.execute(selection: picked(),
      action: FileOperationAction.delete), throwsA(isA<DioException>()));
    expect(signals, 1);
    expect(FileOperationDataSource.classify(const DsmException(119)),
      FileOperationErrorKind.reauthNeeded);
    expect(FileOperationDataSource.classify(const DsmException(414)),
      FileOperationErrorKind.conflict);
    expect(FileOperationDataSource.classify(const DsmException(800)),
      FileOperationErrorKind.duplicate);
    expect(FileOperationDataSource.classify(failure),
      FileOperationErrorKind.offline);
  });

  test('blank task ID and missing server-created link never count as successful mutation', () async {
    final source = FileOperationDataSource(
      contextId: 'A', isContextCurrent: () => true,
      entry: (api, method, {required version, required data}) async =>
          ok({'taskid': '  ', 'links': <dynamic>[]}),
    );
    await expectLater(source.execute(selection: picked(),
      action: FileOperationAction.delete), throwsFormatException);
    await expectLater(source.execute(selection: picked(),
      action: FileOperationAction.shareLink), throwsFormatException);
  });
}
