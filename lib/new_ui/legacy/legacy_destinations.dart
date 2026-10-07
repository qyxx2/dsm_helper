import 'dart:io';

import 'package:dsm_helper/models/Syno/Core/Notify.dart';
import 'package:dsm_helper/new_ui/intents/external_intent.dart';
import 'package:dsm_helper/new_ui/legacy/legacy_page_host.dart';
import 'package:dsm_helper/new_ui/shell/primary_destination.dart';
import 'package:dsm_helper/pages/applications/applications.dart';
import 'package:dsm_helper/pages/dashboard/dashboard.dart';
import 'package:dsm_helper/pages/download_station/add_task.dart';
import 'package:dsm_helper/pages/file/file_page.dart';
import 'package:dsm_helper/pages/file/upload.dart';
import 'package:dsm_helper/pages/notify/notify.dart';
import 'package:dsm_helper/pages/setting/setting.dart';
import 'package:dsm_helper/pages/transfer/transfer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';

abstract final class LegacyDestinations {
  static Future<void> openPrimary(
    BuildContext context,
    PrimaryDestination destination,
  ) async {
    final Widget page;
    Future<bool> Function()? onBackAttempt;

    switch (destination) {
      case PrimaryDestination.overview:
        page = Dashboard();
      case PrimaryDestination.files:
        final fileKey = GlobalKey<FilePageState>();
        page = FilePage(key: fileKey);
        onBackAttempt = () async {
          final navigator = fileKey.currentState?.navigatorKey.currentState;
          if (navigator != null && navigator.canPop()) {
            navigator.pop();
            return true;
          }
          return false;
        };
      case PrimaryDestination.applications:
        page = const Applications();
      case PrimaryDestination.tasks:
        page = Transfer();
      case PrimaryDestination.mine:
        page = Setting();
    }

    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LegacyPageHost(
          onBackAttempt: onBackAttempt,
          child: page,
        ),
      ),
    );
  }

  static Future<void> openNotifications(BuildContext context) async {
    final notifies = await DsmNotify.notify();
    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LegacyPageHost(
          child: Notify(notifies),
        ),
      ),
    );
  }

  static Future<void> openExternalIntent(
    BuildContext context,
    ExternalIntentPayload payload,
  ) async {
    if (!context.mounted) {
      return;
    }

    Widget page;
    if (payload.kind == ExternalIntentKind.torrent) {
      var path = payload.paths.single;
      if (Platform.isAndroid) {
        path = await FlutterSharingIntent.getAbsolutePath(path);
      }
      page = AddDownloadTask(torrentPath: path);
    } else {
      page = Upload('', selectedFilesPath: payload.paths);
    }

    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LegacyPageHost(child: page),
      ),
    );
  }
}
