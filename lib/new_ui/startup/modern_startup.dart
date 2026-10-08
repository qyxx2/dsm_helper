import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:dsm_helper/new_ui/startup/startup_resolver.dart';
import 'package:flutter/material.dart';

class StartupSavedContext {
  const StartupSavedContext({
    required this.accountId,
    required this.serverId,
    required this.isDefault,
    required this.baseUrl,
    required this.deviceId,
    required this.sid,
    this.checkSsl = true,
  });

  final int accountId;
  final int serverId;
  final bool isDefault;
  final String baseUrl;
  final String deviceId;
  final String sid;
  final bool checkSsl;

  StartupAccountCandidate get candidate => StartupAccountCandidate(
        accountId: accountId,
        serverId: serverId,
        isDefault: isDefault,
      );

  ActiveContextRequest get request => ActiveContextRequest(
        contextId: '$serverId/$accountId',
        baseUrl: baseUrl,
        deviceId: deviceId,
        sid: sid,
        checkSsl: checkSsl,
      );
}

class StartupSnapshot {
  const StartupSnapshot({
    required this.hasServers,
    required this.launcherSelectionEnabled,
    required this.knownServerIds,
    required this.contexts,
  });

  final bool hasServers;
  final bool launcherSelectionEnabled;
  final Set<int> knownServerIds;
  final List<StartupSavedContext> contexts;
}

abstract interface class StartupDataSource {
  Future<StartupSnapshot> load();
}

typedef StartupContextActivator = Future<ActiveContextResult> Function(
  ActiveContextRequest request,
);
typedef StartupShellBuilder = Widget Function(
  BuildContext context,
  ActiveContextResult result,
);
typedef StartupErrorBuilder = Widget Function(
  BuildContext context,
  Object error,
  VoidCallback retry,
);

enum _StartupPhase {
  loading,
  addServer,
  selectAccount,
  shell,
  reauth,
  error,
}

class ModernStartup extends StatefulWidget {
  const ModernStartup({
    super.key,
    required this.dataSource,
    required this.activateContext,
    required this.addServerBuilder,
    required this.selectAccountBuilder,
    required this.shellBuilder,
    this.onReauthNeeded,
    this.errorBuilder,
  });

  final StartupDataSource dataSource;
  final StartupContextActivator activateContext;
  final WidgetBuilder addServerBuilder;
  final WidgetBuilder selectAccountBuilder;
  final StartupShellBuilder shellBuilder;
  final ValueChanged<StartupSavedContext>? onReauthNeeded;
  final StartupErrorBuilder? errorBuilder;

  @override
  State<ModernStartup> createState() => _ModernStartupState();
}

class _ModernStartupState extends State<ModernStartup> {
  _StartupPhase _phase = _StartupPhase.loading;
  ActiveContextResult? _result;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    if (mounted) {
      setState(() {
        _phase = _StartupPhase.loading;
        _result = null;
        _error = null;
      });
    }

    try {
      final snapshot = await widget.dataSource.load();
      final resolution = StartupResolver.resolve(
        hasServers: snapshot.hasServers,
        launcherSelectionEnabled: snapshot.launcherSelectionEnabled,
        accounts: snapshot.contexts
            .map((context) => context.candidate)
            .toList(growable: false),
        knownServerIds: snapshot.knownServerIds,
      );

      if (!mounted) {
        return;
      }

      switch (resolution.target) {
        case StartupTarget.addServer:
          setState(() {
            _phase = _StartupPhase.addServer;
          });
          return;
        case StartupTarget.selectAccount:
          setState(() {
            _phase = _StartupPhase.selectAccount;
          });
          return;
        case StartupTarget.shell:
          final context = snapshot.contexts.singleWhere(
            (candidate) =>
                candidate.accountId == resolution.accountId &&
                candidate.serverId == resolution.serverId,
          );
          final result = await widget.activateContext(context.request);
          if (!mounted) {
            return;
          }
          switch (result.status) {
            case ActiveContextStatus.authenticated:
            case ActiveContextStatus.offline:
              setState(() {
                _result = result;
                _phase = _StartupPhase.shell;
              });
              return;
            case ActiveContextStatus.reauthNeeded:
              final onReauthNeeded = widget.onReauthNeeded;
              if (onReauthNeeded == null) {
                setState(() {
                  _error = StateError('Exact-account reauthentication handler is missing');
                  _phase = _StartupPhase.error;
                });
              } else {
                setState(() {
                  _phase = _StartupPhase.reauth;
                });
                onReauthNeeded(context);
              }
              return;
            case ActiveContextStatus.failed:
              setState(() {
                _error = result.error ?? StateError('Context activation failed');
                _phase = _StartupPhase.error;
              });
              return;
          }
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _phase = _StartupPhase.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _StartupPhase.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case _StartupPhase.addServer:
        return widget.addServerBuilder(context);
      case _StartupPhase.selectAccount:
        return widget.selectAccountBuilder(context);
      case _StartupPhase.shell:
        return widget.shellBuilder(context, _result!);
      case _StartupPhase.reauth:
        return const Scaffold(
          body: Center(child: Text('正在重新认证账号')),
        );
      case _StartupPhase.error:
        final error = _error!;
        final builder = widget.errorBuilder;
        if (builder != null) {
          return builder(context, error, _resolve);
        }
        return Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: _resolve,
              child: const Text('重试'),
            ),
          ),
        );
    }
  }
}
