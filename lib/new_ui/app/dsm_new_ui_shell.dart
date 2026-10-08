import 'dart:async';
import 'dart:io';

import 'package:dsm_helper/new_ui/app/new_ui_app_shell.dart';
import 'package:dsm_helper/new_ui/intents/external_intent_listener.dart';
import 'package:dsm_helper/new_ui/intents/external_intent_router.dart';
import 'package:dsm_helper/new_ui/intents/flutter_sharing_intent_source.dart';
import 'package:dsm_helper/new_ui/legacy/legacy_page_host.dart';
import 'package:dsm_helper/new_ui/legacy/legacy_shared_bootstrap.dart';
import 'package:dsm_helper/new_ui/notifications/legacy_notification_entry.dart';
import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:dsm_helper/new_ui/session/dsm_provider_scope.dart';
import 'package:dsm_helper/new_ui/system/new_ui_system_bars.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:dsm_helper/pages/applications/applications.dart';
import 'package:dsm_helper/pages/dashboard/dashboard.dart';
import 'package:dsm_helper/pages/download_station/add_task.dart';
import 'package:dsm_helper/pages/file/file_page.dart';
import 'package:dsm_helper/pages/file/upload.dart';
import 'package:dsm_helper/pages/setting/setting.dart';
import 'package:dsm_helper/pages/transfer/transfer.dart';
import 'package:dsm_helper/providers/background_task_provider.dart';
import 'package:dsm_helper/providers/dark_mode.dart';
import 'package:dsm_helper/providers/external_device_provider.dart';
import 'package:dsm_helper/providers/init_data_provider.dart';
import 'package:dsm_helper/providers/storage_provider.dart';
import 'package:dsm_helper/providers/system_info_provider.dart';
import 'package:dsm_helper/providers/utilization_provider.dart';
import 'package:dsm_helper/utils/overlay_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:provider/provider.dart';
import 'package:sp_util/sp_util.dart';

class DsmNewUiShell extends StatefulWidget {
  const DsmNewUiShell({
    super.key,
    this.initialContextStatus = ActiveContextStatus.authenticated,
    this.contextId,
    this.legacyBootstrap,
    this.onManageAccounts,
    this.onLogout,
  });

  final ActiveContextStatus initialContextStatus;
  final String? contextId;
  final LegacySharedBootstrap? legacyBootstrap;
  final VoidCallback? onManageAccounts;
  final VoidCallback? onLogout;

  @override
  State<DsmNewUiShell> createState() => _DsmNewUiShellState();
}

class _DsmNewUiShellState extends State<DsmNewUiShell> {
  final GlobalKey<FilePageState> _filePageKey = GlobalKey<FilePageState>();
  late final FlutterSharingIntentSource _intentSource =
      const FlutterSharingIntentSource();
  bool _overlayInitialized = false;

  @override
  void initState() {
    super.initState();
    SpUtil.putBool('agreement', true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_overlayInitialized) {
      OverlayUtil.init(context);
      _overlayInitialized = true;
    }
  }

  ThemeData _themeFor(BuildContext context, int darkMode) {
    switch (darkMode) {
      case 0:
        return NewUiTheme.light();
      case 1:
        return NewUiTheme.dark();
      case 2:
      default:
        return MediaQuery.of(context).platformBrightness == Brightness.dark
            ? NewUiTheme.dark()
            : NewUiTheme.light();
    }
  }

  String? get _connectionStatusText {
    switch (widget.initialContextStatus) {
      case ActiveContextStatus.authenticated:
        return null;
      case ActiveContextStatus.offline:
        return '离线';
      case ActiveContextStatus.reauthNeeded:
        return '需要重新登录';
      case ActiveContextStatus.failed:
        return '连接异常';
    }
  }

  bool _handleFileBack() {
    final navigator = _filePageKey.currentState?.navigatorKey.currentState;
    if (navigator == null || !navigator.canPop()) {
      return false;
    }
    navigator.pop();
    return true;
  }

