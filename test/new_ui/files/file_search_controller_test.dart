import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dsm_helper/apis/dsm_api/dsm_exception.dart';
import 'package:dsm_helper/models/Syno/FileStation/FileStationList.dart';
import 'package:dsm_helper/new_ui/files/file_search_controller.dart';
import 'package:dsm_helper/new_ui/files/file_search_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _StartHandler = Future<FileSearchStart> Function({
  required String folderPath,
  required String pattern,
  required bool recursive,
  required bool searchContent,
});

typedef _PageHandler = Future<FileSearchPage> Function({
  required String taskId,
  required int offset,
  required int limit,
});

class _FakeSearchSource extends FileSearchDataSource {
  _FakeSearchSource({
    required this.onStart,
    required this.onPage,
  }) : super(
          contextId: 'fake',
          isContextCurrent: () => true,
          entry: (api, method, {required version, required data}) =>
              throw UnimplementedError('fake transport is never used'),
        );

  final _StartHandler onStart;
  final _PageHandler onPage;

  @override
  Future<FileSearchStart> startSearch({
    required String folderPath,
    required String pattern,
    bool recursive = true,
    bool searchContent = false,
  }) => onStart(
    folderPath: folderPath,
    pattern: pattern,
    recursive: recursive,
    searchContent: searchContent,
  );

  @override
  Future<FileSearchPage> loadPage({
    required String taskId,
    required int offset,
    required int limit,
  }) => onPage(taskId: taskId, offset: offset, limit: limit);
}

FileItem item(String path) => FileItem(
  path: path,
  name: path.split('/').last,
  isdir: false,
);

FileSearchPage searchPage({
  required int offset,
  required List<FileItem> items,
  required bool finished,
  int? total,
}) => FileSearchPage(
  offset: offset,
  items: items,
  finished: finished,
  total: total,
);

