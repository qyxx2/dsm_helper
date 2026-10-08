import 'package:dsm_helper/models/Syno/Api/auth.dart';
import 'package:dsm_helper/new_ui/auth/server_account_store.dart';
import 'package:flutter/material.dart';

typedef RemoteLogoutAction = Future<bool> Function();

/// A local logout always completes after the saved session is invalidated,
/// even if the best-effort DSM logout or trusted-device request fails.
class LogoutController {
  LogoutController({
    required this.store,
    RemoteLogoutAction? remoteLogout,
    RemoteLogoutAction? remoteForget,
    this.onLocalExit,
  })  : _remoteLogout = remoteLogout ?? Auth.logout,
        _remoteForget = remoteForget ?? Auth.forget;

  final ServerAccountStore store;
  final RemoteLogoutAction _remoteLogout;
  final RemoteLogoutAction _remoteForget;
  final VoidCallback? onLocalExit;
  bool _busy = false;

  Future<void> logout({
    required int accountId,
    bool forgetDevice = false,
  }) async {
    if (_busy) return;
    _busy = true;
    try {
      // A failed optional forget request must not prevent Auth.logout.
      if (forgetDevice) {
        try {
          await _remoteForget();
        } catch (_) {
          // Only remote best-effort failures are suppressed.
        }
      }
      try {
        await _remoteLogout();
      } catch (_) {
        // Offline DSM still permits local logout.
      }
      // Never report local exit if persistence fails.
      await store.clearAccountSession(accountId);
      onLocalExit?.call();
    } finally {
      _busy = false;
    }
  }
}

/// Standalone confirmation hook for Batch 5's account/logout entry.
/// This does not change the Task 3 shell or legacy navigation.
Future<void> showLogoutConfirmation(
  BuildContext context, {
  required LogoutController controller,
  required int accountId,
}) async {
  var forgetDevice = false;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: const Text('确认退出当前账号？'),
        content: CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('取消记住本设备'),
          value: forgetDevice,
          onChanged: (value) {
            setDialogState(() => forgetDevice = value ?? false);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('退出登录'),
          ),
        ],
      ),
    ),
  );
  if (confirmed != true) return;
  try {
    await controller.logout(
      accountId: accountId,
      forgetDevice: forgetDevice,
    );
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('本地退出失败，请重试')),
      );
    }
  }
}
