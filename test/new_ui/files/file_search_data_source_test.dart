import 'dart:async';
import 'dart:convert';

import 'package:dsm_helper/apis/api.dart';
import 'package:dsm_helper/new_ui/files/file_search_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

class _Call {
  _Call(this.api, this.method, this.version, this.data);

  final String api;
  final String method;
  final int version;
  final Map<String, dynamic> data;
}

DsmResponse<dynamic> ok(dynamic data) =>
    DsmResponse<dynamic>(success: true, data: data);

FileSearchDataSource sourceWith(
  Future<DsmResponse<dynamic>> Function(_Call call) responder, {
  List<_Call>? calls,
}) {
  final recorded = calls ?? <_Call>[];
  return FileSearchDataSource(
    contextId: 'A',
    isContextCurrent: () => true,
    entry: (api, method, {required version, required data}) async {
      final call = _Call(api, method, version, Map<String, dynamic>.from(data));
      recorded.add(call);
      return responder(call);
    },
  );
}

Map<String, dynamic> row(String path) => <String, dynamic>{
      'path': path,
      'name': path.split('/').last,
      'isdir': false,
      'additional': <String, dynamic>{},
    };

void main() {
  test('Search/start v2 preserves exact verified folder and legacy flags', () async {
    final calls = <_Call>[];
    final source = sourceWith((_) async => ok(<String, dynamic>{
          'taskid': 'search-job-1',
        }), calls: calls);

    final result = await source.startSearch(
      folderPath: '/共享/音乐',
      pattern: '  Miles Davis  ',
      recursive: false,
      searchContent: true,
    );

    expect(result.taskId, 'search-job-1');
    expect(calls, hasLength(1));
    expect(calls.single.api, 'SYNO.FileStation.Search');
    expect(calls.single.method, '"start"');
    expect(calls.single.version, 2);
    expect(jsonDecode(calls.single.data['folder_path'] as String),
        <String>['/共享/音乐']);
    expect(calls.single.data, containsPair('pattern', '"Miles Davis"'));
    expect(calls.single.data, containsPair('recursive', false));
    expect(calls.single.data, containsPair('search_content', true));
    expect(calls.single.data, containsPair('search_type', '"simple"'));
  });

  test('Search/list forwards task id offset and caller limit instead of fixed 0/1000',
      () async {
    final calls = <_Call>[];
    final files = List<Map<String, dynamic>>.generate(
      101,
      (index) => row('/share/result-${1000 + index}'),
    );
    final source = sourceWith((_) async => ok(<String, dynamic>{
          'offset': 1000,
          'total': 1101,
          'finished': false,
          'files': files,
        }), calls: calls);

    final page = await source.loadPage(
      taskId: 'job-real',
      offset: 1000,
      limit: 101,
    );

    expect(calls, hasLength(1));
    expect(calls.single.api, 'SYNO.FileStation.Search');
    expect(calls.single.method, '"list"');
    expect(calls.single.version, 2);
    expect(calls.single.data['taskid'], 'job-real');
    expect(calls.single.data['offset'], 1000);
    expect(calls.single.data['limit'], 101);
    expect(calls.single.data['filetype'], 'all');
    expect(jsonDecode(calls.single.data['additional'] as String),
        containsAll(<String>['real_path', 'size', 'owner', 'time', 'perm', 'type']));
    expect(page.offset, 1000);
    expect(page.total, 1101);
    expect(page.finished, isFalse);
    expect(page.items, hasLength(101));
    expect(page.items.first.path, '/share/result-1000');
  });

  test('finished empty page is distinct from unfinished empty page', () async {
    var finished = false;
    final source = sourceWith((_) async => ok(<String, dynamic>{
          'offset': 0,
          'total': 0,
          'finished': finished,
          'files': <dynamic>[],
        }));

    final pending = await source.loadPage(taskId: 'job', offset: 0, limit: 100);
    expect(pending.finished, isFalse);
    expect(pending.items, isEmpty);

    finished = true;
    final done = await source.loadPage(taskId: 'job', offset: 0, limit: 100);
    expect(done.finished, isTrue);
    expect(done.items, isEmpty);
  });

  test('1000 plus results require explicit later page and are never silently capped',
      () async {
    final calls = <_Call>[];
    final source = sourceWith((call) async {
      final offset = call.data['offset'] as int;
      final limit = call.data['limit'] as int;
      final count = offset == 0 ? limit : 101;
      return ok(<String, dynamic>{
        'offset': offset,
        'total': 1101,
        'finished': offset > 0,
        'files': List<Map<String, dynamic>>.generate(
          count,
          (index) => row('/share/item-${offset + index}'),
        ),
      });
    }, calls: calls);

    final first = await source.loadPage(taskId: 'job', offset: 0, limit: 1000);
    final second =
        await source.loadPage(taskId: 'job', offset: 1000, limit: 101);

    expect(first.items, hasLength(1000));
    expect(first.finished, isFalse);
    expect(second.items, hasLength(101));
    expect(second.finished, isTrue);
    expect(calls.map((call) => call.data['offset']), <int>[0, 1000]);
    expect(calls.map((call) => call.data['limit']), <int>[1000, 101]);
  });

  test('overlap remains visible to the paging owner and does not become false complete',
      () async {
    final source = sourceWith((_) async => ok(<String, dynamic>{
          'offset': 100,
          'total': 202,
          'finished': false,
          'files': <Map<String, dynamic>>[
            row('/share/duplicate'),
            row('/share/new'),
          ],
        }));

    final page = await source.loadPage(taskId: 'job', offset: 100, limit: 100);

    expect(page.items.map((item) => item.path),
        <String?>['/share/duplicate', '/share/new']);
    expect(page.finished, isFalse);
  });

  test('malformed start and list responses fail explicitly', () async {
    var start = true;
    final source = sourceWith((_) async => start
        ? ok(<String, dynamic>{})
        : ok(<String, dynamic>{
            'offset': 0,
            'finished': false,
          }));

    await expectLater(
      source.startSearch(folderPath: '/share', pattern: 'x'),
      throwsA(isA<FileSearchDataException>()),
    );

    start = false;
    await expectLater(
      source.loadPage(taskId: 'job', offset: 0, limit: 100),
      throwsA(isA<FileSearchDataException>()),
    );
  });

  test('a delayed unfinished page causes one request only; datasource never self-polls',
      () async {
    final pending = Completer<DsmResponse<dynamic>>();
    var calls = 0;
    final source = FileSearchDataSource(
      contextId: 'A',
      isContextCurrent: () => true,
      entry: (api, method, {required version, required data}) {
        calls++;
        return pending.future;
      },
    );

    final future = source.loadPage(taskId: 'job', offset: 0, limit: 100);
    await Future<void>.delayed(Duration.zero);
    expect(calls, 1);

    pending.complete(ok(<String, dynamic>{
      'offset': 0,
      'finished': false,
      'files': <dynamic>[],
    }));
    final page = await future;
    expect(page.finished, isFalse);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(calls, 1);
  });
}
