import 'dart:async';

import 'package:dsm_helper/models/Syno/FileStation/FileStationList.dart';
import 'package:dsm_helper/new_ui/files/file_browse_breadcrumb.dart';
import 'package:dsm_helper/new_ui/files/file_browse_controller.dart';
import 'package:dsm_helper/new_ui/files/file_browse_data_source.dart';
import 'package:dsm_helper/new_ui/files/file_browse_path.dart';
import 'package:dsm_helper/new_ui/files/file_browse_preferences.dart';
import 'package:dsm_helper/new_ui/files/file_browse_row.dart';
import 'package:dsm_helper/new_ui/files/file_browse_selection_bar.dart';
import 'package:dsm_helper/new_ui/files/file_search_data_source.dart' show FileSearchDataSource;
import 'package:dsm_helper/new_ui/files/file_search_page.dart';
import 'package:dsm_helper/pages/file/enums/list_type_enums.dart';
import 'package:dsm_helper/pages/file/enums/sort_enums.dart';
import 'package:flutter/material.dart';

/// An isolated, read-only directory route. The host tab Navigator owns it.
class FileBrowsePage extends StatefulWidget {
  const FileBrowsePage({
    super.key,
    required this.contextId,
    required this.onOpenNotifications,
    this.connectionStatusText,
    this.dataSource,
    this.searchDataSource,
    this.path,
    this.ancestors = const <FileBrowseAncestor>[],
    this.onReauthNeeded,
  });

  final String contextId;
  final String? path;
  final List<FileBrowseAncestor> ancestors;
  final FileBrowseDataSource? dataSource;
  final FileSearchDataSource? searchDataSource;
  final VoidCallback onOpenNotifications;
  final String? connectionStatusText;
  final VoidCallback? onReauthNeeded;

  @override
  State<FileBrowsePage> createState() => _FileBrowsePageState();
}

class _FileBrowsePageState extends State<FileBrowsePage> {
  final SpUtilFileBrowsePreferencesStore _preferences =
      SpUtilFileBrowsePreferencesStore();
  final ScrollController _scrollController = ScrollController();
  late FileBrowsePreferences _viewPreferences;
  late FileBrowseController _controller;
  bool _paging = false;