  Future<void> _handleIntent(
    BuildContext context,
    DsmProviderScope providerScope,
    ExternalIntentDecision decision,
  ) async {
    try {
      switch (decision.kind) {
        case ExternalIntentKind.none:
          return;
        case ExternalIntentKind.torrent:
          var path = decision.paths.single;
          if (Platform.isAndroid) {
            path = await FlutterSharingIntent.getAbsolutePath(path);
          }
          if (!context.mounted) {
            return;
          }
          await Navigator.of(context, rootNavigator: true).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => providerScope.wrap(
                LegacyPageHost(
                  builder: (_) => AddDownloadTask(torrentPath: path),
                ),
              ),
            ),
          );
        case ExternalIntentKind.upload:
          await Navigator.of(context, rootNavigator: true).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => providerScope.wrap(
                LegacyPageHost(
                  builder: (_) => Upload(
                    '',
                    selectedFilesPath: decision.paths,
                  ),
                ),
              ),
            ),
          );
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法处理共享内容')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = context.watch<DarkModeProvider>().darkMode;
    final theme = _themeFor(context, darkMode);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(NewUiSystemBars.apply(theme.brightness));
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: NewUiSystemBars.forBrightness(theme.brightness),
      child: Theme(
        data: theme,
        child: KeyedSubtree(
          key: ValueKey(widget.contextId ?? 'legacy-current-context'),
          child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SystemInfoProvider()),
            ChangeNotifierProvider(create: (_) => InitDataProvider()),
            ChangeNotifierProvider(create: (_) => UtilizationProvider()),
            ChangeNotifierProvider(create: (_) => StorageProvider()),
            ChangeNotifierProvider(create: (_) => ExternalDeviceProvider()),
            ChangeNotifierProvider(create: (_) => BackgroundTaskProvider()),
          ],
          child: LegacySharedBootstrapBoundary(
            bootstrap: widget.legacyBootstrap ?? LegacySharedBootstrap(),
            enabled: widget.initialContextStatus ==
                ActiveContextStatus.authenticated,
            child: Builder(
              builder: (shellContext) {
                final providerScope = DsmProviderScope.capture(shellContext);

                return ExternalIntentListener(
                  source: _intentSource,
                  onDecision: (decision) {
                    unawaited(
                      _handleIntent(shellContext, providerScope, decision),
                    );
                  },
                  child: NewUiAppShell(
                    legacyHostWrapper: providerScope.wrap,
                    connectionStatusText: _connectionStatusText,
                    onOpenAccountManagement: widget.onManageAccounts,
                    onLogout: widget.onLogout,
                    notificationBuilder: (_) => const LegacyNotificationEntry(),
                    destinations: [
                      NewUiAppDestination(
                        label: '概览',
                        icon: Icons.dashboard_outlined,
                        selectedIcon: Icons.dashboard,
                        legacyBuilder: (_) => Dashboard(),
                      ),
                      NewUiAppDestination(
                        label: '文件',
                        icon: Icons.folder_outlined,
                        selectedIcon: Icons.folder,
                        legacyBuilder: (_) => FilePage(key: _filePageKey),
                        onLegacyBack: _handleFileBack,
                      ),
                      NewUiAppDestination(
                        label: '应用',
                        icon: Icons.apps_outlined,
                        selectedIcon: Icons.apps,
                        legacyBuilder: (_) => Applications(),
                      ),
                      NewUiAppDestination(
                        label: '任务',
                        icon: Icons.swap_vert_outlined,
                        selectedIcon: Icons.swap_vert,
                        legacyBuilder: (_) => Transfer(),
                      ),
                      NewUiAppDestination(
                        label: '我的',
                        icon: Icons.person_outline,
                        selectedIcon: Icons.person,
                        legacyBuilder: (_) => Setting(
                          onManageAccounts: widget.onManageAccounts,
                          onLogout: widget.onLogout,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ),
        ),
      ),
    );
  }
}