void main() {
  test('finished empty search is explicit empty and preserves folder scope', () async {
    final source = _FakeSearchSource(
      onStart: ({
        required folderPath,
        required pattern,
        required recursive,
        required searchContent,
      }) async {
        expect(folderPath, '/share/音乐');
        expect(pattern, 'Miles');
        return const FileSearchStart('task-empty');
      },
      onPage: ({
        required taskId,
        required offset,
        required limit,
      }) async => searchPage(offset: 0, items: <FileItem>[], finished: true, total: 0),
    );
    final controller = FileSearchController(
      dataSource: source,
      contextId: 'NAS-A/user',
      folderPath: '/share/音乐',
      wait: (_) async {},
    );

    await controller.search('Miles');

    expect(controller.folderPath, '/share/音乐');
    expect(controller.pattern, 'Miles');
    expect(controller.taskId, 'task-empty');
    expect(controller.items, isEmpty);
    expect(controller.phase, FileSearchPhase.empty);
    expect(controller.isComplete, isTrue);
    controller.dispose();
  });

  test('finished job still pages past a full first page and returns 101 exact results', () async {
    final offsets = <int>[];
    final source = _FakeSearchSource(
      onStart: ({
        required folderPath,
        required pattern,
        required recursive,
        required searchContent,
      }) async => const FileSearchStart('task-101'),
      onPage: ({
        required taskId,
        required offset,
        required limit,
      }) async {
        offsets.add(offset);
        if (offset == 0) {
          return searchPage(
            offset: 0,
            items: List<FileItem>.generate(100, (i) => item('/share/$i')),
            finished: true,
            total: 101,
          );
        }
        return searchPage(
          offset: 100,
          items: <FileItem>[item('/share/100')],
          finished: true,
          total: 101,
        );
      },
    );
    final controller = FileSearchController(
      dataSource: source,
      contextId: 'NAS-A/user',
      folderPath: '/share',
      wait: (_) async {},
    );

    await controller.search('file');

    expect(offsets, <int>[0, 100]);
    expect(controller.items, hasLength(101));
    expect(controller.items.last.path, '/share/100');
    expect(controller.phase, FileSearchPhase.complete);
    expect(controller.isComplete, isTrue);
    controller.dispose();
  });

  test('rapid query replacement ignores late task and result from old generation', () async {
    final oldStart = Completer<FileSearchStart>();
    final source = _FakeSearchSource(
      onStart: ({
        required folderPath,
        required pattern,
        required recursive,
        required searchContent,
      }) => pattern == 'old'
          ? oldStart.future
          : Future<FileSearchStart>.value(const FileSearchStart('task-new')),
      onPage: ({
        required taskId,
        required offset,
        required limit,
      }) async => searchPage(
        offset: 0,
        items: <FileItem>[item('/new/result')],
        finished: true,
        total: 1,
      ),
    );
    final controller = FileSearchController(
      dataSource: source,
      contextId: 'NAS-A/user',
      folderPath: '/share',
      wait: (_) async {},
    );

    final old = controller.search('old');
    await Future<void>.delayed(Duration.zero);
    await controller.search('new');
    oldStart.complete(const FileSearchStart('task-old'));
    await old;

    expect(controller.pattern, 'new');
    expect(controller.taskId, 'task-new');
    expect(controller.items.map((e) => e.path), <String?>['/new/result']);
    expect(controller.phase, FileSearchPhase.complete);
    controller.dispose();
  });

  test('unfinished empty polling is serialized and stops at bounded retry limit', () async {
    var active = 0;
    var maxActive = 0;
    var pageCalls = 0;
    final source = _FakeSearchSource(
      onStart: ({
        required folderPath,
        required pattern,
        required recursive,
        required searchContent,
      }) async => const FileSearchStart('task-poll'),
      onPage: ({
        required taskId,
        required offset,
        required limit,
      }) async {
        pageCalls++;
        active++;
        if (active > maxActive) maxActive = active;
        await Future<void>.delayed(Duration.zero);
        active--;
        return searchPage(offset: offset, items: <FileItem>[], finished: false);
      },
    );
    final controller = FileSearchController(
      dataSource: source,
      contextId: 'NAS-A/user',
      folderPath: '/share',
      maxPollAttempts: 3,
      wait: (_) async {},
    );

    await controller.search('slow');

    expect(pageCalls, 3);
    expect(maxActive, 1);
    expect(controller.items, isEmpty);
    expect(controller.phase, FileSearchPhase.incomplete);
    expect(controller.isComplete, isFalse);
    controller.dispose();
  });

  test('overlapping full page that cannot advance becomes incomplete, not false complete', () async {
    var pageCalls = 0;
    final repeated = List<FileItem>.generate(100, (i) => item('/share/$i'));
    final source = _FakeSearchSource(
      onStart: ({
        required folderPath,
        required pattern,
        required recursive,
        required searchContent,
      }) async => const FileSearchStart('task-overlap'),
      onPage: ({
        required taskId,
        required offset,
        required limit,
      }) async {
        pageCalls++;
        return searchPage(
          offset: offset,
          items: repeated,
          finished: false,
          total: 250,
        );
      },
    );
    final controller = FileSearchController(
      dataSource: source,
      contextId: 'NAS-A/user',
      folderPath: '/share',
      wait: (_) async {},
    );

    await controller.search('x');

    expect(pageCalls, 2);
    expect(controller.items, hasLength(100));
    expect(controller.phase, FileSearchPhase.incomplete);
    expect(controller.isComplete, isFalse);
    expect(controller.error, isNotNull);
    controller.dispose();
  });

  test('offline and DSM 119 remain distinct; reauth callback is one-shot', () async {
    final offline = FileSearchController(
      dataSource: _FakeSearchSource(
        onStart: ({
          required folderPath,
          required pattern,
          required recursive,
          required searchContent,
        }) async => throw DioException(
          requestOptions: RequestOptions(path: '/webapi/entry.cgi'),
          type: DioExceptionType.connectionTimeout,
        ),
        onPage: ({
          required taskId,
          required offset,
          required limit,
        }) async => throw StateError('not reached'),
      ),
      contextId: 'NAS-A/user',
      folderPath: '/share',
    );
    await offline.search('x');
    expect(offline.phase, FileSearchPhase.offline);
    offline.dispose();

    var reauth = 0;
    final auth = FileSearchController(
      dataSource: _FakeSearchSource(
        onStart: ({
          required folderPath,
          required pattern,
          required recursive,
          required searchContent,
        }) async => throw const DsmException(119),
        onPage: ({
          required taskId,
          required offset,
          required limit,
        }) async => throw StateError('not reached'),
      ),
      contextId: 'NAS-A/user',
      folderPath: '/share',
      onReauthNeeded: () => reauth++,
    );
    await auth.search('x');
    await auth.retry();
    expect(auth.phase, FileSearchPhase.reauthNeeded);
    expect(reauth, 1);
    auth.dispose();
  });

  test('malformed datasource failure is unavailable rather than empty success', () async {
    final source = _FakeSearchSource(
      onStart: ({
        required folderPath,
        required pattern,
        required recursive,
        required searchContent,
      }) async => const FileSearchStart('task-bad'),
      onPage: ({
        required taskId,
        required offset,
        required limit,
      }) async => throw const FileSearchDataException('malformed'),
    );
    final controller = FileSearchController(
      dataSource: source,
      contextId: 'NAS-A/user',
      folderPath: '/share',
    );

    await controller.search('x');

    expect(controller.items, isEmpty);
    expect(controller.phase, FileSearchPhase.unavailable);
    expect(controller.error, isA<FileSearchDataException>());
    controller.dispose();
  });

  test('dispose invalidates a late page and schedules no further local polls', () async {
    final late = Completer<FileSearchPage>();
    var pageCalls = 0;
    final source = _FakeSearchSource(
      onStart: ({
        required folderPath,
        required pattern,
        required recursive,
        required searchContent,
      }) async => const FileSearchStart('task-late'),
      onPage: ({
        required taskId,
        required offset,
        required limit,
      }) {
        pageCalls++;
        return late.future;
      },
    );
    final controller = FileSearchController(
      dataSource: source,
      contextId: 'NAS-A/user',
      folderPath: '/share',
      wait: (_) async {},
    );
    var notifications = 0;
    controller.addListener(() => notifications++);

    final pending = controller.search('x');
    await Future<void>.delayed(Duration.zero);
    controller.dispose();
    final afterDispose = notifications;
    late.complete(searchPage(offset: 0, items: <FileItem>[], finished: false));
    await pending;
    await Future<void>.delayed(Duration.zero);

    expect(pageCalls, 1);
    expect(notifications, afterDispose);
  });

  test('local cancel invalidates pending work without inventing remote Search stop', () async {
    final late = Completer<FileSearchPage>();
    final source = _FakeSearchSource(
      onStart: ({
        required folderPath,
        required pattern,
        required recursive,
        required searchContent,
      }) async => const FileSearchStart('task-cancel'),
      onPage: ({
        required taskId,
        required offset,
        required limit,
      }) => late.future,
    );
    final controller = FileSearchController(
      dataSource: source,
      contextId: 'NAS-A/user',
      folderPath: '/share',
      wait: (_) async {},
    );

    final pending = controller.search('x');
    await Future<void>.delayed(Duration.zero);
    controller.cancelLocal();
    late.complete(searchPage(
      offset: 0,
      items: <FileItem>[item('/stale/result')],
      finished: true,
      total: 1,
    ));
    await pending;

    expect(controller.phase, FileSearchPhase.idle);
    expect(controller.items, isEmpty);
    expect(controller.taskId, isNull);
    controller.dispose();
  });
}
