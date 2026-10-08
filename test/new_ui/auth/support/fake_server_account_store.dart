import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/new_ui/auth/server_account_store.dart';

/// In-memory store for widget tests. Real Drift transactions are covered by
/// auth_flow_controller_test.dart, outside the widget FakeAsync test zone.
class FakeServerAccountStore extends ServerAccountStore {
  FakeServerAccountStore(super.db, {this.existingAccount});

  final Account? existingAccount;
  final List<Account> savedAccounts = [];

  @override
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
  }) async {
    final previous = savedAccounts.isEmpty ? existingAccount : savedAccounts.last;
    final saved = Account(
      id: previous?.id ?? 1,
      serverId: serverId,
      account: account,
      password: password,
      remark: previous?.remark ?? '',
      createTime: previous?.createTime ?? timestamp,
      lastLoginTime: timestamp,
      isDefault: isDefault,
      deviceId: deviceId,
      sid: sid,
      ikMessage: ikMessage,
      synoToken: synoToken,
    );
    savedAccounts.add(saved);
    return saved;
  }
}
