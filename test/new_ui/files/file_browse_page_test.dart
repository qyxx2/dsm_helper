import 'package:dio/dio.dart';
import 'package:dsm_helper/models/Syno/FileStation/FileStationList.dart';
import 'package:dsm_helper/new_ui/files/file_browse_data_source.dart';
import 'package:dsm_helper/new_ui/files/file_browse_page.dart';
import 'package:dsm_helper/new_ui/files/file_browse_row.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_util/sp_util.dart';

FileBrowseDataSource testSource(
  Future<FileStationList> Function(String? path, int offset) fetch,
  List<String> requests,
) => FileBrowseDataSource(
      loadShares: ({
        required offset,
        required limit,
        required sortBy,
        required sortDirection,
      }) {
        requests.add('root:$offset:$limit:$sortBy:$sortDirection');
        return fetch(null, offset);
      },
      loadFolder: ({
        required path,
        required offset,
        required limit,
        required sortBy,
        required sortDirection,
      }) {
        requests.add('$path:$offset:$limit:$sortBy:$sortDirection');
        return fetch(path, offset);
      },
    );

FileItem browseItem(String name, String? path, {bool directory = false}) =>
    FileItem(name: name, path: path, isdir: directory);

Widget browser(
  FileBrowseDataSource source, {
  String? path,
  ThemeData? theme,
  double scale = 1,
  VoidCallback? onReauthNeeded,
}) => MaterialApp(
      theme: theme ?? NewUiTheme.light(),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: FileBrowsePage(
          contextId: 'NAS-A/account',
          dataSource: source,
          path: path,
          onOpenNotifications: () {},
          onReauthNeeded: onReauthNeeded,
        ),
      ),
    );

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await SpUtil.getInstance();
  });

  testWidgets('root loads shares, handles nullable metadata and navigable rows',
      (tester) async {
    final requests = <String>[];
    final source = testSource((path, offset) async => FileStationList(
      files: [
        browseItem('影音与中文 电影资料夹', '/volume share/影音', directory: true),
        browseItem('没有路径的资料', null),
      ],
      offset: offset,
      total: 2,
    ), requests);
    await tester.pumpWidget(browser(source));
    await tester.pump();
    expect(requests, ['root:0:100:name:ASC']);
    expect(find.text('影音与中文 电影资料夹'), findsOneWidget);
    expect(find.text('没有路径的资料'), findsOneWidget);
    expect(find.byKey(const Key('file-browse-view-toggle')), findsOneWidget);
    expect(find.byKey(const Key('new-ui-notifications')), findsOneWidget);
    expect(find.byType(Card), findsNothing);
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('list/grid render same paths in light/dark with scaled Unicode labels',
      (tester) async {
    final requests = <String>[];
    final source = testSource((path, offset) async => FileStationList(
      files: [
        browseItem('很长很长的中文与 Unicode 文件名称 2026.flac', '/share/2026.flac'),
        browseItem('目录', '/share/目录', directory: true),
      ],
      offset: offset,
      total: 2,
    ), requests);
    await tester.pumpWidget(browser(source, path: '/share',
        theme: NewUiTheme.dark(), scale: 1.6));
    await tester.pump();
    expect(find.text('目录'), findsOneWidget);
    expect(find.text('很长很长的中文与 Unicode 文件名称 2026.flac'), findsOneWidget);
    expect(find.byType(Card), findsNothing);
    await tester.tap(find.byKey(const Key('file-browse-view-toggle')));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('目录'), findsOneWidget);
    expect(find.text('很长很长的中文与 Unicode 文件名称 2026.flac'),
        findsOneWidget);
    expect(requests, hasLength(1)); // View changes do not refetch or sort.
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('valid empty differs from first-request offline failure and retry',
      (tester) async {
    final requests = <String>[];
    var unavailable = true;
    final source = testSource((path, offset) async {
      if (unavailable) {
        throw DioException(
          requestOptions: RequestOptions(path: '/file-station'),
          type: DioExceptionType.connectionError,
        );
      }
      return FileStationList(files: [], offset: offset, total: 0);
    }, requests);
    await tester.pumpWidget(browser(source, path: '/share'));
    await tester.pump();
    expect(find.text('无网络连接'), findsWidgets);
    expect(find.byKey(const Key('file-browse-retry')), findsOneWidget);
    expect(find.text('暂无文件'), findsNothing);
    unavailable = false;
    await tester.tap(find.byKey(const Key('file-browse-retry')));
    await tester.pump();
    expect(find.text('暂无文件'), findsOneWidget);
    expect(requests, hasLength(2));
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('incremental paging waits for scroll and requests next offset once',
      (tester) async {
    final requests = <String>[];
    final source = testSource((path, offset) async {
      final count = offset == 0 ? 100 : 1;
      return FileStationList(
        files: List<FileItem>.generate(count, (i) =>
          browseItem('item-${offset + i}', '/share/${offset + i}')),
        offset: offset,
        total: 101,
      );
    }, requests);
    await tester.pumpWidget(browser(source, path: '/share'));
    await tester.pump();
    expect(requests, ['/share:0:100:name:ASC']);
    expect(find.text('加载更多'), findsNothing);
    expect(find.byKey(const Key('file-browse-load-more')), findsNothing);
    expect(find.byType(FileBrowseRow).evaluate().length, lessThan(40));
    await tester.drag(find.byKey(const Key('file-browse-scroll')),
        const Offset(0, -6000));
    await tester.pump();
    await tester.pump();
    expect(requests, ['/share:0:100:name:ASC', '/share:100:100:name:ASC']);
    expect(find.text('item-100'), findsWidgets);
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('verified folder pushes nested routes; file remains read-only; crumb pops existing ancestor',
      (tester) async {
    final requests = <String>[];
    final source = testSource((path, offset) async {
      final files = switch (path) {
        null => [browseItem('共享 A', '/share', directory: true)],
        '/share' => [
          browseItem('深入子目录', '/share/sub', directory: true),
          browseItem('不可预览.flac', '/share/song.flac'),
        ],
        '/share/sub' => [browseItem('最深文件.txt', '/share/sub/f.txt')],
        _ => <FileItem>[],
      };
      return FileStationList(files: files, offset: offset, total: files.length);
    }, requests);
    await tester.pumpWidget(MaterialApp(home: FileBrowsePage(
      contextId: 'NAS-A/account',
      dataSource: source,
      onOpenNotifications: () {},
    )));
    await tester.pump();
    await tester.tap(find.text('共享 A'));
    await tester.pumpAndSettle();
    expect(requests, contains('/share:0:100:name:ASC'));
    expect(find.text('不可预览.flac'), findsOneWidget);
    await tester.tap(find.text('不可预览.flac'));
    await tester.pump();
    expect(requests, hasLength(2));
    await tester.tap(find.text('深入子目录'));
    await tester.pumpAndSettle();
    expect(requests, contains('/share/sub:0:100:name:ASC'));
    expect(find.text('最深文件.txt'), findsOneWidget);
    expect(find.byKey(const Key('file-browse-crumb:root')), findsOneWidget);
    expect(find.byKey(const Key('file-browse-crumb:/share')), findsOneWidget);
    await tester.tap(find.byKey(const Key('file-browse-crumb:/share')));
    await tester.pumpAndSettle();
    expect(find.text('不可预览.flac'), findsOneWidget);
    expect(find.text('最深文件.txt'), findsNothing);
    expect(requests, hasLength(3)); // Parent retained its completed snapshot.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('共享 A'), findsOneWidget);
    expect(requests, hasLength(3));
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('Android Back pops one directory and preserves parent scroll position',
      (tester) async {
    final requests = <String>[];
    final source = testSource((path, offset) async {
      final files = path == null
          ? List<FileItem>.generate(
              40, (i) => browseItem('共享-$i', '/share-$i', directory: true))
          : <FileItem>[browseItem('子文件', '$path/file')];
      return FileStationList(files: files, offset: offset, total: files.length);
    }, requests);
    await tester.pumpWidget(browser(source));
    await tester.pump();
    final scrollable = find.descendant(
      of: find.byKey(const Key('file-browse-scroll')),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('共享-12'), 180, scrollable: scrollable,
    );
    await tester.pump();
    final scroll = tester.state<ScrollableState>(scrollable);
    final before = scroll.position.pixels;
    expect(before, greaterThan(0));
    await tester.tap(find.text('共享-12'));
    await tester.pumpAndSettle();
    expect(find.text('子文件'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('子文件'), findsNothing);
    expect(find.text('共享-12'), findsOneWidget);
    final restored = tester.state<ScrollableState>(find.descendant(
      of: find.byKey(const Key('file-browse-scroll')),
      matching: find.byType(Scrollable),
    ));
    expect(restored.position.pixels, closeTo(before, 1));
    expect(requests, hasLength(2));
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('horizontal swipe selects exact files; selection tap, view toggle and Back priority',
      (tester) async {
    await SpUtil.putString('file_list_type', 'list');
    final requests = <String>[];
    final source = testSource((path, offset) async => FileStationList(
      files: [
        browseItem('One.txt', '/share/one'),
        browseItem('Two.txt', '/share/two'),
        browseItem('Subfolder', '/share/sub', directory: true),
      ], offset: offset, total: 3), requests);
    await tester.pumpWidget(browser(source, path: '/share'));
    await tester.pump();
    await tester.drag(find.text('One.txt'), const Offset(180, 0));
    await tester.pump();
    expect(find.byKey(const Key('file-browse-selection-count')), findsOneWidget);
    expect(find.text('已选择 1 项'), findsOneWidget);
    expect(find.byKey(const Key('new-ui-notifications')), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
    await tester.tap(find.text('Two.txt'));
    await tester.pump();
    expect(find.text('已选择 2 项'), findsOneWidget);
    await tester.tap(find.text('One.txt'));
    await tester.pump();
    expect(find.text('已选择 1 项'), findsOneWidget);
    await tester.tap(find.byKey(const Key('file-browse-view-toggle')));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('已选择 1 项'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('file-browse-selection-count')), findsNothing);
    expect(find.byKey(const Key('new-ui-notifications')), findsOneWidget);
    expect(find.text('Subfolder'), findsOneWidget);
    expect(requests, hasLength(1));
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('share-root swipe does not select; folder route selection Back stays inside child',
      (tester) async {
    await SpUtil.putString('file_list_type', 'list');
    final requests = <String>[];
    final source = testSource((path, offset) async {
      final files = path == null
          ? [browseItem('Share', '/share', directory: true)]
          : [browseItem('Child.txt', '/share/child')];
      return FileStationList(files: files, offset: offset, total: files.length);
    }, requests);
    await tester.pumpWidget(browser(source));
    await tester.pump();
    await tester.drag(find.text('Share'), const Offset(180, 0));
    await tester.pump();
    expect(find.byKey(const Key('file-browse-selection-count')), findsNothing);
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();
    await tester.drag(find.text('Child.txt'), const Offset(-180, 0));
    await tester.pump();
    expect(find.text('已选择 1 项'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Child.txt'), findsOneWidget);
    expect(find.byKey(const Key('file-browse-selection-count')), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Share'), findsOneWidget);
    expect(requests, hasLength(2));
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('dark scaled grid swipe selects without checkbox gutter',
      (tester) async {
    await SpUtil.putString('file_list_type', 'grid');
    final requests = <String>[];
    final source = testSource((path, offset) async => FileStationList(
      files: [browseItem('中文名字很长的文件.txt', '/share/中文.txt')],
      offset: offset, total: 1,
    ), requests);
    await tester.pumpWidget(browser(source, path: '/share',
        theme: NewUiTheme.dark(), scale: 1.6));
    await tester.pump();
    expect(find.byType(GridView), findsOneWidget);
    await tester.drag(find.text('中文名字很长的文件.txt'), const Offset(150, 0));
    await tester.pump();
    expect(find.text('已选择 1 项'), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
    await tester.tap(find.byKey(const Key('file-browse-selection-exit')));
    await tester.pump();
    expect(find.byKey(const Key('file-browse-selection-count')), findsNothing);
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('paged select-loaded header counts 100 then 250 without auto selecting',
      (tester) async {
    await SpUtil.putString('file_list_type', 'list');
    final requests = <String>[];
    final source = testSource((path, offset) async => FileStationList(
      files: List<FileItem>.generate(offset == 200 ? 50 : 100, (i) =>
        browseItem('item-${offset + i}', '/share/${offset + i}')),
      offset: offset, total: 250,
    ), requests);
    await tester.pumpWidget(browser(source, path: '/share'));
    await tester.pump();
    await tester.drag(find.text('item-0'), const Offset(180, 0));
    await tester.pump();
    expect(find.text('已加载项全选'), findsOneWidget);
    expect(find.text('已选择 1 项'), findsOneWidget);
    await tester.tap(find.byKey(const Key('file-browse-select-loaded')));
    await tester.pump();
    expect(find.text('已选择 100 项'), findsOneWidget);
    expect(find.text('加载更多'), findsNothing);
    await tester.drag(find.byKey(const Key('file-browse-scroll')),
        const Offset(0, -6000));
    await tester.pump();
    await tester.pump();
    expect(requests.map((r) => r.split(':')[1]).toList(), [ '0', '100' ]);
    expect(find.text('已选择 100 项'), findsOneWidget);
    expect(find.text('已加载项全选'), findsOneWidget);
    await tester.drag(find.byKey(const Key('file-browse-scroll')),
        const Offset(0, -6000));
    await tester.pump();
    await tester.pump();
    expect(requests.map((r) => r.split(':')[1]).toList(),
        ['0', '100', '200']);
    expect(find.text('已选择 100 项'), findsOneWidget);
    expect(find.text('全选'), findsOneWidget);
    await tester.tap(find.byKey(const Key('file-browse-select-loaded')));
    await tester.pump();
    expect(find.text('已选择 250 项'), findsOneWidget);
    await tester.tap(find.byKey(const Key('file-browse-selection-exit')));
    await tester.pump();
    expect(find.byKey(const Key('file-browse-selection-count')), findsNothing);
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));
  testWidgets('selected grid tiles retain a visible tonal surface without a checkbox',
      (tester) async {
    await SpUtil.putString('file_list_type', 'grid');
    final requests = <String>[];
    final source = testSource((path, offset) async => FileStationList(
      files: [
        browseItem('Folder', '/share/folder', directory: true),
        browseItem('Item.txt', '/share/item'),
      ], offset: offset, total: 2,
    ), requests);
    final theme = NewUiTheme.dark();
    await tester.pumpWidget(browser(source, path: '/share', theme: theme));
    await tester.pump();
    await tester.drag(find.text('Folder'), const Offset(160, 0));
    await tester.pump();
    expect(find.text('已选择 1 项'), findsOneWidget);
    expect(requests, hasLength(1)); // Swiping a folder does not navigate.
    expect(find.byType(Checkbox), findsNothing);
    final selectedRow = find.ancestor(
      of: find.text('Folder'),
      matching: find.byType(FileBrowseRow),
    );
    final selectedSurface = find.descendant(
      of: selectedRow, matching: find.byType(Material),
    );
    expect(selectedSurface, findsOneWidget,
      reason: 'Persistent selected tile needs its own colored surface');
    expect(tester.widget<Material>(selectedSurface).color,
        theme.colorScheme.secondaryContainer);
    await tester.tap(find.text('Folder'));
    await tester.pump();
    expect(find.text('已选择 0 项'), findsOneWidget);
    expect(tester.widget<Material>(selectedSurface).color,
        isNot(theme.colorScheme.secondaryContainer));
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));


  testWidgets('folder entry and Back skip Android zoom and transition frames',
      (tester) async {
    await SpUtil.putString('file_list_type', 'list');
    final requests = <String>[];
    final source = testSource((path, offset) async {
      final rows = path == null
          ? <FileItem>[browseItem('文件夹', '/share', directory: true)]
          : <FileItem>[browseItem('立即显示.txt', '/share/file')];
      return FileStationList(files: rows, offset: offset, total: rows.length);
    }, requests);
    await tester.pumpWidget(browser(source));
    await tester.pump();
    await tester.tap(find.text('文件夹'));
    await tester.pumpAndSettle();
    expect(find.text('立即显示.txt'), findsOneWidget);
    final route = ModalRoute.of(tester.element(find.text('立即显示.txt')))!;
    expect(route, isA<PageRouteBuilder<void>>());
    expect(route.transitionDuration, Duration.zero);
    expect(route.reverseTransitionDuration, Duration.zero);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('文件夹'), findsOneWidget);
    expect(find.text('立即显示.txt'), findsNothing);
    expect(requests, hasLength(2));
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('file sort popup opens and closes without scale/fade animation',
      (tester) async {
    await SpUtil.putString('file_list_type', 'list');
    final requests = <String>[];
    final source = testSource((path, offset) async =>
        FileStationList(
          files: [browseItem('entry.txt', '/share/entry.txt')],
          offset: offset, total: 1,
        ), requests);
    await tester.pumpWidget(browser(source, path: '/share'));
    await tester.pump();
    final button = tester.widget<PopupMenuButton<String>>(
      find.byKey(const Key('file-browse-sort')),
    );
    expect(button.popUpAnimationStyle, same(AnimationStyle.noAnimation));
    await tester.tap(find.byKey(const Key('file-browse-sort')));
    await tester.pump();
    expect(find.textContaining('排序方向：'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.textContaining('排序方向：'), findsNothing);
    expect(find.text('entry.txt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));


  testWidgets('folder AppBar exposes direct search, root disables it, and sort stays secondary',
      (tester) async {
    final requests = <String>[];
    final source = testSource((path, offset) async => FileStationList(
      files: <FileItem>[],
      offset: offset,
      total: 0,
    ), requests);

    await tester.pumpWidget(browser(source, path: '/share'));
    await tester.pump();
    final folderSearch = tester.widget<IconButton>(
      find.byKey(const Key('file-browse-search')),
    );
    expect(folderSearch.onPressed, isNotNull);
    expect(find.descendant(
      of: find.byType(AppBar),
      matching: find.byKey(const Key('file-browse-search')),
    ), findsOneWidget);
    expect(find.descendant(
      of: find.byType(AppBar),
      matching: find.byKey(const Key('file-browse-sort')),
    ), findsNothing);
    expect(find.byKey(const Key('file-browse-sort')), findsOneWidget);
    expect(find.byKey(const Key('new-ui-notifications')), findsOneWidget);

    await tester.pumpWidget(browser(source));
    await tester.pump();
    final rootSearch = tester.widget<IconButton>(
      find.byKey(const Key('file-browse-search')),
    );
    expect(rootSearch.onPressed, isNull,
      reason: 'Search root scope is not verified in Task 7B Batch 2');
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));

}