  @override
  void initState() {
    super.initState();
    _viewPreferences = _preferences.load();
    _controller = FileBrowseController(
      dataSource: widget.dataSource ?? FileBrowseDataSource.production(),
      contextId: widget.contextId,
      path: widget.path,
      sortBy: _viewPreferences.sortBy,
      sortDirection: _viewPreferences.direction,
      onReauthNeeded: widget.onReauthNeeded,
    );
    _scrollController.addListener(_onScroll);
    unawaited(_controller.loadInitial());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _paging ||
        !_controller.hasMore || _controller.error != null ||
        _controller.phase == FileBrowsePhase.initial ||
        _controller.phase == FileBrowsePhase.loading ||
        _controller.phase == FileBrowsePhase.refreshing) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 180) return;
    _loadMore();
  }

  void _loadMore() {
    if (_paging || !_controller.hasMore) return;
    _paging = true;
    unawaited(_controller.loadNext().whenComplete(() {
      _paging = false;
    }));
  }

  Future<void> _changeView() async {
    final next = _viewPreferences.view == ListType.list
        ? ListType.grid : ListType.list;
    try {
      await _preferences.saveView(next);
      if (!mounted) return;
      setState(() {
        _viewPreferences = FileBrowsePreferences(
          view: next,
          sortBy: _viewPreferences.sortBy,
          direction: _viewPreferences.direction,
        );
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法保存文件视图设置')),
      );
    }
  }

  Future<void> _changeSort(String command) async {
    final by = command == 'direction'
        ? _viewPreferences.sortBy
        : SortByEnum.fromValue(command);
    final direction = command == 'direction'
        ? (_viewPreferences.direction == SortDirectionEnum.ASC
            ? SortDirectionEnum.DESC : SortDirectionEnum.ASC)
        : _viewPreferences.direction;
    try {
      await _preferences.saveSort(by, direction);
      if (!mounted) return;
      setState(() {
        _viewPreferences = FileBrowsePreferences(
          view: _viewPreferences.view, sortBy: by, direction: direction,
        );
      });
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      unawaited(_controller.changeSort(by, direction));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法保存文件排序设置')),
      );
    }
  }

  List<FileBrowseAncestor> get _breadcrumbTrail {
    final matches = widget.ancestors.where((a) => a.path == widget.path);
    final label = widget.path == null
        ? '共享文件夹'
        : (matches.isEmpty ? widget.path! : matches.last.label);
    return buildBrowseAncestors(
      visited: widget.ancestors,
      current: FileBrowseAncestor(label: label, path: widget.path),
    );
  }

  void _navigateToAncestor(FileBrowseAncestor ancestor) {
    final trail = _breadcrumbTrail;
    // Targets come only from the verified visited route chain.
    if (ancestor.path == widget.path ||
        !trail.take(trail.length - 1).any((a) => a.path == ancestor.path)) {
      return;
    }
    final navigator = Navigator.of(context);
    final target = ancestor.path;
    if (target == null) {
      navigator.popUntil(
        (route) => route.isFirst || route.settings.name == 't7a-file-root',
      );
    } else {
      navigator.popUntil(
        (route) =>
            route.settings.name == 't7a-folder:$target' || route.isFirst,
      );
    }
  }

  void _openFolder(FileItem item) {
    final path = item.path;
    // Only DSM-returned nonempty folder paths may produce a child route.
    if (item.isdir != true || path == null || path.isEmpty ||
        path == widget.path) {
      return;
    }
    final trail = _breadcrumbTrail;
    // A returned folder already in the stack is a jump, not a new route.
    for (final ancestor in trail.take(trail.length - 1)) {
      if (ancestor.path == path) {
        _navigateToAncestor(ancestor);
        return;
      }
    }
    _controller.onLeaveDirectory();
    final current = FileBrowseAncestor(
      label: item.name?.isNotEmpty == true ? item.name! : path,
      path: path,
    );
    unawaited(Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        settings: RouteSettings(name: 't7a-folder:$path'),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => FileBrowsePage(
          contextId: widget.contextId,
          onOpenNotifications: widget.onOpenNotifications,
          connectionStatusText: widget.connectionStatusText,
          dataSource: widget.dataSource,
          searchDataSource: widget.searchDataSource,
          path: path,
          ancestors: <FileBrowseAncestor>[...trail, current],
          onReauthNeeded: widget.onReauthNeeded,
        ),
      ),
    ));
  }

  void _openSearch() {
    final path = widget.path;
    if (path == null || path.isEmpty) return;
    unawaited(Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        settings: RouteSettings(name: 't7b-search:$path'),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => FileSearchPage(
          contextId: widget.contextId,
          folderPath: path,
          dataSource: widget.searchDataSource,
          onOpenNotifications: widget.onOpenNotifications,
          connectionStatusText: widget.connectionStatusText,
          onReauthNeeded: widget.onReauthNeeded,
        ),
      ),
    ));
  }

  void _retry() {
    if (_controller.error != null && _controller.visibleItems.isNotEmpty &&
        _controller.phase == FileBrowsePhase.partial) {
      _loadMore();
    } else {
      unawaited(_controller.refresh());
    }
  }

  Widget _contents() {
    final rows = _controller.visibleItems;
    // Copy selection once per rebuild, not once for every lazily built row.
    final selectedPaths = _controller.selectedPaths;
    final phase = _controller.phase;
    if (phase == FileBrowsePhase.loading ||
        phase == FileBrowsePhase.initial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (rows.isEmpty && _controller.isComplete &&
        phase == FileBrowsePhase.valid) {
      return Center(child: Text(
        widget.path == null ? '无共享文件夹' : '暂无文件',
      ));
    }
    if (rows.isEmpty && _controller.error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_errorLabel(phase)),
          const SizedBox(height: 8),
          TextButton(
            key: const Key('file-browse-retry'),
            onPressed: _retry, child: const Text('重试')),
        ]),
      );
    }
    Widget itemBuilder(BuildContext context, int index) {
      return FileBrowseRow(
        key: Key('file-browse-item:${rows[index].path ?? index}'),
        item: rows[index],
        grid: _viewPreferences.view == ListType.grid,
        onOpenFolder: _openFolder,
        selectionMode: _controller.isSelectionMode,
        selected: rows[index].path != null &&
            selectedPaths.contains(rows[index].path),
        selectable: widget.path != null,
        onSelect: (item) {
          final path = item.path;
          if (path != null) _controller.selectPath(path);
        },
        onToggle: (item) {
          final path = item.path;
          if (path != null) _controller.togglePath(path);
        },
      );
    }
    if (_viewPreferences.view == ListType.grid) {
      return RefreshIndicator(
        onRefresh: _controller.refresh,
        child: GridView.builder(
          key: const Key('file-browse-scroll'),
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 144,
            mainAxisExtent: 142,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: rows.length,
          itemBuilder: itemBuilder,
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _controller.refresh,
      child: ListView.builder(
        key: const Key('file-browse-scroll'),
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: rows.length,
        itemBuilder: itemBuilder,
      ),
    );
  }

  String _errorLabel(FileBrowsePhase phase) => switch (phase) {
    FileBrowsePhase.offline => '无网络连接',
    FileBrowsePhase.reauthNeeded => '需要重新登录',
    FileBrowsePhase.stale => '刷新失败，显示上次读取的文件',
    FileBrowsePhase.partial => '文件列表尚未加载完整',
    _ => '无法读取文件',
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final phase = _controller.phase;
        return PopScope(
          canPop: !_controller.isSelectionMode,
          onPopInvoked: (didPop) {
            if (!didPop && _controller.isSelectionMode) {
              _controller.clearSelection();
            }
          },
          child: Scaffold(
          appBar: _controller.isSelectionMode
              ? FileBrowseSelectionBar(
                  selectedCount: _controller.selectedPaths.length,
                  isComplete: _controller.isComplete,
                  onExit: _controller.clearSelection,
                  onSelectLoaded: _controller.selectLoaded,
                )
              : AppBar(
            title: Row(children: [
              const Flexible(child: Text('文件', maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
              if (widget.connectionStatusText != null) ...[
                const SizedBox(width: 8),
                Flexible(child: Text(widget.connectionStatusText!,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelMedium)),
              ],
            ]),
            actions: [
              IconButton(
                key: const Key('file-browse-search'),
                tooltip: widget.path == null ? '搜索仅支持文件夹' : '搜索当前文件夹',
                onPressed: widget.path == null ? null : _openSearch,
                icon: const Icon(Icons.search_outlined),
              ),
              IconButton(
                key: const Key('new-ui-notifications'),
                tooltip: '通知',
                onPressed: widget.onOpenNotifications,
                icon: const Icon(Icons.notifications_outlined),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: Row(children: [
                  Expanded(child: FileBrowseBreadcrumb(
                    ancestors: _breadcrumbTrail,
                    onNavigate: _navigateToAncestor,
                  )),
                  PopupMenuButton<String>(
                    key: const Key('file-browse-sort'),
                    popUpAnimationStyle: AnimationStyle.noAnimation,
                    tooltip: '排序',
                    icon: const Icon(Icons.sort_outlined),
                    onSelected: (command) => unawaited(_changeSort(command)),
                    itemBuilder: (_) => <PopupMenuEntry<String>>[
                      for (final by in SortByEnum.values)
                        PopupMenuItem<String>(
                          value: by.name,
                          child: Text(by.label),
                        ),
                      PopupMenuItem<String>(
                        value: 'direction',
                        child: Text(
                          '排序方向：${_viewPreferences.direction.label}',
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    key: const Key('file-browse-view-toggle'),
                    tooltip: _viewPreferences.view == ListType.list
                        ? '切换网格' : '切换列表',
                    onPressed: () => unawaited(_changeView()),
                    icon: Icon(_viewPreferences.view == ListType.list
                        ? Icons.grid_view_outlined : Icons.view_list_outlined),
                  ),
                ]),
              ),
              if (phase == FileBrowsePhase.refreshing)
                const LinearProgressIndicator(),
              if (phase == FileBrowsePhase.stale ||
                  phase == FileBrowsePhase.partial ||
                  (phase == FileBrowsePhase.reauthNeeded &&
                      _controller.visibleItems.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    Expanded(child: Text(_errorLabel(phase),
                      style: Theme.of(context).textTheme.bodySmall)),
                    TextButton(
                      key: const Key('file-browse-retry'),
                      onPressed: _retry, child: const Text('重试')),
                  ]),
                ),
              Expanded(child: _contents()),
            ],
          ),
        ),
        );
      },
    );
  }
}
