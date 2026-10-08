import 'package:drift/drift.dart';
import 'package:dsm_helper/database/tables.dart';

class ServerAccountStore {
  const ServerAccountStore(this.db);

  final Database db;

  Future<void> deleteServer(int serverId) {
    return db.transaction(() async {
      await db.deleteAccountByServerId(serverId);
      final deleted =
          await (db.delete(db.servers)..where((table) => table.id.equals(serverId))).go();
      if (deleted != 1) {
        throw StateError('Server not found: $serverId');
      }
    });
  }

  Future<void> setDefaultAccount(int accountId) {
    return db.transaction(() async {
      final target = await (db.select(db.accounts)
            ..where((table) => table.id.equals(accountId)))
          .getSingleOrNull();
      if (target == null) {
        throw StateError('Account not found: $accountId');
      }

      await db.update(db.accounts).write(
            const AccountsCompanion(isDefault: Value(false)),
          );
      await (db.update(db.accounts)..where((table) => table.id.equals(accountId)))
          .write(
        const AccountsCompanion(isDefault: Value(true)),
      );
    });
  }

  Future<Account> saveAuthenticatedAccount({
    required int serverId,
    required String account,
    required String password,
    required bool isDefault,
    required String deviceId,
    required String sid,
    required String ikMessage,
    required String synoToken,
    required int timestamp,
  }) {
    return db.transaction(() async {
      final existing = await (db.select(db.accounts)
            ..where(
              (table) =>
                  table.serverId.equals(serverId) &
                  table.account.equals(account),
            ))
          .getSingleOrNull();

      if (isDefault) {
        await db.update(db.accounts).write(
              const AccountsCompanion(isDefault: Value(false)),
            );
      }

      if (existing == null) {
        return db.into(db.accounts).insertReturning(
              AccountsCompanion.insert(
                serverId: serverId,
                account: account,
                password: password,
                remark: '',
                createTime: timestamp,
                lastLoginTime: timestamp,
                isDefault: isDefault,
                deviceId: deviceId,
                sid: sid,
                ikMessage: ikMessage,
                synoToken: synoToken,
              ),
            );
      }

      final updated = existing.copyWith(
        password: password,
        lastLoginTime: timestamp,
        isDefault: isDefault,
        deviceId: deviceId,
        sid: sid,
        ikMessage: ikMessage,
        synoToken: synoToken,
      );
      await db.updateAccount(updated);
      return updated;
    });
  }

  Future<void> clearDefaultAccount(int accountId) {
    return db.transaction(() async {
      final updated =
          await (db.update(db.accounts)..where((table) => table.id.equals(accountId)))
              .write(
        const AccountsCompanion(isDefault: Value(false)),
      );
      if (updated != 1) {
        throw StateError('Account not found: $accountId');
      }
    });
  }
}
