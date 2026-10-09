import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:background_downloader_sql/background_downloader_sql.dart';
import 'package:dsm_helper/apis/api.dart';
import 'package:dsm_helper/apis/dsm_api/dsm_api.dart';
import 'package:dsm_helper/database/table_extension.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/models/api_model.dart';
import 'package:dsm_helper/new_ui/app/dsm_new_ui_shell.dart';
import 'package:dsm_helper/new_ui/dashboard/overview_page.dart';
import 'package:dsm_helper/new_ui/auth/auth_flow_controller.dart';
import 'package:dsm_helper/new_ui/auth/auth_flow_models.dart';
import 'package:dsm_helper/new_ui/auth/login_page.dart';
import 'package:dsm_helper/new_ui/auth/logout_controller.dart';
import 'package:dsm_helper/new_ui/auth/server_account_controller.dart';
import 'package:dsm_helper/new_ui/auth/server_account_page.dart';
import 'package:dsm_helper/new_ui/auth/server_account_store.dart';
import 'package:dsm_helper/new_ui/auth/server_form_controller.dart';
import 'package:dsm_helper/new_ui/auth/server_form_page.dart';
import 'package:dsm_helper/new_ui/lifecycle/launch_auth_gate.dart';
import 'package:dsm_helper/new_ui/lifecycle/launch_auth_policy.dart';
import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:dsm_helper/new_ui/session/dsm_active_context_adapter.dart';
import 'package:dsm_helper/new_ui/session/legacy_session_bridge.dart';
import 'package:dsm_helper/new_ui/startup/dsm_startup_data_source.dart';
import 'package:dsm_helper/new_ui/startup/modern_startup.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:dsm_helper/pages/login/auth_page.dart';
import 'package:dsm_helper/utils/db_utils.dart';
import 'package:flutter/material.dart';
import 'package:sp_util/sp_util.dart';

typedef ModernLoginPreparation = Future<void> Function(
  Server server,
  Account? savedAccount,
);

/// Task 4's sole migrated authentication entry. All successful paths activate
/// the Task 3 context before presenting the shell.
class ModernUiRoot extends StatefulWidget {
  const ModernUiRoot({
    super.key,
    required this.initialAuthRequired,
    this.dataSource,
    this.contextActivator,
    this.authLogin,
    this.serverProbe,
    this.loginPreparation,
    this.shellBuilder,
    this.overviewControllerFactory,
    this.gatePolicy,
    this.initializeDownloader = true,
  });

  final bool initialAuthRequired;
  // Explicit seams let relationship tests use real Drift with fake DSM I/O.
  final StartupDataSource? dataSource;
  final StartupContextActivator? contextActivator;
  final AuthLogin? authLogin;
  final ServerFormProbe? serverProbe;
  final ModernLoginPreparation? loginPreparation;
  final StartupShellBuilder? shellBuilder;
  final OverviewControllerFactory? overviewControllerFactory;
  final Future<bool> Function()? gatePolicy;
  final bool initializeDownloader;

  @override
  State<ModernUiRoot> createState() => _ModernUiRootState();
}

enum _AuthView { startup, loading, selector, form, login, shell, error }

class _ModernUiRootState extends State<ModernUiRoot> {
  final DsmActiveContextAdapter _contextAdapter = DsmActiveContextAdapter();
  late final ServerAccountStore _store = ServerAccountStore(DbUtils.db);
  late final ServerAccountController _accounts =
      ServerAccountController(store: _store);

