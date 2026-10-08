import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/new_ui/auth/server_account_store.dart';
import 'package:flutter/foundation.dart';

@immutable
class ServerAccountItem {
  const ServerAccountItem({required this.server, this.account});

  final Server server;
  final Account? account;

  bool get canEnter => account != null;
}

/// Server/Account presentation and mutations, not active-context activation.
/// The caller of [ServerAccountPage] owns selecting/activating the saved pair.
class ServerAccountController extends ChangeNotifier {
  ServerAccountController({required this.store});

  final ServerAccountStore store;
  List<ServerAccountItem> _items = const [];
  bool _disposed = false;

  List<ServerAccountItem> get items => List.unmodifiable(_items);

  Future<void> load() async {
    final servers = await store.db.select(store.db.servers).get();
    final accounts = await store.db.select(store.db.accounts).get();
    servers.sort((a, b) => a.id.compareTo(b.id));
    accounts.sort((a, b) => a.id.compareTo(b.id));

    final accountsByServer = <int, List<Account>>{};
    for (final account in accounts) {
      accountsByServer.putIfAbsent(account.serverId, () => []).add(account);
    }

    final joined = <ServerAccountItem>[];
    for (final server in servers) {
      final saved = accountsByServer[server.id];
      if (saved == null || saved.isEmpty) {
        joined.add(ServerAccountItem(server: server));
      } else {
        for (final account in saved) {
          joined.add(ServerAccountItem(server: server, account: account));
        }
      }
    }

    if (_disposed) return;
    _items = joined;
    notifyListeners();
  }

  Future<void> setDefaultAccount(int accountId) async {
    await store.setDefaultAccount(accountId);
    await load();
  }

  Future<void> clearDefaultAccount(int accountId) async {
    await store.clearDefaultAccount(accountId);
    await load();
  }

  Future<void> deleteAccount(int accountId) async {
    await store.deleteAccount(accountId);
    await load();
  }

  Future<void> deleteServer(int serverId) async {
    await store.deleteServer(serverId);
    await load();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
