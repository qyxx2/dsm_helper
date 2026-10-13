import 'package:dio/dio.dart';
import 'package:dsm_helper/models/Syno/FileStation/FileStationList.dart';
import 'package:dsm_helper/new_ui/files/file_search_data_source.dart' as search_data;
import 'package:dsm_helper/new_ui/files/file_search_page.dart' as search_ui;
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _StartHandler = Future<search_data.FileSearchStart> Function({
  required String folderPath,
  required String pattern,
  required bool recursive,
  required bool searchContent,
});

typedef _PageHandler = Future<search_data.FileSearchPage> Function({
  required String taskId,
  required int offset,
  required int limit,
});

class _FakeSearchSource extends search_data.FileSearchDataSource {
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
  Future<search_data.FileSearchStart> startSearch({
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
  Future<search_data.FileSearchPage> loadPage({
    required String taskId,
    required int offset,
    required int limit,
  }) => onPage(taskId: taskId, offset: offset, limit: limit);
}

FileItem resultItem(String name, String path) =>
    FileItem(name: name, path: path, isdir: false);

search_ui.FileSearchPage searchPage(
  search_data.FileSearchDataSource source, {
  VoidCallback? onNotifications,
}) => search_ui.FileSearchPage(
  contextId: 'NAS-A/account',
  folderPath: '/share/music',
  dataSource: source,
  onOpenNotifications: onNotifications ?? () {},
);

Widget app(
  search_data.FileSearchDataSource source, {
  ThemeData? theme,
  double scale = 1,
}) => MaterialApp(
  theme: theme ?? NewUiTheme.light(),
  home: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
    child: searchPage(source),
  ),
);

void main() {
  testWidgets(
    'IME search preserves exact folder and flags, renders exact paths without preview or selection',
    (tester) async {
      String? folder;
      String? query;
      bool? recursiveFlag;
      bool? contentFlag;
      final source = _FakeSearchSource(
        onStart: ({
          required folderPath,
          required pattern,
          required recursive,
          required searchContent,
        }) async {
          folder = folderPath;
          query = pattern;
          recursiveFlag = recursive;
          contentFlag = searchContent;
          return const search_data.FileSearchStart('task-ui');
        },
        onPage: ({
          required taskId,
          required offset,
          required limit,
        }) async => search_data.FileSearchPage(
          offset: 0,
          items: <FileItem>[
            resultItem('So What.flac', '/share/music/So What.flac'),
          ],
          finished: true,
          total: 1,
        ),
      );

      await tester.pumpWidget(app(source));
      await tester.pump();
      expect(find.byKey(const Key('file-search-query')), findsOneWidget);
      expect(find.byKey(const Key('new-ui-notifications')), findsOneWidget);
      await tester.tap(find.byKey(const Key('file-search-content')));
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('file-search-query')),
        '  Miles Davis  ',
      );
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await tester.pump();

      expect(folder, '/share/music');
      expect(query, 'Miles Davis');
      expect(recursiveFlag, isTrue);
      expect(contentFlag, isTrue);
      expect(find.text('So What.flac'), findsOneWidget);
      expect(find.text('/share/music/So What.flac'), findsOneWidget);
      final tile = tester.widget<ListTile>(
        find.byKey(const Key('file-search-result:/share/music/So What.flac')),
      );
      expect(tile.onTap, isNull);
      expect(find.byType(Checkbox), findsNothing);
      expect(find.text('预览'), findsNothing);
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );

  testWidgets('blank query is rejected locally without starting a DSM job',
      (tester) async {
    var starts = 0;
    final source = _FakeSearchSource(
      onStart: ({
        required folderPath,
        required pattern,
        required recursive,
        required searchContent,
      }) async {
        starts++;
        return const search_data.FileSearchStart('unused');
      },
      onPage: ({
        required taskId,
        required offset,
        required limit,
      }) async => const search_data.FileSearchPage(
        offset: 0,
        items: <FileItem>[],
        finished: true,
        total: 0,
      ),
    );

    await tester.pumpWidget(app(source));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('file-search-query')), '   ');
    await tester.tap(find.byKey(const Key('file-search-submit')));
    await tester.pump();