  _AuthView _view = _AuthView.startup;
  ServerFormController? _form;
  AuthFlowController? _auth;
  ActiveContextResult? _activeResult;
  String _errorMessage = '';
  VoidCallback? _retry;
  bool _authCompleted = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initializeDownloader) {
      FileDownloader(persistentStorage: SqlitePersistentStorage());
    }
  }

  @override
  void dispose() {
    _generation++;
    _auth?.removeListener(_onAuthenticated);
    _auth?.dispose();
    _form?.dispose();
    _accounts.dispose();
    super.dispose();
  }

  Future<bool> _shouldGate() async {
    if (widget.gatePolicy != null) return widget.gatePolicy!();
    return LaunchAuthPolicy.shouldGate(
      launchAuth: SpUtil.getBool('launch_auth', defValue: false) ?? false,
      passwordEnabled:
          SpUtil.getBool('launch_auth_password', defValue: false) ?? false,
      biometricsEnabled:
          SpUtil.getBool('launch_auth_biometrics', defValue: false) ?? false,
    );
  }

  void _busy() {
    if (mounted) setState(() => _view = _AuthView.loading);
  }

  void _failure(String message, VoidCallback retry) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _retry = retry;
      _view = _AuthView.error;
    });
  }

  void _showSelector() {
    _generation++;
    if (mounted) setState(() => _view = _AuthView.selector);
  }

  void _showForm(Server? server) {
    _generation++;
    _form?.dispose();
    _form = ServerFormController(
      db: DbUtils.db,
      existingServer: server,
      probe: widget.serverProbe,
    );
    if (mounted) setState(() => _view = _AuthView.form);
  }

  Widget _serverFormPage() {
    final controller = _form ??= ServerFormController(
      db: DbUtils.db,
      probe: widget.serverProbe,
    );
    return ServerFormPage(
      controller: controller,
      onSaved: (server) {
        if (controller.existingServer != null) {
          _showSelector();
        } else {
          unawaited(_beginLogin(server));
        }
      },
    );
  }

  Widget _selectorPage() {
    return ServerAccountPage(
      controller: _accounts,
      onAddServer: () => _showForm(null),
      onAddAccount: (server) => unawaited(_beginLogin(server)),
      onEditServer: _showForm,
      onSelected: (item) {
        final account = item.account;
        if (account != null) {
          unawaited(_activateAccount(item.server, account));
        }
      },
    );
  }

  Future<void> _prepareLogin(Server server, Account? saved) async {
    if (widget.loginPreparation != null) {
      await widget.loginPreparation!(server, saved);
      return;
    }
    ApiModel.apiInfo = <String, ApiModel>{};
    Api.dsm = DsmApi(
      baseUrl: server.url,
      deviceId: saved?.deviceId,
      sid: saved?.sid,
      checkSsl: server.checkSsl,
    );
    ApiModel.apiInfo = await ApiModel.info();
  }

  Future<void> _beginLogin(
    Server server, {
    Account? savedAccount,
    bool automatic = false,
  }) async {
    final ticket = ++_generation;
    _busy();
    try {
      await _prepareLogin(server, savedAccount);
      if (!mounted || ticket != _generation) return;

      _auth?.removeListener(_onAuthenticated);
      _auth?.dispose();
      final controller = AuthFlowController(
        server: server,
        existingAccount: savedAccount,
        store: _store,
        login: widget.authLogin,
      );
      _auth = controller;
      _authCompleted = false;
      controller.addListener(_onAuthenticated);
      setState(() => _view = _AuthView.login);

      if (automatic) {
        await controller.reauthenticateSavedAccount();
      }
    } catch (_) {
      if (ticket != _generation) return;
      _failure(
        '无法准备此服务器的登录，请检查连接并重试',
        () => unawaited(_beginLogin(
          server,
          savedAccount: savedAccount,
          automatic: automatic,
        )),
      );
    }
  }

  void _onAuthenticated() {
    final controller = _auth;
    if (!mounted ||
        controller == null ||
        _view != _AuthView.login ||
        _authCompleted ||
        controller.state.stage != AuthFlowStage.authenticated) {
      return;
    }
    final account = controller.state.authenticatedAccount;
    if (account == null) return;
    _authCompleted = true;
    unawaited(_activateAccount(
      controller.server,
      account,
      automaticReauth: false,
    ));
  }

  Future<void> _activateAccount(
    Server server,
    Account account, {
    bool automaticReauth = true,
  }) async {
    final ticket = ++_generation;
    _busy();
    try {
      final result =
          await (widget.contextActivator ?? _contextAdapter.activate)(
        ActiveContextRequest(
          contextId: '${server.id}/${account.id}',
          baseUrl: server.url,
          deviceId: account.deviceId,
          sid: account.sid,
          checkSsl: server.checkSsl,
        ),
      );
      if (!mounted || ticket != _generation) return;
      switch (result.status) {
        case ActiveContextStatus.authenticated:
        case ActiveContextStatus.offline:
          setState(() {
            _activeResult = result;
            _view = _AuthView.shell;
          });
          return;
        case ActiveContextStatus.reauthNeeded:
          if (automaticReauth) {
            await _beginLogin(
              server,
              savedAccount: account,
              automatic: true,
            );
          } else {
            _failure('登录后的会话仍被服务器拒绝，请重试',
                () => unawaited(_beginLogin(server, savedAccount: account)));
          }
          return;
        case ActiveContextStatus.failed:
          _failure(
            '无法激活此账号，请重试',
            () => unawaited(_activateAccount(server, account)),
          );
          return;
      }
    } catch (_) {
      if (ticket != _generation) return;
      _failure(
        '激活账号失败，请重试',
        () => unawaited(_activateAccount(server, account)),
      );
    }
  }

  Future<void> _reauthSaved(StartupSavedContext saved) =>
      _reauthSavedAccountIds(
        serverId: saved.serverId,
        accountId: saved.accountId,
      );

  Future<void> _reauthSavedAccountIds({
    required int serverId,
    required int accountId,
  }) async {
    final ticket = ++_generation;
    _busy();
    try {
      final server = await (DbUtils.db.select(DbUtils.db.servers)
            ..where((row) => row.id.equals(serverId)))
          .getSingleOrNull();
      final account = await (DbUtils.db.select(DbUtils.db.accounts)
            ..where((row) => row.id.equals(accountId)))
          .getSingleOrNull();
      if (!mounted || ticket != _generation) return;
      if (server == null ||
          account == null ||
          account.serverId != server.id) {
        _failure('保存的服务器或账号已不存在', _showSelector);
        return;
      }
      await _beginLogin(
        server,
        savedAccount: account,
        automatic: true,
      );
    } catch (_) {
      if (ticket != _generation) return;
      _failure('无法读取保存的账号', _showSelector);
    }
  }

  Future<void> _logout(int accountId) async {
    await showLogoutConfirmation(
      context,
      controller: LogoutController(
        store: _store,
        onLocalExit: () {
          // Clearing the persistent SID alone must not leave an active
          // legacy transport or capability map behind.
          ApiModel.apiInfo = <String, ApiModel>{};
          Api.dsm = DsmApi();
          LegacySessionBridge.bindValues(baseUrl: '', sid: '');
          _showSelector();
        },
      ),
      accountId: accountId,
    );
  }

  Widget _shellFor(ActiveContextResult result) {
    if (widget.shellBuilder != null) {
      return widget.shellBuilder!(context, result);
    }
    final accountId = int.tryParse(result.contextId.split('/').last);
    return DsmNewUiShell(
      initialContextStatus: result.status,
      contextId: result.contextId,
      overviewControllerFactory: widget.overviewControllerFactory,
      onManageAccounts: _showSelector,
      onReauthNeeded: () {
        // Accept only the shell's current saved context; a stale route
        // must never start a reauthentication for an older account.
        if (!mounted ||
            (_view != _AuthView.startup && _view != _AuthView.shell) ||
            (_view == _AuthView.shell &&
                _activeResult?.contextId != result.contextId)) {
          return;
        }
        final parts = result.contextId.split('/');
        if (parts.length != 2) return;
        final serverId = int.tryParse(parts[0]);
        final savedAccountId = int.tryParse(parts[1]);
        if (serverId == null || savedAccountId == null) return;
        unawaited(_reauthSavedAccountIds(
          serverId: serverId,
          accountId: savedAccountId,
        ));
      },
      onLogout: accountId == null
          ? null
          : () => unawaited(_logout(accountId)),
    );
  }

  Widget _content(BuildContext context) {
    switch (_view) {
      case _AuthView.startup:
        return ModernStartup(
          dataSource: widget.dataSource ?? const DsmStartupDataSource(),
          activateContext: widget.contextActivator ?? _contextAdapter.activate,
          addServerBuilder: (_) => _serverFormPage(),
          selectAccountBuilder: (_) => _selectorPage(),
          shellBuilder: (_, result) => _shellFor(result),
          onReauthNeeded: (saved) => unawaited(_reauthSaved(saved)),
        );
      case _AuthView.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case _AuthView.selector:
        return _selectorPage();
      case _AuthView.form:
        return _serverFormPage();
      case _AuthView.login:
        return LoginPage(controller: _auth!);
      case _AuthView.shell:
        return _shellFor(_activeResult!);
      case _AuthView.error:
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_errorMessage),
                const SizedBox(height: 12),
                FilledButton(onPressed: _retry, child: const Text('重试')),
                TextButton(
                  onPressed: _showSelector,
                  child: const Text('选择其他账号'),
                ),
              ],
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final modernTheme = Theme.of(context).brightness == Brightness.dark
        ? NewUiTheme.dark()
        : NewUiTheme.light();
    return LaunchAuthGate(
      gateInitially: widget.initialAuthRequired,
      shouldGate: _shouldGate,
      gateBuilder: (_) => AuthPage(launch: false),
      child: Theme(
        data: modernTheme,
        child: _content(context),
      ),
    );
  }
}
