import 'package:dsm_helper/models/Syno/Core/Notify.dart';
import 'package:dsm_helper/models/Syno/Core/Notify/DsmNotifyStrings.dart';
import 'package:dsm_helper/pages/notify/notify.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:flutter/material.dart';

class LegacyNotificationEntry extends StatefulWidget {
  const LegacyNotificationEntry({super.key});

  @override
  State<LegacyNotificationEntry> createState() => _LegacyNotificationEntryState();
}

class _LegacyNotificationEntryState extends State<LegacyNotificationEntry> {
  DsmNotify? _notifications;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _notifications = null;
      _error = null;
    });

    try {
      try {
        Utils.notifyStrings = await DsmNotifyStrings.get();
      } catch (_) {
        // Notification strings are presentation metadata. Raw notification
        // content remains usable when the strings endpoint is unavailable.
      }

      final notifications = await DsmNotify.notify();
      notifications.items ??= [];
      if (!mounted) {
        return;
      }
      setState(() {
        _notifications = notifications;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _notifications;
    if (notifications != null) {
      return Notify(notifications);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('消息')),
      body: Center(
        child: _error == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('消息加载失败'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _load,
                    child: const Text('重试'),
                  ),
                ],
              ),
      ),
    );
  }
}
