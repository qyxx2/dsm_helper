import 'dart:async';

import 'package:dsm_helper/new_ui/files/file_search_controller.dart';
import 'package:dsm_helper/new_ui/files/file_search_data_source.dart'
    as search_data;
import 'package:flutter/material.dart';

class FileSearchPage extends StatefulWidget {
  const FileSearchPage({
    super.key,
    required this.contextId,
    required this.folderPath,
    required this.onOpenNotifications,
    this.connectionStatusText,
    this.dataSource,
    this.onReauthNeeded,
  });

  final String contextId;
  final String folderPath;
  final VoidCallback onOpenNotifications;
  final String? connectionStatusText;
  final search_data.FileSearchDataSource? dataSource;
  final VoidCallback? onReauthNeeded;

  @override
  State<FileSearchPage> createState() => _FileSearchPageState();
}

class _FileSearchPageState extends State<FileSearchPage> {
  final TextEditingController _query = TextEditingController();
  final FocusNode _queryFocus = FocusNode();
  late final FileSearchController _controller;
  bool _active = true;
  bool _recursive = true;
  bool _searchContent = false;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    final source = widget.dataSource ??
        search_data.FileSearchDataSource.production(
          contextId: widget.contextId,
          isContextCurrent: () => _active,
        );
    _controller = FileSearchController(
      dataSource: source,
      contextId: widget.contextId,
      folderPath: widget.folderPath,
      onReauthNeeded: widget.onReauthNeeded,
    );
    _queryFocus.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _active = false;
    _queryFocus.removeListener(_onFocusChanged);
    _queryFocus.dispose();
    _query.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _query.text.trim();
    if (value.isEmpty) {
      setState(() => _validationMessage = '请输入搜索内容');
      return;
    }
    setState(() => _validationMessage = null);
    unawaited(_controller.search(
      value,
      recursive: _recursive,
      searchContent: _searchContent,
    ));
  }

  void _retry() {
    setState(() => _validationMessage = null);
    unawaited(_controller.retry());
  }

  Widget _resultList() {
    final rows = _controller.items;
    return ListView.separated(
      key: const Key('file-search-results'),
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = rows[index];
        final path = item.path!;
        final name = item.name?.isNotEmpty == true ? item.name! : path;
        return ListTile(
          key: Key('file-search-result:$path'),
          title: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(path, maxLines: 2, overflow: TextOverflow.ellipsis),
        );
      },
    );
  }

  Widget _errorBanner(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          TextButton(
            key: const Key('file-search-retry'),
            onPressed: _retry,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _contents() {
    final phase = _controller.phase;
    final rows = _controller.items;

    if (phase == FileSearchPhase.idle) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '搜索范围：${widget.folderPath}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if ((phase == FileSearchPhase.starting ||
            phase == FileSearchPhase.searching) &&
        rows.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (phase == FileSearchPhase.empty) {
      return const Center(child: Text('没有搜索结果'));
    }

    Widget? banner;
    var showProgress = false;
    if (phase == FileSearchPhase.complete) {
      banner = Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('搜索完成 · ${rows.length} 项'),
        ),
      );
    } else if (phase == FileSearchPhase.incomplete) {
      banner = _errorBanner('搜索结果可能不完整');
    } else if (phase == FileSearchPhase.offline) {
      banner = _errorBanner('无网络连接');
    } else if (phase == FileSearchPhase.reauthNeeded) {
      banner = _errorBanner('需要重新登录');
    } else if (phase == FileSearchPhase.unavailable) {
      banner = _errorBanner('搜索失败');
    } else if (phase == FileSearchPhase.partial ||
        phase == FileSearchPhase.starting ||
        phase == FileSearchPhase.searching) {
      showProgress = true;
    }

    if (rows.isEmpty && banner != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [banner],
      );
    }

    return Column(
      children: [
        if (banner != null) banner,
        if (showProgress) const LinearProgressIndicator(),
        Expanded(child: _resultList()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return PopScope(
          canPop: !_queryFocus.hasFocus,
          onPopInvoked: (didPop) {
            if (!didPop && _queryFocus.hasFocus) {
              _queryFocus.unfocus();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  const Flexible(
                    child: Text(
                      '搜索',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.connectionStatusText != null) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.connectionStatusText!,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                IconButton(
                  key: const Key('new-ui-notifications'),
                  tooltip: '通知',
                  onPressed: widget.onOpenNotifications,
                  icon: const Icon(Icons.notifications_outlined),
                ),
              ],
            ),
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const Key('file-search-query'),
                            controller: _query,
                            focusNode: _queryFocus,
                            autofocus: true,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _submit(),
                            decoration: const InputDecoration(
                              hintText: '搜索当前文件夹',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          key: const Key('file-search-submit'),
                          tooltip: '搜索',
                          onPressed: _submit,
                          icon: const Icon(Icons.search),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          FilterChip(
                            key: const Key('file-search-recursive'),
                            label: const Text('包含子文件夹'),
                            selected: _recursive,
                            onSelected: (value) {
                              setState(() => _recursive = value);
                            },
                          ),
                          FilterChip(
                            key: const Key('file-search-content'),
                            label: const Text('搜索文件内容'),
                            selected: _searchContent,
                            onSelected: (value) {
                              setState(() => _searchContent = value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_validationMessage != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _validationMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  const Divider(height: 1),
                  Expanded(child: _contents()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
