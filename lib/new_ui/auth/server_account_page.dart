import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/new_ui/auth/server_account_controller.dart';
import 'package:flutter/material.dart';

/// Standalone management UI. Shell activation/navigation is owned by its caller.
class ServerAccountPage extends StatefulWidget {
  const ServerAccountPage({
    super.key,
    required this.controller,
    this.onSelected,
    this.onAddServer,
    this.onAddAccount,
    this.onEditServer,
  });

  final ServerAccountController controller;
  final ValueChanged<ServerAccountItem>? onSelected;
  final VoidCallback? onAddServer;
  final ValueChanged<Server>? onAddAccount;
  final ValueChanged<Server>? onEditServer;

  @override
  State<ServerAccountPage> createState() => _ServerAccountPageState();
}

class _ServerAccountPageState extends State<ServerAccountPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    _load();
  }

  @override
  void didUpdateWidget(covariant ServerAccountPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
      _load();
    }
  }

  Future<void> _load() async {
    try {
      await widget.controller.load();
    } catch (_) {
      _showError();
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _showError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('服务器/账号操作失败，请重试')),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  String _serverName(Server server) {
    if (server.hostname?.trim().isNotEmpty == true) {
      return server.hostname!;
    }
    if (server.remark.trim().isNotEmpty) return server.remark;
    return server.domain;
  }

  Future<void> _confirmDelete({
    required String title,
    required Future<void> Function() delete,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('删除后无法撤销，确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await delete();
    } catch (_) {
      _showError();
    }
  }

  Future<void> _changeDefault(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      _showError();
    }
  }

  Widget _sheetAction(
    BuildContext sheetContext,
    String label,
    VoidCallback action,
  ) {
    return ListTile(
      title: Text(label),
      onTap: () {
        Navigator.of(sheetContext).pop();
        action();
      },
    );
  }

  void _showActions(ServerAccountItem item) {
    final server = item.server;
    final account = item.account;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetAction(
              sheetContext,
              '编辑服务器',
              () => widget.onEditServer?.call(server),
            ),
            if (account != null) ...[
              _sheetAction(
                sheetContext,
                account.isDefault ? '清除默认' : '设置默认',
                () => _changeDefault(
                  () => account.isDefault
                      ? widget.controller.clearDefaultAccount(account.id)
                      : widget.controller.setDefaultAccount(account.id),
                ),
              ),
              _sheetAction(
                sheetContext,
                '删除账号',
                () => _confirmDelete(
                  title: '删除账号',
                  delete: () => widget.controller.deleteAccount(account.id),
                ),
              ),
            ],
            _sheetAction(
              sheetContext,
              '删除服务器',
              () => _confirmDelete(
                title: '删除服务器',
                delete: () => widget.controller.deleteServer(server.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(ServerAccountItem item) {
    final server = item.server;
    final account = item.account;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        key: Key(
          account == null
              ? 'server-no-account-${server.id}'
              : 'server-account-${account.id}',
        ),
        borderRadius: BorderRadius.circular(14),
        onTap: item.canEnter ? () => widget.onSelected?.call(item) : null,
        onLongPress: () => _showActions(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _serverName(server),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                '${server.domain}:${server.port}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              if (account != null)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        account.account,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    if (account.isDefault)
                      Text(
                        '默认',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                  ],
                )
              else ...[
                Text(
                  '未添加账号',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    key: Key('add-account-${server.id}'),
                    onPressed: widget.onAddAccount == null
                        ? null
                        : () => widget.onAddAccount!(server),
                    child: const Text('添加账号'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('服务器/账号'),
        actions: [
          IconButton(
            key: const Key('add-server'),
            icon: const Icon(Icons.add),
            tooltip: '添加服务器',
            onPressed: widget.onAddServer,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.controller.items.isEmpty)
              const Text('暂无服务器'),
            for (final item in widget.controller.items) _buildItem(item),
          ],
        ),
      ),
    );
  }
}