    expect(starts, 0);
    expect(find.text('请输入搜索内容'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('valid empty differs from offline failure and retry can recover',
      (tester) async {
    var starts = 0;
    final source = _FakeSearchSource(
      onStart: ({
        required folderPath,
        required pattern,
        required recursive,
        required searchContent,
      }) async {
        starts++;
        if (starts == 1) {
          throw DioException(
            requestOptions: RequestOptions(path: '/webapi/entry.cgi'),
            type: DioExceptionType.connectionTimeout,
          );
        }
        return const search_data.FileSearchStart('task-retry');
      },
      onPage: ({
        required taskId,
        required offset,
        required limit,
      }) async => search_data.FileSearchPage(
        offset: 0,
        items: <FileItem>[resultItem('Recovered.txt', '/share/music/Recovered.txt')],
        finished: true,
        total: 1,
      ),
    );

    await tester.pumpWidget(app(source));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('file-search-query')), 'x');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    await tester.pump();
    expect(find.text('无网络连接'), findsOneWidget);
    expect(find.byKey(const Key('file-search-retry')), findsOneWidget);

    await tester.tap(find.byKey(const Key('file-search-retry')));
    await tester.pump();
    await tester.pump();
    expect(find.text('Recovered.txt'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    final emptySource = _FakeSearchSource(
      onStart: ({
        required folderPath,
        required pattern,
        required recursive,
        required searchContent,
      }) async => const search_data.FileSearchStart('task-empty'),
      onPage: ({
        required taskId,
        required offset,
        required limit,
      }) async => const search_data.FileSearchPage(
        offset: 0,
        items: <FileItem>[],
        finished: true,
        total: 0,
      ),
    );
    await tester.pumpWidget(app(emptySource));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('file-search-query')), 'none');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    await tester.pump();
    expect(find.text('没有搜索结果'), findsOneWidget);
    expect(find.text('无网络连接'), findsNothing);
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('incomplete search is explicit and never presented as complete',
      (tester) async {
    final source = _FakeSearchSource(
      onStart: ({
        required folderPath,
        required pattern,
        required recursive,
        required searchContent,
      }) async => const search_data.FileSearchStart('task-incomplete'),
      onPage: ({
        required taskId,
        required offset,
        required limit,
      }) async => search_data.FileSearchPage(
        offset: 0,
        items: List<FileItem>.generate(
          101,
          (i) => resultItem('row-$i', '/share/music/$i'),
        ),
        finished: false,
        total: 250,
      ),
    );

    await tester.pumpWidget(app(source));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('file-search-query')), 'x');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    await tester.pump();

    expect(find.text('搜索结果可能不完整'), findsOneWidget);
    expect(find.byKey(const Key('file-search-retry')), findsOneWidget);
    expect(find.textContaining('搜索完成'), findsNothing);
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('Back dismisses focused keyboard before leaving the search route',
      (tester) async {
    final source = _FakeSearchSource(
      onStart: ({
        required folderPath,
        required pattern,
        required recursive,
        required searchContent,
      }) async => const search_data.FileSearchStart('task-back'),
      onPage: ({
        required taskId,
        required offset,
        required limit,
      }) async => const search_data.FileSearchPage(
        offset: 0,
        items: <FileItem>[],
        finished: true,
        total: 0,
      ),
    );

    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) => Scaffold(
        body: Center(child: ElevatedButton(
          key: const Key('open-search'),
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute<void>(builder: (_) => searchPage(source)),
          ),
          child: const Text('Open'),
        )),
      )),
    ));
    await tester.tap(find.byKey(const Key('open-search')));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(
      find.byKey(const Key('file-search-query')),
    );
    expect(field.focusNode?.hasFocus, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('file-search-query')), findsOneWidget);
    expect(field.focusNode?.hasFocus, isFalse);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('file-search-query')), findsNothing);
    expect(find.byKey(const Key('open-search')), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('dark large-text search remains Material 3 and readable',
      (tester) async {
    final source = _FakeSearchSource(
      onStart: ({
        required folderPath,
        required pattern,
        required recursive,
        required searchContent,
      }) async => const search_data.FileSearchStart('task-dark'),
      onPage: ({
        required taskId,
        required offset,
        required limit,
      }) async => search_data.FileSearchPage(
        offset: 0,
        items: <FileItem>[
          resultItem(
            '很长很长的 Unicode 文件名称.flac',
            '/share/music/很长很长的 Unicode 文件名称.flac',
          ),
        ],
        finished: true,
        total: 1,
      ),
    );

    await tester.pumpWidget(app(
      source,
      theme: NewUiTheme.dark(),
      scale: 1.6,
    ));
    await tester.pump();
    expect(Theme.of(tester.element(find.byType(Scaffold))).useMaterial3, isTrue);
    expect(find.byKey(const Key('file-search-query')), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));
}
